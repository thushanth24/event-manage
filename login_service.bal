import ballerina/http;

// Service listens on port 8081 for "/login" path
service /login on new http:Listener(8081) {

    // Resource to handle the POST request for login
    resource function post .(@http:Payload map<string> loginData, http:Caller caller) returns error? {
        string username = loginData["username"].toString();
        string password = loginData["password"].toString();

        boolean|error loginResult = loginUser(username, password); // Ensure this function is defined

        http:Response res = new;
        if loginResult is boolean && loginResult {
            res.setTextPayload("Login successful!");
        } else {
            res.setTextPayload("Invalid username or password.");
            res.statusCode = 401;  // Unauthorized status code
        }

        // CORS headers for development
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        check caller->respond(res);
    }
}
