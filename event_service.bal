import ballerina/http;

// Define a function to set CORS headers
function setCorsHeaders(http:Caller caller, http:Response res) returns error? {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return caller->respond(res);
}

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

        // CORS headers
        check setCorsHeaders(caller, res);

        // Send the response
        return;
    }

    // Resource to handle the GET request to retrieve all events or events created by a specific user
    resource function get .(http:Caller caller, string? username) returns error? {
        EventRecord[]|error eventsResult;

        if username is string {
            // If username is provided, get events for that user
            eventsResult = getEventsByUser(username);
        } else {
            // If no username is provided, get all events
            eventsResult = getAllEvents();
        }

        http:Response res = new;
        if eventsResult is EventRecord[] {
            // Create a JSON array from the EventRecord array
            json[] jsonResponse = [];
            foreach EventRecord event in eventsResult {
                json eventJson = {
                    id: event.id,
                    title: event.title,
                    description: event.description,
                    date: event.date,
                    location: event.location,
                    createdBy: event.createdBy
                };
                jsonResponse.push(eventJson); // Use push to add to the array
            }
            res.setJsonPayload(jsonResponse); // Set the JSON response
        } else {
            res.setTextPayload("Failed to retrieve events: " + eventsResult.toString());
            res.statusCode = 500; // Set status to Internal Server Error if retrieving events fails
        }

        // CORS headers
        check setCorsHeaders(caller, res);

        // Send the response
        return;
    }

    // Handling preflight OPTIONS requests for CORS
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;
        check setCorsHeaders(caller, res);
        return;
    }
}
