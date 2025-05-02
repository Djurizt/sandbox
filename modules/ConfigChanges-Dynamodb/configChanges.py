import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    detail = event.get("detail", {})
    resource_id = detail.get("configurationItem", {}).get("resourceId", "unknown")
    
    item = {
        "resourceId": resource_id,
        "resourceType": detail.get("configurationItem", {}).get("resourceType", "unknown"),
        "awsRegion": detail.get("awsRegion", "unknown"),
        "changeType": detail.get("messageType", "ConfigurationItemChangeNotification"),
        "timestamp": event.get("time", ""),
        "fullEvent": json.dumps(detail)
    }

    table.put_item(Item=item)
    return {"statusCode": 200, "body": "Success"}
