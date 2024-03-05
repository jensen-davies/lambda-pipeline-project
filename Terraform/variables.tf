variable "aws_region" {
    description = "AWS region to deploy the infrastructure"
    type        = string
    default     = "us-west-2"
}

variable "s3_bucket_name" {
    description = "Name of S3 bucket for input files"
    type        = string
    default     = "de-project-bucket-1"
}

variable "dynamodb_table_name" {
    description = "Name of the DynamoDB table to store results"
    type        = string
    default     = "PROCESSED_TEXT"
}

variable "lambda_function_name" {
    description = "Name of the Lambda function for data processing"
    type        = string
    default     = "DataProcessorFunction"
}

variable "lambda_runtime" {
    description = "Runtime for the Lambda function"
    type        = string
    default     = "python3.12"
}

variable "lambda_handler" {
    description = "Handler for the lambda function"
    type        = string
    default     = "lambda_function.lambda_handler"
}