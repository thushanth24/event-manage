import ballerina/http;

// Service listens on port 8083 for "/register" path
service /register on new http:Listener(8083) {

    // Resource to handle the POST request for event registration
    resource function post .(@http:Payload RegistrationRecord newRegistration, http:Caller caller) returns error? {
        int|error result = registerForEvent(newRegistration); // Call the function to register for an event

        http:Response res = new;
        if result is int {
            res.setTextPayload("Registration successful with ID: " + result.toString());
            res.statusCode = 200; // Set status to OK
        } else if result is error {
            // Check if the error message contains "Duplicate entry"
            string errMessage = result.toString();
            if errMessage.includes("Duplicate entry") {
                // Handle duplicate NIC error
                res.setTextPayload("Failed to register: NIC already registered.");
                res.statusCode = 409; // Conflict status code for duplicate NIC
            } else {
                res.setTextPayload("Failed to register: " + errMessage);
                res.statusCode = 500; // Set status to Internal Server Error for other errors
            }
        }

        // CORS headers
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
