data "aws_iam_policy_document" "lambda_cloudwatch_policy_doc" {
  statement {
    actions = [
      "logs:Describe*",
      "logs:Get*",
      "logs:FilterLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.emr_cluster_logGroup.arn
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}