# CLOUD FUNCTION CHECK S3

## Installation

Follow these steps to create cloud function in Yandex Cloud:

1. Create function with instructions https://cloud.yandex.ru/docs/functions/operations/function/function-create and name it check-s3
2. Select runtime Python 3.11
3. Upload cloud-function.zip from this repository entrypoint index.py
4. ADD environment variables
  AWS_DEFAULT_REGION ru-central1
  AWS_ACCESS_KEY_ID your key https://cloud.yandex.com/en-ru/docs/iam/concepts/authorization/access-key
  AWS_SECRET_ACCESS_KEY your key https://cloud.yandex.com/en-ru/docs/iam/concepts/authorization/access-key
  BUCKET your bucket https://cloud.yandex.com/en-ru/docs/storage/operations/buckets/create
  BOT_TOKEN telegram bot token create with Bot Father
  CHAT_ID your chat id

6. Create function
7. Create trigger 
  Name ha-check-backup
  Type timer
  Cron expression 00 07 ? * * * ### every day in 7 a.m. UTC
  Function check-s3
  Service account 
    Create new
      Name check-s3
      Roles serverless.functions.invoker


## Checking
Go to the function Testing Run test, if everything OK you receive alert in telegram, then upload file in your bucket and run test again, and no alerts should be.
