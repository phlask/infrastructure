import json
import boto3
import logging
import time
import os
from botocore.config import Config

logger = logging.getLogger()
logger.setLevel(logging.INFO)

list_name = "test-page-list"

boto3_config = Config(
    region_name = 'us-east-1',
    signature_version = 'v4',
    retries = {
        'max_attempts': 10,
        'mode': 'standard'
    }
)

s3 = boto3.resource('s3', config=boto3_config)
ddb = boto3.resource('dynamodb', config=boto3_config)
table = ddb.Table(list_name)

os.environ['TZ'] = 'America/New_York'
time.tzset()

def getTestResult(gitHash):
    # test_results_object = s3.Object('test.phlask.me', gitHash + '/testResults/jestResults.json')
    # test_results_content = test_results_object.get()['Body'].read().decode('utf-8')
    # test_results_json = json.loads(test_results_content)
    # if test_results_json['success']:
    #     return "Success"
    # else:
    #     return "Failed"
    return "TBD"

def timeConversion(seconds):

    minutes = (seconds // (60))

    hours = (seconds // (60 * 60))

    days = (seconds // (60 * 60 * 24))

    if seconds < 0:
        return "ERROR"
    elif seconds < 60:
        return str(seconds) + " Sec"
    elif minutes < 60:
        return str(minutes) + " Min"
    elif hours < 24:
        return str(hours) + " Hrs"
    else:
        return str(days) + " Days"

def lambda_handler(event, context):
    rows = ""
    rowCount = 0
    
    # Get everything from DynamoDB
    logger.info("Querying DDB list: " + list_name)
    
    response = table.scan()
    rowCount = response['ScannedCount']
    items = response['Items']
    
    logger.info("Found {} items!".format(rowCount))
    
    for item in items:
        currTime = int(time.time())
        timeRemaining = timeConversion(int(item['expirationTime']) - currTime)
        if timeRemaining == "ERROR":
            continue
        timestamp = time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime(int(item['timeCreated'])))
        
        testResult = getTestResult(item.get('lighthouseTestAvailable', False))
        if not item.get('gistID'):
            lighthouseResult = "N/A"
        else:
            lighthouseResult = "<a href=\"https://test.phlask.me/{}/testResults/lighthouse_result.html\">Click Here</a>".format(item['gitHash'])
    
        rows = rows + """
            <tr>
                <td><a href="https://github.com/{0}">{0}</td>
                <td><a href="https://github.com/phlask/phlask-map/tree/{1}">{1}</a></td>
                <td>{2}</td>
                <td>{3}</td>
                <td><a href="https://test.phlask.me/{4}">Click Here</a></td>
                <td><a href="https://test.phlask.me/testResults/{4}">{5}</a></td>
                <td>{6}</td>
            </tr>
        """.format(item['creator'], item['branch'], timestamp, timeRemaining, item['gitHash'], testResult, lighthouseResult)
    
    CONTENT = """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title>Phlask Test Site Listing</title>
        </head>
        <body>
            <p>Looking for your test site? You've come to the right place!</p>
            <p>There are currently {} sites available</p>
            <table border="1">
                <tr>
                    <th>Creator</th>
                    <th>Branch</th>
                    <th>Time </br>Created</th>
                    <th>Time </br>Remaining</th>
                    <th>URL</th>
                    <th>Jest </br>Test Results</th>
                    <th>Lighthouse </br>Test Results</th>
                </tr>
                {}
            </table>
        </body>
    </html>
    """.format(rowCount, rows)
    
    logger.info("Sending response!")

    # Generate HTTP OK response using 200 status code with HTML body.
    response = {
        'status': '200',
        'statusDescription': 'OK',
        'headers': {
            'cache-control': [
                {
                    'key': 'Cache-Control',
                    'value': 'max-age=100'
                }
            ],
            "content-type": [
                {
                    'key': 'Content-Type',
                    'value': 'text/html'
                }
            ],
            'content-encoding': [
                {
                    'key': 'Content-Encoding',
                    'value': 'UTF-8'
                }
            ]
        },
        'body': CONTENT
    }
    return response