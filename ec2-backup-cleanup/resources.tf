##########################################################
# Adding the lambda archive to the defined bucket        #
##########################################################
resource "aws_s3_bucket_object" "ec2_snapshot_cleanup_package" {
  depends_on = [data.archive_file.ec2_snapshot_cleanup]

  bucket = data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_name
  key    = var.s3_lambda_bucket_key
  source = "${path.module}/lambda-function/ec2-backup-cleanup.zip"
  etag   = filemd5("${path.module}/lambda-function/ec2-backup-cleanup.zip")
}

data "archive_file" "ec2_snapshot_cleanup" {
  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ec2-backup-cleanup.zip"
}


resource "aws_lambda_function" "ec2_cleanup" {
  description = "Lambda function to cleanup Backup of EC2"

  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  s3_bucket = aws_s3_bucket_object.ec2_snapshot_cleanup_package.bucket
  s3_key    = aws_s3_bucket_object.ec2_snapshot_cleanup_package.key
  source_code_hash = data.archive_file.ec2_snapshot_cleanup.output_base64sha256

  role             = aws_iam_role.ec2_cleanup_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = var.lambda_runtime

  tags = merge(local.common_tags, map("Name", "${var.environment}-ec2-cleanup"))

}


resource "aws_lambda_permission" "cloudwatch_trigger" {
  //function_name = "${join("", concat(aws_lambda_function.ec2_start_stop.*.arn, aws_lambda_function.lambda_classic.*.arn))}"

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_cleanup.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "cw_event_rule" {
  name                = "${aws_lambda_function.ec2_cleanup.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = var.schedule_expression

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.cw_event_rule.name
  arn  = aws_lambda_function.ec2_cleanup.arn
}
