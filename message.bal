import ballerina/http;

service /messages on new http:Listener(8087) {

    // POST to store a new message
    resource function post .(@http:Payload MessageRecord newMessage, http:Caller caller) returns error? {
        int|error result = storeMessage(newMessage);

        http:Response res = new;
        if result is int {
            res.setTextPayload("Message stored with ID: " + result.toString());
        } else {
            res.setTextPayload("Failed to store message: " + result.toString());
            res.statusCode = 500;
        }

        // CORS headers
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send response
        check caller->respond(res);
    }

    // Handle OPTIONS preflight request
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;

        // Set CORS headers for preflight requests
        res.setHeader("Access-Control-Allow-Origin",  "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Respond to preflight request
        check caller->respond(res);
    }
}
