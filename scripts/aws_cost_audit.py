#!/usr/bin/env python3
import boto3
import csv
import datetime
import argparse
import botocore

# --- CONFIGURATION: enable/disable services here ---
ENABLED_SERVICES = [
    "ec2",
    "ebs",
    "elastic_ip",
    "load_balancer",
    "rds",
    "eks",
    "ecs",
    "ecr",
    "dynamodb",
    "lambda",
    "s3",
    "secretsmanager",
    "cloudfront",
    "route53",
    "iam",
]

# --- UTILITIES ---
def iso_or_none(dt):
    if not dt:
        return ""
    if isinstance(dt, str):
        return dt
    if isinstance(dt, datetime.datetime):
        return dt.isoformat()
    return str(dt)

def get_all_regions():
    ec2 = boto3.client("ec2")
    resp = ec2.describe_regions(AllRegions=False)
    return [r["RegionName"] for r in resp.get("Regions", [])]

def safe_client(service, region=None):
    try:
        if region:
            return boto3.client(service, region_name=region)
        return boto3.client(service)
    except Exception:
        return None

def get_cost_for_identifier(ce_client, identifier, start, end):
    try:
        resp = ce_client.get_cost_and_usage(
            TimePeriod={"Start": start, "End": end},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
            Filter={
                "Dimensions": {
                    "Key": "RESOURCE_ID",
                    "Values": [identifier],
                }
            },
        )
        total = 0.0
        for r in resp.get("ResultsByTime", []):
            if r.get("Groups"):
                for g in r["Groups"]:
                    for _, val in g.get("Metrics", {}).items():
                        total += float(val.get("Amount", 0.0))
            else:
                total += float(r["Total"]["UnblendedCost"]["Amount"])
        return total
    except Exception:
        return None

def add_row(rows, **r):
    rows.append({
        "Service": r.get("service", ""),
        "Name/Identifier": r.get("name", ""),
        "ARN/ID": r.get("arn", ""),
        "Region": r.get("region", ""),
        "CreationTime": iso_or_none(r.get("created")),
        "Status": r.get("status", ""),
        "LikelyBillable": r.get("billable", ""),
        "RecentCost30dUSD": f"{r.get('cost'):.4f}" if isinstance(r.get("cost"), float) else (str(r.get("cost")) if r.get("cost") is not None else ""),
    })

