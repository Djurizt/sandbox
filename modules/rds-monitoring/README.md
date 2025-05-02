# RDS Monitoring Stack with Prometheus and Grafana

This stack provides real-time visibility into Amazon RDS metrics using the following components:

- Enhanced Monitoring and Performance Insights on RDS
- Prometheus for scraping CloudWatch metrics
- Grafana for visualization and alerting

---

## 📁 Folder Structure

```
.
├── prometheus-grafana-cloudwatch/
│   ├── .env
│   ├── config.yml
│   ├── docker-compose.yml
│   ├── prometheus.yml
│   ├── dashboards/
│   │   └── rds_monitoring.json
│   ├── provisioning/
│   │   ├── alerting/
│   │   │   └── rds-alerts.yml
│   │   ├── dashboards/
│   │   │   └── rds-dashboard.yml
│   │   └── datasources/
│   │       └── prometheus.yml
│
├── rds-monitoring-terraform/
│   ├── clean.sh
│   ├── main.tf
│   ├── terraform.tfvars
│   └── variables.tf
│
└── README.md
```

---

## 🚀 Setup Instructions

### A. Enable RDS Monitoring and Metrics Collection with Terraform

This Terraform configuration will:
- Create an IAM role for RDS Enhanced Monitoring.
- Attach the required AWS-managed policy.
- Use the AWS CLI to enable Enhanced Monitoring and Performance Insights.
- Leave all other configurations of the existing RDS instance unchanged.

#### Prerequisites
- AWS CLI installed and configured with sufficient permissions to update RDS.
- Terraform installed.

#### 1. Configure your RDS parameters

Update `terraform.tfvars` with your region and database identifier:

```hcl
aaws_region    = "<your-region>"
db_identifier = "<your-database-name>"
```
#### 2. Initialize and apply the Terraform configuration
```bash
terraform init
terraform apply
```

#### 3. Verify Enhanced Monitoring is enabled

Run the following AWS CLI command:
```bash
aws rds describe-db-instances \
  --db-instance-identifier <your-database-name> \
  --query "DBInstances[0].MonitoringInterval"
```

If the result is 0, Enhanced Monitoring is disabled.

If it returns 1, 5, 10, 15, etc., Enhanced Monitoring is enabled with the interval shown in seconds.

### B. Docker setup for Prometheus and Grafana
This setup will:
- Deploy Prometheus and Grafana
- Configure Prometheus to scrape RDS metrics
- Add Prometheus as a data source in Grafana 
- Create a Grafana dashboard to visualize metrics 
- Provision alerts for abnormal connection patterns (e.g., connections > 100)

#### Prerequisites
- Docker and Docker Compose installed
- AWS credentials with cloudwatch:GetMetricData permissions
- RDS Enhanced Monitoring and Performance Insights enabled (see part A)

#### 1. Configure Environment
Edit .env with your credentials and Grafana admin login:
```hcl
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin
AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
```
#### 2. Configure CloudWatch Exporter

- Edit config.yml to include the RDS metrics you want (e.g. DatabaseConnections, CPUUtilization, FreeableMemory, etc.)

- Make sure to replace database-1 with your actual RDS instance identifier.

#### 3. Launch the stack
```bash
docker-compose up -d --build
```
### 4. Access Grafana

Navigate to: http://localhost:3000

Login with the credentials from .env


### 5. Verify Dashboard

Confirm RDS metrics appear on the preloaded "RDS Monitoring" dashboard

### 6. Test Alerts

- Review provisioned alert rules under Alerting > Alert Rules
- Confirm that the rule for High RDS Connection Count is listed and functional
- You can simulate alerting by lowering the threshold or manipulating data




