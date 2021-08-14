
lambda_func_name    = "EC2StartStopHandler"
lambda_handler      = "lambda-function.lambda_handler"
lambda_runtime      = "python3.8"
lambda_timeout      = 90
lambda_memory       = 256
schedule_expression = "rate(15 minutes)"

s3_lambda_bucket_key = "lambda/ec2-start-stop/ec2-backup-cleanup.zip"

lambda_role   = "EC2StartStopAccessRole"
lambda_policy = "EC2StartStopPermissionPolicy"
