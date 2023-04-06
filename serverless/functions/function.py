import json
import boto3
import os
from datetime import datetime
from base64 import b64decode
import json
import dateutil.tz

client = boto3.client('sqs')

def send_handler(event, context):
    if event:
        body = {}
        if "body" in event: 
            if ("isBase64Encoded" in event and event["isBase64Encoded"] == True):
                body = json.loads(b64decode(event["body"]).decode("ASCII"))
            else:
                body = json.loads(event["body"])
        
        body["timestamp"] = datetime.now(tz=dateutil.tz.gettz("Europe/Stockholm")).strftime("%Y-%m-%d %H:%M:%S")

        response = client.send_message(
            QueueUrl=os.environ["SQS_URL"],
            MessageBody=json.dumps(body)
        )

        return {
            "statusCode": 200,
            "body": "Message with ID " + response["MessageId"] + " sent.\n"
        }

def receive_handler(event, context):
    if event:
        batch_item_failures = []
        sqs_batch_response = {}
     
        for record in event["Records"]:
            try:
                body = json.loads(record["body"])
                body["message_id"] = record["messageId"]
                print(json.dumps(body))
            except Exception as e:
                batch_item_failures.append({"itemIdentifier": record["messageId"]})
        
        sqs_batch_response["batchItemFailures"] = batch_item_failures
        return sqs_batch_response