# --- HANDLERS ---
def handle_s3(rows, ce_client, start, end, account_id, include_cost):
    s3 = safe_client("s3")
    if not s3:
        return
    try:
        for b in s3.list_buckets().get("Buckets", []):
            name = b["Name"]
            created = b.get("CreationDate")
            # location
            region = "us-east-1"
            try:
                loc = s3.get_bucket_location(Bucket=name).get("LocationConstraint")
                if loc:
                    region = loc if loc != "US" else "us-east-1"
            except Exception:
                pass
            arn = f"arn:aws:s3:::{name}"
            billable = "yes"
            cost = get_cost_for_identifier(ce_client, name, start, end) if include_cost else None
            add_row(rows,
                    service="S3 Bucket",
                    name=name,
                    arn=arn,
                    region=region,
                    created=created,
                    status="exists",
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_ec2(rows, ce_client, start, end, account_id, region, include_cost):
    ec2 = safe_client("ec2", region=region)
    if not ec2:
        return
    # Instances
    try:
        for page in ec2.get_paginator("describe_instances").paginate():
            for res in page.get("Reservations", []):
                for inst in res.get("Instances", []):
                    iid = inst.get("InstanceId")
                    state = inst.get("State", {}).get("Name")
                    created = inst.get("LaunchTime")
                    arn = f"arn:aws:ec2:{region}:{account_id}:instance/{iid}"
                    billable = "yes" if state in ("running", "pending") else "maybe"
                    cost = get_cost_for_identifier(ce_client, iid, start, end) if include_cost else None
                    add_row(rows,
                            service="EC2 Instance",
                            name=iid,
                            arn=arn,
                            region=region,
                            created=created,
                            status=state,
                            billable=billable,
                            cost=cost)
    except Exception:
        pass

def handle_ebs(rows, ce_client, start, end, account_id, region, include_cost):
    ec2 = safe_client("ec2", region=region)
    if not ec2:
        return
    try:
        for vol in ec2.describe_volumes(Filters=[{"Name": "status", "Values": ["in-use", "available"]}]).get("Volumes", []):
            vid = vol.get("VolumeId")
            state = vol.get("State")
            created = vol.get("CreateTime")
            arn = f"arn:aws:ec2:{region}:{account_id}:volume/{vid}"
            billable = "yes" if state == "in-use" else "maybe"
            cost = get_cost_for_identifier(ce_client, vid, start, end) if include_cost else None
            add_row(rows,
                    service="EBS Volume",
                    name=vid,
                    arn=arn,
                    region=region,
                    created=created,
                    status=state,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_elastic_ip(rows, ce_client, start, end, account_id, region, include_cost):
    ec2 = safe_client("ec2", region=region)
    if not ec2:
        return
    try:
        for addr in ec2.describe_addresses().get("Addresses", []):
            allocation_id = addr.get("AllocationId") or addr.get("PublicIp")
            assoc = addr.get("AssociationId")
            arn = f"arn:aws:ec2:{region}:{account_id}:eip/{allocation_id}"
            billable = "yes" if not assoc else "maybe"
            status = "associated" if assoc else "unassociated"
            cost = get_cost_for_identifier(ce_client, allocation_id, start, end) if include_cost else None
            add_row(rows,
                    service="Elastic IP",
                    name=allocation_id,
                    arn=arn,
                    region=region,
                    created=None,
                    status=status,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_load_balancer(rows, ce_client, start, end, account_id, region, include_cost):
    elbv2 = safe_client("elbv2", region=region)
    if not elbv2:
        return
    try:
        for lb in elbv2.describe_load_balancers().get("LoadBalancers", []):
            name = lb.get("LoadBalancerName")
            arn = lb.get("LoadBalancerArn")
            created = lb.get("CreatedTime")
            state = lb.get("State", {}).get("Code")
            billable = "yes" if state == "active" else "maybe"
            cost = get_cost_for_identifier(ce_client, name, start, end) if include_cost else None
            add_row(rows,
                    service="Load Balancer",
                    name=name,
                    arn=arn,
                    region=region,
                    created=created,
                    status=state,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_rds(rows, ce_client, start, end, account_id, region, include_cost):
    rds = safe_client("rds", region=region)
    if not rds:
        return
    try:
        for db in rds.describe_db_instances().get("DBInstances", []):
            identifier = db.get("DBInstanceIdentifier")
            arn = db.get("DBInstanceArn")
            created = db.get("InstanceCreateTime")
            status = db.get("DBInstanceStatus")
            billable = "yes" if status not in ("stopped",) else "maybe"
            cost = get_cost_for_identifier(ce_client, identifier, start, end) if include_cost else None
            add_row(rows,
                    service="RDS Instance",
                    name=identifier,
                    arn=arn,
                    region=region,
                    created=created,
                    status=status,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_eks(rows, ce_client, start, end, account_id, region, include_cost):
    eks = safe_client("eks", region=region)
    if not eks:
        return
    try:
        for cname in eks.list_clusters().get("clusters", []):
            detail = eks.describe_cluster(name=cname).get("cluster", {})
            arn = detail.get("arn")
            created = detail.get("createdAt")
            status = detail.get("status")
            billable = "yes" if status in ("ACTIVE",) else "maybe"
            cost = get_cost_for_identifier(ce_client, cname, start, end) if include_cost else None
            add_row(rows,
                    service="EKS Cluster",
                    name=cname,
                    arn=arn,
                    region=region,
                    created=created,
                    status=status,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_ecs(rows, ce_client, start, end, account_id, region, include_cost):
    ecs = safe_client("ecs", region=region)
    if not ecs:
        return
    try:
        for carc in ecs.list_clusters().get("clusterArns", []):
            cname = carc.split("/")[-1]
            add_row(rows,
                    service="ECS Cluster",
                    name=cname,
                    arn=carc,
                    region=region,
                    created=None,
                    status="active",
                    billable="yes",
                    cost=get_cost_for_identifier(ce_client, cname, start, end) if include_cost else None)
            # Services
            try:
                for sarn in ecs.list_services(cluster=carc).get("serviceArns", []):
                    sname = sarn.split("/")[-1]
                    desc = ecs.describe_services(cluster=carc, services=[sarn]).get("services", [])
                    status = desc[0].get("status") if desc else ""
                    add_row(rows,
                            service="ECS Service",
                            name=f"{cname}/{sname}",
                            arn=sarn,
                            region=region,
                            created=None,
                            status=status,
                            billable="yes",
                            cost=get_cost_for_identifier(ce_client, sname, start, end) if include_cost else None)
            except Exception:
                pass
            # Tasks
            try:
                for tart in ecs.list_tasks(cluster=carc).get("taskArns", []):
                    tname = tart.split("/")[-1]
                    add_row(rows,
                            service="ECS Task",
                            name=f"{cname}/{tname}",
                            arn=tart,
                            region=region,
                            created=None,
                            status="running",
                            billable="yes",
                            cost=None)
            except Exception:
                pass
    except Exception:
        pass

def handle_ecr(rows, ce_client, start, end, account_id, region, include_cost):
    ecr = safe_client("ecr", region=region)
    if not ecr:
        return
    try:
        for repo in ecr.describe_repositories().get("repositories", []):
            name = repo.get("repositoryName")
            arn = repo.get("repositoryArn")
            created = repo.get("createdAt")
            billable = "yes"
            cost = get_cost_for_identifier(ce_client, name, start, end) if include_cost else None
            add_row(rows,
                    service="ECR Repository",
                    name=name,
                    arn=arn,
                    region=region,
                    created=created,
                    status="exists",
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_dynamodb(rows, ce_client, start, end, account_id, region, include_cost):
    ddb = safe_client("dynamodb", region=region)
    if not ddb:
        return
    try:
        for t in ddb.list_tables().get("TableNames", []):
            desc = ddb.describe_table(TableName=t).get("Table", {})
            arn = desc.get("TableArn")
            created = desc.get("CreationDateTime")
            status = desc.get("TableStatus")
            billable = "yes"
            cost = get_cost_for_identifier(ce_client, t, start, end) if include_cost else None
            add_row(rows,
                    service="DynamoDB Table",
                    name=t,
                    arn=arn,
                    region=region,
                    created=created,
                    status=status,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_lambda(rows, ce_client, start, end, account_id, region, include_cost):
    lam = safe_client("lambda", region=region)
    if not lam:
        return
    try:
        for f in lam.list_functions().get("Functions", []):
            name = f.get("FunctionName")
            arn = f.get("FunctionArn")
            last_mod = f.get("LastModified")
            billable = "maybe"
            cost = get_cost_for_identifier(ce_client, name, start, end) if include_cost else None
            add_row(rows,
                    service="Lambda Function",
                    name=name,
                    arn=arn,
                    region=region,
                    created=last_mod,
                    status="active",
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_secretsmanager(rows, ce_client, start, end, account_id, region, include_cost):
    sm = safe_client("secretsmanager", region=region)
    if not sm:
        return
    try:
        for page in sm.get_paginator("list_secrets").paginate():
            for secret in page.get("SecretList", []):
                name = secret.get("Name")
                arn = secret.get("ARN")
                created = secret.get("CreatedDate")
                status = "enabled" if not secret.get("DeletedDate") else "scheduled for deletion"
                billable = "yes"
                cost = get_cost_for_identifier(ce_client, name, start, end) if include_cost else None
                add_row(rows,
                        service="Secrets Manager Secret",
                        name=name,
                        arn=arn,
                        region=region,
                        created=created,
                        status=status,
                        billable=billable,
                        cost=cost)
    except Exception:
        pass

def handle_cloudfront(rows, ce_client, start, end, account_id, include_cost):
    cf = safe_client("cloudfront")
    if not cf:
        return
    try:
        for d in cf.list_distributions().get("DistributionList", {}).get("Items", []):
            id_ = d.get("Id")
            arn = f"arn:aws:cloudfront::{account_id}:distribution/{id_}"
            status = d.get("Status")
            billable = "yes" if status == "Deployed" else "maybe"
            cost = get_cost_for_identifier(ce_client, id_, start, end) if include_cost else None
            add_row(rows,
                    service="CloudFront Distribution",
                    name=id_,
                    arn=arn,
                    region="global",
                    created=None,
                    status=status,
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_route53(rows, ce_client, start, end, account_id, include_cost):
    r53 = safe_client("route53")
    if not r53:
        return
    try:
        for z in r53.list_hosted_zones().get("HostedZones", []):
            name = z.get("Name")
            zid = z.get("Id").split("/")[-1]
            arn = f"arn:aws:route53:::hostedzone/{zid}"
            billable = "yes"
            cost = get_cost_for_identifier(ce_client, zid, start, end) if include_cost else None
            add_row(rows,
                    service="Route53 HostedZone",
                    name=name,
                    arn=arn,
                    region="global",
                    created=None,
                    status="exists",
                    billable=billable,
                    cost=cost)
    except Exception:
        pass

def handle_iam(rows, ce_client, start, end, account_id, include_cost):
    iam = safe_client("iam")
    if not iam:
        return
    try:
        for u in iam.list_users().get("Users", []):
            add_row(rows,
                    service="IAM User",
                    name=u.get("UserName"),
                    arn=u.get("Arn"),
                    region="global",
                    created=u.get("CreateDate"),
                    status="active",
                    billable="no",
                    cost=0.0 if include_cost else None)
        for r in iam.list_roles().get("Roles", []):
            add_row(rows,
                    service="IAM Role",
                    name=r.get("RoleName"),
                    arn=r.get("Arn"),
                    region="global",
                    created=r.get("CreateDate"),
                    status="active",
                    billable="no",
                    cost=0.0 if include_cost else None)
    except Exception:
        pass

# -- DISPATCH MAP --
SERVICE_HANDLERS_GLOBAL = {
    "s3": handle_s3,
    "cloudfront": handle_cloudfront,
    "route53": handle_route53,
    "iam": handle_iam,
}

SERVICE_HANDLERS_REGIONAL = {
    "ec2": handle_ec2,
    "ebs": handle_ebs,
    "elastic_ip": handle_elastic_ip,
    "load_balancer": handle_load_balancer,
    "rds": handle_rds,
    "eks": handle_eks,
    "ecs": handle_ecs,
    "ecr": handle_ecr,
    "dynamodb": handle_dynamodb,
    "lambda": handle_lambda,
    "secretsmanager": handle_secretsmanager,
}

def main(output_csv, include_cost):
    session = boto3.Session()
    account_id = session.client("sts").get_caller_identity().get("Account")
    now = datetime.datetime.utcnow()
    start = (now - datetime.timedelta(days=30)).date().isoformat()
    end = now.date().isoformat()
    ce_client = session.client("ce", region_name="us-east-1") if include_cost else None

    rows = []

    # Global services
    for svc in ENABLED_SERVICES:
        if svc in SERVICE_HANDLERS_GLOBAL:
            SERVICE_HANDLERS_GLOBAL[svc](rows, ce_client, start, end, account_id, include_cost)

    # Regional scan
    regions = get_all_regions()
    for region in regions:
        for svc in ENABLED_SERVICES:
            if svc in SERVICE_HANDLERS_REGIONAL:
                SERVICE_HANDLERS_REGIONAL[svc](
                    rows, ce_client, start, end, account_id, region, include_cost
                )

    # Write CSV
    fieldnames = ["Service", "Name/Identifier", "ARN/ID", "Region", "CreationTime", "Status", "LikelyBillable", "RecentCost30dUSD"]
    with open(output_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in rows:
            writer.writerow(r)

    print(f"Scan complete: {len(rows)} entries. Output at {output_csv}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Modular AWS resource + cost audit.")
    parser.add_argument("--output", "-o", default="aws_cost_audit.csv", help="CSV output file")
    parser.add_argument("--cost", action="store_true", help="Enable Cost Explorer lookups")
    args = parser.parse_args()
    main(args.output, args.cost)
