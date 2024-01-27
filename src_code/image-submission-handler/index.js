'use strict';
const uuid = require('uuid');
const querystring = require('querystring');

const bucket = "phlask-tap-images"
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { PutObjectCommand, S3 } = require('@aws-sdk/client-s3');

var s3 = new S3({
        region: 'us-east-2'
});

exports.handler = async(event, context, callback) => {
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
		            	console.log('The request header was invalid: ', request.headers.host[0].value)
		            	return callback(null, {
				            body: JSON.stringify({}),
				            status: '400',
				            statusDescription: 'InvalidHTTPMethod'
				        });
		            }
		            
		            var putParams = {
		                Bucket: bucket,
		                Key: prefix + 'tap-images/' + imageID + '.' + type,
		            };
		            
		            // var getParams = {
		            //     Bucket: bucket,
		            //     Key: imageID + '.' + type
		            // };
		            
					var putURL = await getSignedUrl(s3, new PutObjectCommand(putParams), {
						expiresIn: 300
					})
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
