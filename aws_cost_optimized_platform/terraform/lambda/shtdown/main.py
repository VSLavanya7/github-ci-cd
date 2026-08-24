import os
import boto3
from datetime import datetime, timedelta

asg_name = os.environ["ASG_NAME"]
metric_namespace = os.environ["METRIC_NAMESPACE"]
metric_name = os.environ["METRIC_NAME"]

cloudwatch = boto3.client("cloudwatch")
autoscaling = boto3.client("autoscaling")

def get_activity_last_hour():
    end = datetime.utcnow()
    start = end - timedelta(hours=1)

    resp = cloudwatch.get_metric_statistics(
        Namespace=metric_namespace,
        MetricName=metric_name,
        StartTime=start,
        EndTime=end,
        Period=300,
        Statistics=["Sum"]
    )

    total = 0
    for dp in resp["Datapoints"]:
        total += dp["Sum"]
    return total

def get_asg():
    resp = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )
    return resp["AutoScalingGroups"][0]

def lambda_handler(event, context):
    activity = get_activity_last_hour()
    group = get_asg()
    desired = group["DesiredCapacity"]

    if activity == 0 and desired > 0:
        # Optionally track "idle since" in a parameter/DynamoDB if you want 1‑hour grace.
        # For simple version: if no activity, scale down immediately after 17:00.
        autoscaling.set_desired_capacity(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=0,
            HonorCooldown=False
        )

    return {
        "statusCode": 200,
        "body": f"Activity={activity}, desired set to 0 if idle."
    }