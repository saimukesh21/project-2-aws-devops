import boto3
import os

ec2 = boto3.client("ec2")

INSTANCE_ID = os.environ["INSTANCE_ID"]


def lambda_handler(event, context):

    action = event.get("action", "stop")

    if action == "start":
        response = ec2.start_instances(
            InstanceIds=[INSTANCE_ID]
        )
        message = f"Started EC2 instance {INSTANCE_ID}"

    elif action == "stop":
        response = ec2.stop_instances(
            InstanceIds=[INSTANCE_ID]
        )
        message = f"Stopped EC2 instance {INSTANCE_ID}"

    else:
        raise ValueError("action must be 'start' or 'stop'")

    print(message)

    return {
        "statusCode": 200,
        "message": message,
        "response": response
    }
