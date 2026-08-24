import os
import boto3
import json

asg_name = os.environ["ASG_NAME"]
target_group_arn = os.environ["TARGET_GROUP_ARN"]

autoscaling = boto3.client("autoscaling")
elbv2 = boto3.client("elbv2")

def get_asg():
    resp = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )
    return resp["AutoScalingGroups"][0]

def has_healthy_target():
    resp = elbv2.describe_target_health(TargetGroupArn=target_group_arn)
    for t in resp.get("TargetHealthDescriptions", []):
        if t["TargetHealth"]["State"] == "healthy":
            return True
    return False

def lambda_handler(event, context):
    group = get_asg()
    desired = group["DesiredCapacity"]

    if desired == 0:
        autoscaling.set_desired_capacity(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=1,
            HonorCooldown=False
        )

    if has_healthy_target():
        body = {"status": "ready", "message": "Application is ready."}
        status = 200
    else:
        body = {"status": "starting", "message": "Application is starting up. This may take 1–2 minutes."}
        status = 202

    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }