##########################################################
# Terraform resource for Lambda IAM role and policy      #
##########################################################
resource "aws_iam_role" "lambda_cloudwatch_role" {
  name = "LambdaAccessSparkCloudWatchLogsRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name = "LambdaAccessSparkCloudWatchLogsPolicy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda_cloudwatch_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_role_attach" {
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
  role = aws_iam_role.lambda_cloudwatch_role.name
}

