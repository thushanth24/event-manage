import ballerina/http;
import ballerina/sql;

// Service listens on port 8084 for "/admin" path
service /admin on new http:Listener(8084) {

    // Resource to get registrations for an event
    resource function get eventRegistrations/[int eventId](http:Caller caller, http:Request req) returns error? {
        // Fetch registrations for the event
        RegistrationRecord[] registrations = check getRegistrationsForEvent(eventId);

        // Creating the response
        http:Response res = new;
        if registrations.length() > 0 {
            res.setJsonPayload(registrations); // Send registrations as JSON
            res.statusCode = 200; // Status OK
        } else {
            res.setTextPayload("No registrations found for this event.");
            res.statusCode = 404; // Not Found
        }

        // CORS headers
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send response
        check caller->respond(res);
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        check caller->respond(res);
    }
}

// Function to retrieve registrations for a specific event
isolated function getRegistrationsForEvent(int eventId) returns RegistrationRecord[]|error {
    RegistrationRecord[] registrationList = [];

    // Query the database for registrations by eventId
    sql:ParameterizedQuery query = `SELECT id, name, email, phonenumber, eventId FROM registrations WHERE eventId = ${eventId}`;
    stream<RegistrationRecord, sql:Error?> registrationStream = registrationDbClient->query(query);

    // Iterate through the stream and build the registration list
    check from RegistrationRecord registration in registrationStream
        do {
            registrationList.push(registration);
        };

    return registrationList; // Return the list of registrations
}
