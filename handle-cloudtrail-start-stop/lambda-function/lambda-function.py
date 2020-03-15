import boto3

print('loading function.....')


def lambda_handler(event, context):

    try:
        client = boto3.client('cloudtrail')
        if event['detail']['eventName'] == 'StopLogging':
            client.start_logging(Name=event['detail']['requestParameters']['name'])
    except Exception as ex:
        print("Exception is {}.".format(ex))
