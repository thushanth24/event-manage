import ballerina/http;


// Define a function to set CORS headers
function setCorsHeaders(http:Caller caller, http:Response res) returns error? {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return caller->respond(res);
}

service /events on new http:Listener(8082) {

    // POST to create a new event
    resource function post .(@http:Payload EventRecord newEvent, http:Caller caller) returns error? {
        int|error result = createEvent(newEvent);

        http:Response res = new;
        if result is int {
            res.setTextPayload("Event created with ID: " + result.toString());
        } else {
            res.setTextPayload("Failed to create event: " + result.toString());
            res.statusCode = 500;
        }

         // CORS headers for development
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        check setCorsHeaders(caller, res);
        return;
    }

    // GET to retrieve events (by user or all)
    resource function get .(http:Caller caller, string? username) returns error? {
        EventRecord[]|error eventsResult;

        if username is string {
            eventsResult = getEventsByUser(username);
        } else {
            eventsResult = getAllEvents();
        }

        http:Response res = new;
        if eventsResult is EventRecord[] {
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
                jsonResponse.push(eventJson);
            }
            res.setJsonPayload(jsonResponse);
        } else {
            res.setTextPayload("Failed to retrieve events: " + eventsResult.toString());
            res.statusCode = 500;
        }

         // CORS headers for development
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        check setCorsHeaders(caller, res);
        return;
    }

    // PUT to update an event
resource function put .(@http:Payload EventRecord updatedEvent, http:Caller caller) returns error? {
    boolean|error result = updateEvent(updatedEvent);

    http:Response res = new;
    if result is boolean {
        if result {
            res.setTextPayload("Event updated successfully");
        } else {
            res.setTextPayload("Event not found");
            res.statusCode = 404; // Set status to Not Found if event doesn't exist
        }
    } else if result is error {
        res.setTextPayload("Failed to update event: " + result.toString());
        res.statusCode = 500; // Set status to Internal Server Error if updating event fails
    }

     // CORS headers for development
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

    // CORS headers
    check setCorsHeaders(caller, res);

    // Send the response
    return;
}


    // DELETE to remove an event by ID
resource function delete .(int eventId, http:Caller caller) returns error? {
    boolean|error result = deleteEvent(eventId);

    http:Response res = new;
    if result is boolean {
        if result {
            res.setTextPayload("Event deleted successfully");
        } else {
            res.setTextPayload("Event not found");
            res.statusCode = 404; // Set status to Not Found if event doesn't exist
        }
    } else if result is error {
        res.setTextPayload("Failed to delete event: " + result.toString());
        res.statusCode = 500; // Set status to Internal Server Error if deleting event fails
    }

     // CORS headers for development
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

    // CORS headers
    check setCorsHeaders(caller, res);

    // Send the response
    return;
}


    // OPTIONS to handle preflight requests
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;
        check setCorsHeaders(caller, res);
        return;
    }
}
