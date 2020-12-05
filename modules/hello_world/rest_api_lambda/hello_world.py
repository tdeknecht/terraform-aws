import json

def lambda_handler(event, context):
    print("In lambda handler")
    
    resp = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/html; charset=utf8",
            "Access-Control-Allow-Origin": "*",
        },
        "body": "<h1>Hello world!</h1>"
    }
    
    return resp