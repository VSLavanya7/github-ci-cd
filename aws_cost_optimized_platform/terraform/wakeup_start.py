import os
import boto3

autoscaling = boto3.client("autoscaling")
dynamodb = boto3.resource("dynamodb")

ASG_NAME = os.environ["ASG_NAME"]
STATE_TABLE = os.environ["STATE_TABLE"]

table = dynamodb.Table(STATE_TABLE)


def response(status, message):
    return {
        "statusCode": status,
        "statusDescription": f"{status} Accepted",
        "isBase64Encoded": False,
        "headers": {
            "Content-Type": "text/plain",
            "Cache-Control": "no-store"
        },
        "body": message
    }


def lambda_handler(event, context):
    groups = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[ASG_NAME]
    )["AutoScalingGroups"]

    if not groups:
        return response(500, "ASG not found")

    group = groups[0]
    desired = group["DesiredCapacity"]

    if desired == 0:
        autoscaling.set_desired_capacity(
            AutoScalingGroupName=ASG_NAME,
            DesiredCapacity=1,
            HonorCooldown=False
        )

        table.update_item(
            Key={"application": "main"},
            UpdateExpression="SET #s = :s",
            ExpressionAttributeNames={"#s": "state"},
            ExpressionAttributeValues={":s": "STARTING"}
        )

        return response(
            202,
            "Application is starting. Wait and refresh."
        )

    return response(200, "Application is already starting or running.")
Create infra/lambda_src/wakeup_stop.py:
python
import os
import time
from datetime import datetime
from zoneinfo import ZoneInfo

import boto3

autoscaling = boto3.client("autoscaling")
dynamodb = boto3.resource("dynamodb")

ASG_NAME = os.environ["ASG_NAME"]
STATE_TABLE = os.environ["STATE_TABLE"]
IDLE_MINUTES = int(os.environ.get("IDLE_MINUTES", "60"))
SHUTDOWN_HOUR = int(os.environ.get("SHUTDOWN_HOUR", "17"))

table = dynamodb.Table(STATE_TABLE)


def lambda_handler(event, context):
    now_epoch = int(time.time())
    now_local = datetime.now(ZoneInfo("Europe/Oslo"))

    item = table.get_item(
        Key={"application": "main"}
    ).get("Item", {})

    last_activity = int(item.get("lastActivityEpoch", 0))

    after_shutdown = now_local.hour >= SHUTDOWN_HOUR
    idle = (
        last_activity > 0
        and now_epoch - last_activity >= IDLE_MINUTES * 60
    )

    if after_shutdown or idle:
        autoscaling.set_desired_capacity(
            AutoScalingGroupName=ASG_NAME,
            DesiredCapacity=0,
            HonorCooldown=False
        )

        table.update_item(
            Key={"application": "main"},
            UpdateExpression="SET #s = :s",
            ExpressionAttributeNames={"#s": "state"},
            ExpressionAttributeValues={":s": "SLEEPING"}
        )

        return {
            "statusCode": 200,
            "body": "Application scaled to zero"
        }

    return {
        "statusCode": 200,
        "body": "Application remains active"
    }
