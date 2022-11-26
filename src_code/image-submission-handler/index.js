'use strict';
const uuid = require('uuid');
const querystring = require('querystring');

const bucket = "phlask-tap-images"
const AWS = require("aws-sdk")
var s3 = new AWS.S3({
	    signatureVersion: 'v4',
	    region: 'us-east-2'
});

exports.handler = (event, context, callback) => {
	    console.log(JSON.stringify(event, null, 4));
	    const request = event.Records[0].cf.request;
	    
	    if (request.method === 'GET') {
		            
		            const params = querystring.parse(request.querystring);
		            
		            var type = params["type"]
		            
		            /* Reject unsupported input types */
		            if (type != "image/jpeg" && type != "image/jpg" && type != "image/png" && type != "image/gif") {
		            	console.log("The filetype was invalid: ", type)
		                return callback(null, {
			                body: JSON.stringify({}),
			                status: '400',
			                statusDescription: 'BadContentType'
			            })
		            }
		            
		            type = type.split("/")[1]
		            
		            var imageID = uuid.v4();
		            
		            var prefix = ''
		            /* TODO: Update the method to get the host header based on the following request content
		            {
				    
	                "request": {
	                    "clientIp": "173.62.214.14",
	                    "headers": {
	                        "host": [
	                            {
	                                "key": "Host",
	                                "value": "beta.phlask.me"
	                            }
	                        ],
		            */
		            var hostname = request.headers.host[0].value
		            if (hostname == "test.phlask.me") {
		            	prefix = 'test/'
		            }
		            else if (hostname == "beta.phlask.me") {
		            	prefix = 'beta/'
		            }
		            else if (hostname == "phlask.me") {
		            	prefix = 'prod/'
		            }
		            else {
		            	console.log('The request header was invalid: ', request.headers.host.value)
		            	return callback(null, {
				            body: JSON.stringify({}),
				            status: '400',
				            statusDescription: 'InvalidHTTPMethod'
				        });
		            }
		            
		            var putParams = {
		                Bucket: bucket,
		                Key: prefix + 'tap-images/' + imageID + '.' + type,
		                Expires: 300
		            };
		            
		            // var getParams = {
		            //     Bucket: bucket,
		            //     Key: imageID + '.' + type
		            // };
		            
		            var putURL = s3.getSignedUrl('putObject', putParams)
		            /* TODO: Adjust the GET URL to allow getting images at the expected endpoint */
		            // var getURL = s3.getSignedUrl('getObject', getParams)
		            const getURL = imageID + '.' + type
		            
		            console.log('The generated PUT URL is ', putURL)
		            console.log('The generated GET URL is ', getURL)
		            
		            return callback(null, {
		                body: JSON.stringify({
					                "putURL": putURL,
					                "getURL": getURL,
					                "errorMessage": null
					            }),
		                status: '200',
		                statusDescription: 'OK'
		            })
		        }
	    
	    console.log("Invalid Request Method!", null, 4)
	    return callback(null, {
		            body: JSON.stringify({}),
		            status: '400',
		            statusDescription: 'InvalidHTTPMethod'
		        });
};
