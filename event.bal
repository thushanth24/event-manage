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
