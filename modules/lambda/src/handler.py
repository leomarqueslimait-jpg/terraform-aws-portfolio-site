import json
import boto3
import uuid
import os
from datetime import datetime, timezone

dynamodb = boto3.resource('dynamodb')
table    = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST,OPTIONS'
    }

    if event.get('httpMethod') == 'OPTIONS':
        return {'statusCode': 200, 'headers': headers, 'body': ''}

    try:
        body = json.loads(event.get('body', '{}'))

        required = ['name', 'email', 'message']
        for field in required:
            if not body.get(field):
                return {
                    'statusCode': 400,
                    'headers': headers,
                    'body': json.dumps({'error': f'Missing field: {field}'})
                }

        table.put_item(Item={
            'id':         str(uuid.uuid4()),
            'name':       body['name'],
            'email':      body['email'],
            'subject':    body.get('subject', 'No subject'),
            'message':    body['message'],
            'created_at': datetime.now(timezone.utc).isoformat(),
        })

        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps({'message': 'Contact saved successfully'})
        }

    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({'error': 'Internal server error'})
        }