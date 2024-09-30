import ballerina/http;

// Service listens on port 8080 for "/users" path
service /users on new http:Listener(8080) { // Changed /employees to /users

    // Resource to handle the POST request to add a new user
    resource function post .(@http:Payload User newUser, http:Caller caller) returns error? { // Changed Employee to User
        // Add your code to insert user into the database using the createAccount function
        int|error result = createAccount(newUser); // Assuming the createAccount function is available from main.bal
        
        http:Response res = new;
        if result is int {
            res.setTextPayload("User added with ID: " + result.toString());
        } else {
            res.setTextPayload("Failed to add user: " + result.toString());
            res.statusCode = 500; // Set status to Internal Server Error if adding user fails
        }
        
        // Add CORS headers
        res.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5501");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;

        // Add CORS headers for preflight request
        res.setHeader("Access-Control-Allow-Origin", "http://127.0.0.1:5501");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }
}
