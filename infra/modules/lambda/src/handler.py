import json
import os

def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from LocalStack Lambda!",
            "app": os.environ.get("APP_NAME", "unknown"),
            "event": event
        })
    }
