
lambda_func_name    = "EC2DeregisterAMILambda"
lambda_handler      = "lambda-function.lambda_handler"
lambda_runtime      = "python3.8"
lambda_timeout      = 90
lambda_memory       = 256
schedule_expression = "rate(12 hours)"
s3_lambda_bucket_key = "lambda/deregister-amis/ami-deregister-lambda.zip"

lambda_role   = "EC2DeregisterAMILambdaAccessRole"
lambda_policy = "EC2DeregisterAMILambdaPermissionPolicy"
