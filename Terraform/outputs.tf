output "s3_bucket_name" {
    value       = aws_s3_bucket.input_bucket.bucket
    description = "The name of the S3 bucket for input files."
}

output "dynamodb_table_name" {
    value       = aws_dynamodb_table.result_table.name
    description = "The name of the DynamoDB table storing the results."
}

output "lambda_function_name" {
    value       = aws_lambda_function.data_processor.function_name
    description = "The name of the Lambda function."
}

output "lambda_function_arn" {
    value       = aws_lambda_function.data_processor.arn
    description = "The ARN of the Lambda function."
}