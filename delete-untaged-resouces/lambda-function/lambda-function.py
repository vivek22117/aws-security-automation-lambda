import boto3
import json

ec2 = boto3.resource('ec2')


def lambda_handler(event, context):
    print('Event: ' + str(event))
    print(json.dumps(event))

    # Contain all the identifiers of EC2 resources
    # IDs could be EC2 instance, EBS, AMI , EBS Snapshots
    resource_ids = []

    try:
        region = event['region']
        detail = event['detail']
        event_name = detail['eventName']
        arn = detail['userIdentity']['arn']
        principal = detail['userIdentity']['principalId']
        user_type = detail['userIdentity']['type']

        if user_type == 'IAMUser':
            user = detail['userIdentity']['userName']
        else:
            # Assumed role or federated id
            user = principal.split(": ")[1]
            print("Non IAM user is: ", user)

        print('arn: ' + arn)
        print('principalId: ' + principal)
        print('detail: ' + str(detail))
        print('event name: ' + event_name)
        print('region: ' + region)

        if not detail['responseElements']:
            print('No response elements found')
            if detail['errorCode']:
                print('errorCode: ' + detail['errorCode'])
            if detail['errorMessage']:
                print('error message: ' + detail['errorMessage'])
            return False

        if event_name == 'CreateVolume':
            resource_ids.append(detail['responseElements']['volumeId'])
            print(resource_ids)

        elif event_name == 'RunInstances':
            items = detail['responseElements']['instancesSet']['items']
            for item in items:
                resource_ids.append(item['instanceId'])
            print(resource_ids)
            print('number of instances: ' + str(len(resource_ids)))

            ec2_list = ec2.instances.filter(InstancesIds=resource_ids)

            # loop through the instances
            for instance in ec2_list:
                for vol in instance.volume.all():
                    resource_ids.append(vol.id)
                for eni in instance.network_interfaces:
                    resource_ids.append(eni.id)

        elif event_name == 'CreateImage':
            resource_ids.append(detail['responseElements']['imageId'])
            print(resource_ids)

        elif event_name == 'CreateSnapshot':
            resource_ids.append(detail['responseElements']['snapshotId'])
            print(resource_ids)
        else:
            print('Not support action')
    except Exception as e:
        print("Exception is {}.".format(e))







