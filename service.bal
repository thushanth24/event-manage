import ballerina/http;

// Service listens on port 8080 for "/users" path
service /users on new http:Listener(8080) {

    // Resource to handle the POST request to add a new user
    resource function post .(@http:Payload User user, http:Caller caller) returns error? {
        int|error result = createAccount(user); // Call your user creation function

        http:Response res = new;
        if result is int {
            res.setTextPayload("User added with ID: " + result.toString());
        } else {
            res.setTextPayload("Failed to add user: " + result.toString());
            res.statusCode = 500; // Set status to Internal Server Error if adding user fails
        }

        // Allow all origins for testing (remove this for production)
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;

        // Allow all origins for preflight requests (remove this for production)
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }
}
