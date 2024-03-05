import boto3
import json

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('PROCESSED_TEXT')

def lambda_handler(event: dict, context) -> dict:
    """
    Process an uploaded file from S3, perform data processing, and return the processed content length.

    This function is triggered by an S3 event notification. It reads the content of the uploaded file,
    performs a simple data processing task (in this example, converting text to uppercase),
    and returns the length of the processed content.

    Parameters:
    - event (dict): The event dictionary containing information about the S3 object that triggered this function.
      It must include bucket name and object key.
    - context (LambdaContext): Provides runtime information about the Lambda function execution environment.

    Returns:
    - dict: A dictionary with a statusCode indicating success (200), and a body as a JSON string containing
      the message about the processed content length.

    Raises:
    - Exception: If any error occurs during the processing of the file or accessing S3, an exception is raised.

    Side Effects:
    - Reads a file from S3. This function assumes that the Lambda function has the necessary permissions to access
      the S3 bucket and object.

    Example of expected 'event' format:
    {
        "Records": [
            {
                "s3": {
                    "bucket": {
                        "name": "example-bucket"
                    },
                    "object": {
                        "key": "example-file.txt"
                    }
                }
            }
        ]
    }
    """
    s3 = boto3.client('s3')
    
    # Extract bucket name and file key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']
    
    # Get the file content from S3
    response = s3.get_object(Bucket=bucket_name, Key=file_key)
    file_content = response['Body'].read().decode('utf-8')
    
    # Process the file content (example: convert to uppercase)
    processed_content = file_content.upper()

    response = table.put_item(
        Item={
            'FileId': file_key,
            'data': processed_content
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Data stored in DynamoDB successfully!')
    }
