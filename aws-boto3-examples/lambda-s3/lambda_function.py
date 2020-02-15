# noinspection PyInterpreter
import boto3
import json


def lambda_client():
    aws_lambda = boto3.client('lambda', region='us-east-1')
    ":type : pyboto3.lambda"
    return aws_lambda


def iam_client():
    aws_iam = boto3.client('iam')
    ":type : pyboto3.iam"
    return aws_iam


def create_lambda_access_policy():
    s3_access_policy_doc = {
        "Version": "2012-12-17",
        "Statement": [
            {
                "Action": [
                    "s3:*",
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Effect": "Allow",
                "Resource": "*"
            }
        ]
    }

    return iam_client().create_policy(
        Polc
    )


