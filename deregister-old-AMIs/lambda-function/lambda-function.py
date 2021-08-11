import datetime
import boto3
from dateutil.parser import parse
import logging

log = logging.getLogger()
log.setLevel(logging.DEBUG)


def days_old(date):
    parsed = parse(date).replace(tzinfo=None)
    diff = datetime.datetime.now() - parsed
    return diff.days


def lambda_handler(event, context):

    try:

        # Get list of regions
        ec2_client = boto3.client('ec2')
        regions = [region['RegionName'] for region in ec2_client.describe_regions()['Regions']]

        for region in regions:
            ec2 = boto3.client('ec2', region_name=region)
            print('Region: ', region)

            all_ami = ec2.describe_images(Owners=['self'])['Images']

            for ami in all_ami:
                creation_date = ami['CreationDate']
                age_days = days_old(creation_date)
                image_id = ami['ImageId']
                print('ImageId: {}, CreationDate: {} ({} days old)'.format(image_id, creation_date, age_days))

                if age_days >= 5:
                    print('Deleting imageId: ', image_id)
                    ec2.deregister_image(ImageId=image_id)
                    for ebs in ami['BlockDeviceMappings']:
                        log.debug(ebs)
                        if not (ebs.get('Ebs') is None):
                            ec2_client.delete_snapshot(Shapshot=ebs['Ebs']['SnapshotId'])
                            log.debug('Deleted...')
                else:
                    log.debug(ami['ImageId'] + " is not older than 5 days")

    except Exception as ex:
        log.error("Error occurred " + str(ex))
        raise Exception(ex)
