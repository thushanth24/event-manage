import ballerina/http;

service /viewers on new http:Listener(8089) {

    // Resource for handling login requests
    resource function post login(http:Caller caller, http:Request req) returns error? {
        // Parse the request JSON to get the login credentials
        json|error loginDetails = req.getJsonPayload();

        if (loginDetails is error) {
            // Handle the error when parsing the payload
            http:Response res = new;
            res.setTextPayload("Invalid JSON format");
            res.setHeader("Access-Control-Allow-Origin", "*");
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
            return;
        }

        // Cast json to map<json> to access fields
        map<json> loginMap = <map<json>>loginDetails;

        // Extract username and password from the JSON map
        string username = loginMap["username"].toString();
        string password = loginMap["password"].toString();

        // Call your loginViewer function (assuming it's implemented)
        Viewer|error viewer = loginViewer(username, password);

        if (viewer is Viewer) {
            // If login is successful, send the success message with CORS headers
            http:Response res = new;
            res.setTextPayload("Login successful for " + viewer.username);
            res.setHeader("Access-Control-Allow-Origin", "*"); // Allow all origins
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
        } else {
            // If login fails, send an error message with CORS headers
            http:Response res = new;
            res.setTextPayload("Login failed: Invalid username or password");
            res.setHeader("Access-Control-Allow-Origin", "*"); // Allow all origins
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
        }
    }

    // Handle preflight (OPTIONS) requests for CORS
    resource function options login(http:Caller caller, http:Request req) returns error? {
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        check caller->respond(res);
    }
}
