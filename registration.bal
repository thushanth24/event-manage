import ballerinax/mysql;
import ballerina/sql;

// Define a unique RegistrationRecord type
public type RegistrationRecord record {|
    int id?;                  // Registration ID
    string name;              // User's name
    string email;             // User's email
    string phonenumber;       // User's phone number
    int eventId;             // ID of the event registered for
|};

// MySQL database configuration
configurable string EVENT_DB_USER = ?;
configurable string EVENT_DB_PASSWORD = ?;
configurable string EVENT_DB_HOST = ?;
configurable int EVENT_DB_PORT = ?;
configurable string EVENT_DB_DATABASE = ?;

// MySQL client for database operations
final mysql:Client registrationDbClient = check new(
    host=EVENT_DB_HOST, user=EVENT_DB_USER, password=EVENT_DB_PASSWORD, port=EVENT_DB_PORT, database=EVENT_DB_DATABASE
);

// Function to register for an event
isolated function registerForEvent(RegistrationRecord newRegistration) returns int|error {
    sql:ExecutionResult result = check registrationDbClient->execute(`
        INSERT INTO registrations (name, email, phonenumber, eventId)
        VALUES (${newRegistration.name}, ${newRegistration.email}, 
                ${newRegistration.phonenumber}, ${newRegistration.eventId})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId; // Return the ID of the newly created registration
    } else {
        return error("Unable to obtain last insert ID");
    }
}
