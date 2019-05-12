data "archive_file" "ec2-cleanup" {
  //source_content          = "${data.template_file.lambda_source.rendered}"

  type = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ec2-backup-cleanup.zip"
}


resource "aws_lambda_function" "ec2_cleanup" {
  description = "Lambda function to cleanup Backup of EC2"
  function_name = "ec2-backup-cleanup"
  handler = "lambda-function.lambda_handler"

  filename = "${data.archive_file.ec2-cleanup.output_path}"
  source_code_hash = "${data.archive_file.ec2-cleanup.output_base64sha256}"
  role = "${aws_iam_role.ec2_cleanup_role.arn}"

  memory_size = 128
  timeout = 90
  runtime = "python3.7"

  tags = "${merge(local.common_tags, map("Name", "${var.environment}-ec2-cleanup"))}"

}


resource "aws_lambda_permission" "cloudwatch_trigger" {
  //function_name = "${join("", concat(aws_lambda_function.ec2_start_stop.*.arn, aws_lambda_function.lambda_classic.*.arn))}"

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2_cleanup.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda" {
  name                = "${aws_lambda_function.ec2_cleanup.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = "${var.schedule_expression}"

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "target" {
  rule = "${aws_cloudwatch_event_rule.lambda.name}"
  arn  = "${aws_lambda_function.ec2_cleanup.arn}"
}