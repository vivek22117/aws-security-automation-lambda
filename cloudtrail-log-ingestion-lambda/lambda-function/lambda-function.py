import logging
import boto3
import json
import gzip
import traceback
import six.moves.urllib as urllib  # for for Python 2.7 urllib.unquote_plus
from botocore.vendored import requests
from io import BytesIO, BufferedReader
import re

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# list of supported aws services
list_supported_cw_services = {'ec2', 'ecs', 'rds', 'elasticache'}

# include event list
include_json = {}
include_json['ec2'] = ['StartInstances', 'RunInstances', 'TerminateInstances', 'StopInstances']
include_json['ecs'] = ['CreateService', 'RunTask', 'DeleteCluster']
include_json['rds'] = ['CreateDBInstance', 'StartDBInstance', 'StopDBInstance', 'RebootDBInstance', 'DeleteDBInstance',
                       'ModifyDBInstance']
include_json['elasticache'] = ['CreateCacheCluster', 'ModifyCacheCluster']

# exclude event list
exclude_json = {}
exclude_json['ec2'] = None
exclude_json['ecs'] = None
exclude_json['rds'] = None
exclude_json['elasticache'] = None

s3_client = boto3.client('S3')


# main function
def lambda_handler(event, context):
    response = ''

    if event:
        # Get object and print the event
        bucket = event["Records"][0]["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(event["Records"][0]["s3"]["object"]["key"])
        logger.info('CloudTrail event: ' + str(bucket) + '::' + str(key))

        # Extract the s3 object
        event_body = s3_client.get_object(Bucket=bucket, Key=key)
        body = event_body["Body"]
        data = body.read()

        if key[-3:] == ".gz":
            with gzip.GzipFile(fileobj=BytesIO(data)) as decompress_stream:
                data = b"".join(BufferedReader(decompress_stream))

        log_result = []
        event_result = []

        try:
            json_data = json.loads(data)

            if 'Records' in json_data:
                for record in json_data['Records']:
                    logger.info('Event record: ' + str(record))
                    logger.debug(record)
            if not event_result:
                logger.info('No event found!')
        except Exception as e:
            logger.error('Something went wrong: ' + str(e))
            traceback.print_exc()
            return False
        finally:
            if event_result:
                logger.info("Execution completed with " + response)



