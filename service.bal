import ballerina/http;

// Service listens on port 8080 for "/users" path
service /users on new http:Listener(8080) {

    // Resource to handle the POST request to create a new user
    resource function post .(@http:Payload User user, http:Caller caller) returns error? {
        int|error result = addUser(user); // Add your code to insert user into the database

        http:Response res = new;
        if result is int {
            res.setTextPayload("User added with ID: " + result.toString());
            res.statusCode = 201; // Set status to Created
        } else {
            res.setTextPayload("Failed to add user: " + result.toString());
            res.statusCode = 500; // Set status to Internal Server Error if adding user fails
        }

        // Add CORS headers
        res.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;

        // Add CORS headers for preflight request
        res.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }
}
