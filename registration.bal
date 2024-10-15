import ballerinax/mysql;
import ballerina/sql;
import ballerina/email;

// Define a unique RegistrationRecord type with 'nic'
public type RegistrationRecord record {| 
    int id?;                   // Registration ID
    string name;               // User's name
    string email;              // User's email
    string phonenumber;        // User's phone number
    string nic;                // User's NIC (unique identifier)
    int eventId;               // ID of the event registered for
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

// Function to send registration confirmation email
isolated function sendRegistrationEmail(RegistrationRecord registration) returns error? {
    email:SmtpClient smtpClient = check new ("smtp.gmail.com", "manothushanth@gmail.com", "yvowfmmgkgxzzxfn");

    email:Message email = {
        to: registration.email, // Send the email to the user's email
        subject: "Registration Confirmation",
        body: string `Dear ${registration.name},\n\nThank you for registering for Event ID: ${registration.eventId}.\n\nBest regards,\nEvent Team`
    };

    check smtpClient->sendMessage(email);
}

// Function to register for an event and send an email
isolated function registerForEvent(RegistrationRecord newRegistration) returns int|error {
    // Insert the registration data into the database, ensuring uniqueness with 'nic' + 'eventId'
    sql:ExecutionResult result = check registrationDbClient->execute(` 
        INSERT INTO registrations (name, email, phonenumber, nic, eventId)
        VALUES (${newRegistration.name}, ${newRegistration.email}, 
                ${newRegistration.phonenumber}, ${newRegistration.nic}, ${newRegistration.eventId})
    `);

    int|string? lastInsertId = result.lastInsertId;

    if lastInsertId is int {
        check sendRegistrationEmail(newRegistration); // Call the email function
        return lastInsertId; // Return the ID of the newly created registration
    } else {
        return error("Unable to obtain last insert ID"); 
    }
}
