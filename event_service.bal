import ballerina/http;


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

         // CORS headers
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send response
        check caller->respond(res);
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

        // CORS headers
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send response
        check caller->respond(res);
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

         // CORS headers
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Send response
        check caller->respond(res);
    }

    // DELETE to remove an event by ID
resource function delete .(http:Caller caller, int eventId) returns error? {
    boolean|error result = deleteEvent(eventId);
    http:Response res = new;

    if result is boolean {
        if result {
            res.setTextPayload("Event deleted successfully");
        } else {
            res.setTextPayload("Event not found");
            res.statusCode = 404; // Set status to Not Found if event doesn't exist
        }
    } else {
        res.setTextPayload("Failed to delete event: " + result.toString());
        res.statusCode = 500; // Set status to Internal Server Error if deletion fails
    }

    // CORS headers
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

    // Send response
    check caller->respond(res);
}



    // Handle OPTIONS preflight request
    resource function options .(http:Caller caller) returns error? {
        http:Response res = new;

        // Set CORS headers for preflight requests
        res.setHeader("Access-Control-Allow-Origin",  "*");
        res.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        // Respond to preflight request
        check caller->respond(res);
    }
}
