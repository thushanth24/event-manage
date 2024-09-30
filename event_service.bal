import ballerina/http;


// Service listens on port 8082 for "/events" path
service /events on new http:Listener(8082) {

    // Resource to handle the POST request to create a new event
    resource function post .(@http:Payload EventRecord newEvent, http:Caller caller) returns error? {
        int|error result = createEvent(newEvent); // Call the function to create an event

        http:Response res = new;
        if result is int {
            res.setTextPayload("Event created with ID: " + result.toString());
        } else {
            res.setTextPayload("Failed to create event: " + result.toString());
            res.statusCode = 500; // Set status to Internal Server Error if creating event fails
        }

        // Allow all origins for testing (remove this for production)
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }

    // Resource to handle the GET request to retrieve all events
    resource function get .(http:Caller caller) returns error? {
        EventRecord[]|error eventsResult = getAllEvents(); // Call your function to get all events

        http:Response res = new;
        if eventsResult is EventRecord[] {
            // Create a JSON array from the EventRecord array
            json[] jsonResponse = []; // Create an array of JSON objects
            foreach EventRecord event in eventsResult {
                // Construct individual event JSON objects
                json eventJson = {
                    id: event.id,
                    title: event.title,
                    description: event.description,
                    date: event.date,
                    location: event.location,
                    createdBy: event.createdBy
                };
                // Add eventJson to jsonResponse
                jsonResponse.push(eventJson); // Use push to add to the array
            }
            res.setJsonPayload(jsonResponse); // Set the JSON response
        } else {
            res.setTextPayload("Failed to retrieve events: " + eventsResult.toString());
            res.statusCode = 500; // Set status to Internal Server Error if retrieving events fails
        }

        // Allow all origins for testing (remove this for production)
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send the response
        check caller->respond(res);
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        check caller->respond(res);
    }
}
