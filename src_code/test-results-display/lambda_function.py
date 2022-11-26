import json
import boto3
import logging
import time
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.resource('s3')

os.environ['TZ'] = 'America/New_York'
time.tzset()

def getTestResults(gitHash):
    test_results_object = s3.Object('test.phlask.me', gitHash + '/testResults/jestResults.json')
    test_results_content = test_results_object.get()['Body'].read().decode('utf-8')
    test_results_json = json.loads(test_results_content)
    return test_results_json

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
    requestedURI = event['Records'][0]['cf']['request']['uri']
    gitHash = requestedURI.replace('/testResults/', '')
    
    testResultDetails = getTestResults(gitHash)
    
    testResult = "failed"
    if testResultDetails['success']:
        testResult = "success"
        
    resultsContent = ""
    
    for result in testResultDetails['testResults']:
        testedFile = result['name'].replace('/usr/src/app/', '')
        testSuiteResult = result['status']
        
        rows = ""
        for assertionResult in result['assertionResults']:
            rows = rows + """
            <tr>
                <td>{}</td>
                <td>{}</td>
                <td>{}</td>
            </tr>
            """.format(assertionResult['title'], assertionResult['status'], str(assertionResult['failureMessages']))
        
        RESULTCONTENT = """
        <p>Tests for <b>{}: {}</b></p>
        <table border="1">
                <tr>
                    <th>Assertion Title</th>
                    <th>Assertion Result</th>
                    <th>Failure Messages</th>
                </tr>
                {}
            </table>
            </br>
        """.format(testedFile, testSuiteResult, rows)
        
        resultsContent = resultsContent + RESULTCONTENT
    
    CONTENT = """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title>Phlask Test Results</title>
        </head>
        <body>
            <p>Looking for your test results? You've come to the right place!</p>
            <p>Now showing test results for {}</p>
            <p>For additional result details, <a href="https://test.phlask.me/{}/testResults/jestResults.json">click here!</a></p>
            {}
        </body>
    </html>
    """.format(gitHash, gitHash, resultsContent)
    
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
