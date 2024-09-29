import json
import boto3
from boto3.dynamodb.conditions import Key
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('blogo_posts')


def lambda_handler(event, context):
    method = event['httpMethod']

    if method == 'GET':
        return get_post(event)
    elif method == 'POST':
        return create_post(event)
    elif method == 'PUT':
        return update_post(event)
    elif method == 'DELETE':
        return delete_post(event)
    else:
        return {
            'statusCode': 405,
            'body': json.dumps('Method Not Allowed')
        }


def get_post(event):
    post_id = event['pathParameters'].get('postId')
    try:
        response = table.get_item(Key={'postId': post_id})
        if 'Item' in response:
            return {
                'statusCode': 200,
                'body': json.dumps(response['Item'])
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps('Post not found')
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error fetching post: {str(e)}")
        }


def create_post(event):
    data = json.loads(event['body'])
    post_id = data.get('postId', str(len(table.scan()['Items']) + 1))

    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    item = {
        'postId': post_id,
        'title': data['title'],
        'content': data['content'],
        'createdAt': current_time
    }

    try:
        table.put_item(Item=item)
        return {
            'statusCode': 201,
            'body': json.dumps({'postId': post_id, 'message': 'Post created'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error creating post: {str(e)}")
        }


def update_post(event):
    post_id = event['pathParameters'].get('postId')
    data = json.loads(event['body'])
    try:
        response = table.update_item(
            Key={'postId': post_id},
            UpdateExpression="set title = :t, content = :c",
            ExpressionAttributeValues={
                ':t': data['title'],
                ':c': data['content']
            },
            ReturnValues="UPDATED_NEW"
        )
        return {
            'statusCode': 200,
            'body': json.dumps({'postId': post_id, 'message': 'Post updated', 'updatedAttributes': response['Attributes']})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error updating post: {str(e)}")
        }


def delete_post(event):
    post_id = event['pathParameters'].get('postId')
    try:
        response = table.delete_item(
            Key={'postId': post_id},
            ConditionExpression="attribute_exists(postId)"
        )
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Post deleted', 'deletedAttributes': response['Attributes']})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error deleting post: {str(e)}")
        }
