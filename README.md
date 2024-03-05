# lambda-pipeline-project

The purpose of this project is to gain familiarity with AWS Lambda, S3, DynamoDB, and Terraform. The project creates a simple data pipeline that converts the content of textfiles to uppercase.

The AWS infrastructure in this project is built via Terraform. It contains an S3 bucket, a Lambda function, a DynamoDB table, and an IAM role granting the Lambda function appropriate permissions to retrieve S3 bucket objects and write to DynamoDB tables.

When a textfile is manually uploaded to the S3 bucket, an event is created and notifies the Lambda function, which then processes the data and stores it within the DynamoDB table `PROCESSED_TEXT`.

## Files

- `lambda_function.py` contains a `lambda_handler` that AWS Lambda uses to read a textfile, convert it to uppercase, and store a key-value pair within a DynamoDB table (the key being the file name, and value being the uppercase content).

- `main.tf` contains the Terraform code that defines the AWS resources, policies, and necessary IAM role for the Lambda function.

- `variables.tf` contains variable names used within `main.tf`, enabling customization of the infrastructure without hardcoding values.

- `outputs.tf` simply defines outputs Terraform will print after the infrastructure is built.