resource "aws_iam_role" "ami_deregister_role" {
  name = var.lambda_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ami_deregister_policy" {
  name        = var.lambda_policy
  description = "Policy to access EC2 AMIs"
  path        = "/"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeImages",
        "ec2:DescribeRegions",
        "ec2:DeregisterImage"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_role_attach" {
  policy_arn = aws_iam_policy.ami_deregister_policy.arn
  role       = aws_iam_role.ami_deregister_role.name
}

