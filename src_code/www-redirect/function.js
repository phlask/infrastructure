function handler(event) {
    var request = event.request;
    var host = request.headers.host.value;
    
    if (host == "phlask.me") {
        var uri = request.uri;

        // These is temporary logic to handle in PHLASKv1
        if (uri.endsWith('mission') || uri.endsWith('project') || uri.endsWith('share') || uri.endsWith('contribute')) {
            request.uri = "/index.html"
            return request;
        }

        // Check whether the URI is missing a file name.
        if (uri.endsWith('/')) {
            request.uri += 'index.html';
        }
        // Check whether the URI is missing a file extension.
        else if (!uri.includes('.')) {
            request.uri += '/index.html';
        }

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