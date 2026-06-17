import json
import boto3

def lambda_handler(event, context):

    print("Probando funcion lambda")

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda funcionando correctamente')
    }