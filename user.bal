import ballerina/http;
import ballerina/log;

service /viewers on new http:Listener(8089) {

    // Resource for creating a viewer account
    resource function post create(http:Caller caller, http:Request req) returns error? {
        // Parsing the request payload
        json|error payload = req.getJsonPayload();

        if (payload is error) {
            // Handle JSON parsing error
            http:Response res = new;
            res.setTextPayload("Invalid JSON format");
            res.setHeader("Access-Control-Allow-Origin", "*");
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
            return;
        }

        // Cast json to map<json> to access fields
        map<json> viewerMap = <map<json>>payload;

        // Create the Viewer record based on the received data
        Viewer newViewer = {
            firstname: viewerMap["firstname"].toString(),
            lastname: viewerMap["lastname"].toString(),
            email: viewerMap["email"].toString(),
            username: viewerMap["username"].toString(),
            password: viewerMap["password"].toString(),
            phonenumber: viewerMap["phonenumber"].toString(),
            nic: viewerMap["nic"].toString()
        };

        // Call the createViewerAccount function to insert the new viewer into the database
        int|error insertResult = createViewerAccount(newViewer);

        // Handle the response based on the result of the database operation
        if (insertResult is int) {
            // Return success message with the inserted viewer ID
            json response = { message: "Viewer account created successfully!", viewerId: insertResult };
            http:Response res = new;
            res.setJsonPayload(response);
            res.setHeader("Access-Control-Allow-Origin", "*");
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
        } else {
            // Log and return error response
            log:printError("Error creating viewer account", insertResult);
            json errorResponse = { message: "Failed to create viewer account" };
            http:Response res = new;
            res.setJsonPayload(errorResponse);
            res.setHeader("Access-Control-Allow-Origin", "*");
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
        }
    }

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

        // Call the loginViewer function (assuming it's implemented)
        Viewer|error viewer = loginViewer(username, password);

        if (viewer is Viewer) {
            // If login is successful, send the success message with CORS headers
            http:Response res = new;
            res.setTextPayload("Login successful for " + viewer.username);
            res.setHeader("Access-Control-Allow-Origin", "*");
            res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
            res.setHeader("Access-Control-Allow-Headers", "Content-Type");
            check caller->respond(res);
        } else {
            // If login fails, send an error message with CORS headers
            http:Response res = new;
            res.setTextPayload("Login failed: Invalid username or password");
            res.setHeader("Access-Control-Allow-Origin", "*");
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

    // Handle preflight (OPTIONS) requests for the create endpoint as well
    resource function options create(http:Caller caller, http:Request req) returns error? {
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        check caller->respond(res);
    }
}

