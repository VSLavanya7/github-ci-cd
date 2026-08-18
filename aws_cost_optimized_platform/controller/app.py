import os
import time
import boto3

from flask import Flask, jsonify

app = Flask(__name__)

ASG_NAME = os.environ["ASG_NAME"]
TARGET_GROUP_ARN = os.environ["TARGET_GROUP_ARN"]

autoscaling = boto3.client("autoscaling")
elbv2 = boto3.client("elbv2")


def get_asg():

    response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[ASG_NAME]
    )

    groups = response.get("AutoScalingGroups", [])

    if not groups:
        raise Exception("ASG not found")

    return groups[0]


def wake_application():

    group = get_asg()

    desired = group["DesiredCapacity"]

    if desired == 0:

        autoscaling.set_desired_capacity(
            AutoScalingGroupName=ASG_NAME,
            DesiredCapacity=1,
            HonorCooldown=False
        )

        return True

    return False


def application_healthy():

    response = elbv2.describe_target_health(
        TargetGroupArn=TARGET_GROUP_ARN
    )

    targets = response.get("TargetHealthDescriptions", [])

    for target in targets:

        state = target["TargetHealth"]["State"]

        if state == "healthy":
            return True

    return False


@app.get("/")

def index():

    wake_application()

    return jsonify({
        "status": "starting",
        "message": "Application is starting. Please wait."
    })


@app.get("/health")

def health():

    return jsonify({
        "status": "healthy"
    })


@app.get("/ready")

def ready():

    return jsonify({
        "application_ready": application_healthy()
    })