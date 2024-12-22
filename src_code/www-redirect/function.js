function handler(event) {
    var request = event.request;
    var host = request.headers.host.value;
    
    if (host == "phlask.me") {
        return request;
    }
    
    var newurl = 'https://phlask.me'+event.request.uri; // Change the redirect URL to the root domain
    
    var response = {
        statusCode: 302,
        statusDescription: 'Found',
        headers: { 
            "location": { "value": newurl }
        }
    };
    
    return response;
}