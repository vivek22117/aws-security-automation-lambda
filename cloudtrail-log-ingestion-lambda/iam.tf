resource "aws_iam_role" "cloudtrail_monitoring_lambda_role" {
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

resource "aws_iam_policy" "cloudtrail_monitoring_lambda_policy" {
  name        = var.lambda_policy
  description = "Policy to have delete access"
  path        = "/"
  policy      = data.template_file.lambda_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "policy_role_attach" {
  policy_arn = aws_iam_policy.cloudtrail_monitoring_lambda_policy.arn
  role       = aws_iam_role.cloudtrail_monitoring_lambda_role.name
}

