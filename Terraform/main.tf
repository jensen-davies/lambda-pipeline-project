terraform {
    required_providers  {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

resource "aws_s3_bucket" "input_bucket" {
    bucket = var.s3_bucket_name

    force_destroy = true # Force destroy the bucket even if it's not empty.
}

resource "aws_dynamodb_table" "result_table" {
    name            = var.dynamodb_table_name
    hash_key        = "FileId" # Primary key for the table
    billing_mode    = "PAY_PER_REQUEST" # Charge for reads and writes.

    attribute {
        name = "FileId"
        type = "S" # Defines an attribute 'FileId of type string.
    }
}

resource "aws_iam_role" "lambda_execution_role" {
    name ="lambda_execution_role" # Name of the IAM role.

    assume_role_policy = jsonencode({ # Policy that allows Lambda to assume this role.
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_policy" "lambda_policy" { 
    name        = "lambda_policy" # Name of the policy.
    description = "IAM policy for logging from a Lambda function"

    policy = jsonencode({ # Policy document that specifies allowed actions.
        Version = "2012-10-17"
        Statement = [{
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "dynamodb:PutItem",
                "s3:GetObject",
            ]
            Effect  = "Allow"
            Resource = "*" # Applies to all resources.
        }]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role        = aws_iam_role.lambda_execution_role.name # Role to attach the policy to.
    policy_arn  = aws_iam_policy.lambda_policy.arn # The ARN of the policy to attach.
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = "${path.module}/../Lambda/lambda_function.py" # The file to zip.
    output_path = "${path.module}/../Lambda/lambda_function.zip" # The name of the output file.
}

resource "aws_lambda_function" "data_processor" {
    function_name = var.lambda_function_name

    filename    = data.archive_file.lambda_zip.output_path # The name of the output file.
    handler     = var.lambda_handler # The function within lambda_function.py that Lambda calls.
    runtime     = var.lambda_runtime # Runtime for the Lambda function.
    role        = aws_iam_role.lambda_execution_role.arn # IAM role that Lambda assumes.

    source_code_hash = filebase64sha256("${path.module}/../Lambda/lambda_function.py") # Ensures that updates to the Lambda code trigger redeployment.
}

resource "aws_lambda_permission" "allow_bucket" {
    statement_id    = "AllowExecutionFromS3Bucket"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.data_processor.function_name
    principal       = "s3.amazonaws.com"
    source_arn      = aws_s3_bucket.input_bucket.arn # Specifies the S3 bucket as the source.
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = aws_s3_bucket.input_bucket.id # The S3 bucket to apply the notification configuration to.

    lambda_function {
        lambda_function_arn = aws_lambda_function.data_processor.arn # The ARN of the Lambda function to notify.
        events             = ["s3:ObjectCreated:*"] # Triggers the notification on object creation events.
        filter_suffix      = ".txt" # Only applies trigger to object keys ending in ".txt".
    }

    depends_on = [aws_lambda_permission.allow_bucket] # Ensures Permissions in place
}
