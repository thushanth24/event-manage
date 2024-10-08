import ballerinax/mysql;
import ballerina/sql;

// Define a unique EventRecord type
public type EventRecord record {| 
    int id?;                  // Event ID
    string title;             // Event title
    string description;       // Event description
    string date;              // Event date
    string location;          // Event location
    string createdBy;         // User who created the event
|};

// MySQL database configuration
configurable string DB_USER = ?;
configurable string DB_PASSWORD = ?;
configurable string DB_HOST = ?;
configurable int DB_PORT = ?;
configurable string DB_DATABASE = ?;

// MySQL client for database operations
final mysql:Client eventDbClient = check new(
    host=DB_HOST, user=DB_USER, password=DB_PASSWORD, port=DB_PORT, database=DB_DATABASE
);

// Function to create a new event
isolated function createEvent(EventRecord newEvent) returns int|error {
    sql:ExecutionResult result = check eventDbClient->execute(`
        INSERT INTO events (title, description, date, location, createdBy)
        VALUES (${newEvent.title}, ${newEvent.description}, ${newEvent.date},
                ${newEvent.location}, ${newEvent.createdBy})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId; // Return the ID of the newly created event
    } else {
        return error("Unable to obtain last insert ID");
    }
}

// Function to retrieve events created by the logged-in user
isolated function getEventsByUser(string username) returns EventRecord[]|error {
    EventRecord[] events = [];
    stream<EventRecord, sql:Error?> resultStream = eventDbClient->query(`
        SELECT * FROM events WHERE createdBy = ${username}
    `);
    check from EventRecord event in resultStream
        do {
            events.push(event);
        };
    check resultStream.close();
    return events;
}

// Function to retrieve all events
isolated function getAllEvents() returns EventRecord[]|error {
    EventRecord[] events = [];
    stream<EventRecord, sql:Error?> resultStream = eventDbClient->query(`
        SELECT * FROM events
    `);
    check from EventRecord event in resultStream
        do {
            events.push(event);
        };
    check resultStream.close();
    return events;
}

// Function to delete an event by ID
isolated function deleteEvent(int eventId) returns boolean|error {
    sql:ExecutionResult result = check eventDbClient->execute(`DELETE FROM events WHERE id = ${eventId}`);
    if result.affectedRowCount > 0 {
        return true; // Return true if the event was successfully deleted
    } else {
        return false; // Return false if no rows were affected (event not found)
    }
}

// Function to update an event by ID
isolated function updateEvent(EventRecord updatedEvent) returns boolean|error {
    sql:ExecutionResult result = check eventDbClient->execute(`
        UPDATE events 
        SET title = ${updatedEvent.title}, description = ${updatedEvent.description}, 
            date = ${updatedEvent.date}, location = ${updatedEvent.location}, 
            createdBy = ${updatedEvent.createdBy}
        WHERE id = ${updatedEvent.id}
    `);
    if result.affectedRowCount > 0 {
        return true; // Return true if the event was successfully updated
    } else {
        return false; // Return false if no rows were affected (event not found)
    }
}
