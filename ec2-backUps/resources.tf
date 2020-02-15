data "archive_file" "ec2-backup" {
  //source_content          = "${data.template_file.lambda_source.rendered}"

  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ec2-backup.zip"
}


resource "aws_lambda_function" "ec2_backup" {
  description = "Lambda function to create Backup of EC2 Backup"

  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  filename         = data.archive_file.ec2-backup.output_path
  source_code_hash = data.archive_file.ec2-backup.output_base64sha256
  role             = aws_iam_role.ec2_backup_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = var.lambda_runtime

  tags = merge(local.common_tags, map("Name", "${var.environment}-ec2-backup"))

}


resource "aws_lambda_permission" "cloudwatch_trigger" {

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_backup.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "cw_event_rule" {
  name                = "${aws_lambda_function.ec2_backup.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = var.schedule_expression

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.cw_event_rule.name
  arn  = aws_lambda_function.ec2_backup.arn
}