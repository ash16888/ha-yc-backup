import boto3
import requests
import json
from datetime import datetime, timedelta, timezone
import os
# Set up S3 client
session = boto3.session.Session()
s3 = session.client(
    service_name='s3',
    endpoint_url='https://storage.yandexcloud.net'
)

# Set up Telegram bot
telegram_token =  os.environ.get("BOT_TOKEN")
telegram_chat_id =  os.environ.get("CHAT_ID")

# Set up date and time variables
# Set up date and time variables
now = datetime.now(timezone.utc)
one_day_ago = now - timedelta(days=1)
one_day_ago = one_day_ago.replace(tzinfo=None)
# Get list of objects in S3 bucket
bucket_name =  os.environ.get("BUCKET")
objects = s3.list_objects_v2(Bucket=bucket_name)['Contents']

# Check if any objects were uploaded in the last 24 hours
new_files_exist = False
for obj in objects:
    last_modified = obj['LastModified'].replace(tzinfo=None)
    if last_modified > one_day_ago:
        new_files_exist = True
        break
# Send Telegram alert if no new files were uploaded
if not new_files_exist:
    message = 'No new files uploaded to S3 bucket {} in the last 24 hours.'.format(bucket_name)
    telegram_url = 'https://api.telegram.org/bot{}/sendMessage'.format(telegram_token)
    data = {'chat_id': telegram_chat_id, 'text': message}
    response = requests.post(telegram_url, data=json.dumps(data), headers={'Content-Type': 'application/json'})

def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello!',
    }
