import ballerinax/mysql;
import ballerina/sql;
import ballerina/email;

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

// Define the MessageRecord type
public type MessageRecord record {
    string firstName;
    string lastName;
    string email;
    string phonenumber;
    string message;
};

isolated function sendContactEmail(MessageRecord message) returns error? {
    // Initialize the SMTP client
    email:SmtpClient smtpClient = check new ("smtp.gmail.com", "manothushanth@gmail.com", "yvowfmmgkgxzzxfn");

    // Create the email message
    email:Message email = {
        to: message.email, 
        subject: "New Contact Form Submission",
        body: string `<!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 0;
                    padding: 0;
                    background-color: #f4f4f4;
                }
                .email-container {
                    padding: 20px;
                    background-color: white;
                    margin: 20px auto;
                    border: 1px solid #e2e2e2;
                    border-radius: 8px;
                    max-width: 600px;
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                }
                .email-header {
                    font-size: 18px;
                    color: #333333;
                    margin-bottom: 20px;
                    text-align: center;
                }
                .email-body {
                    font-size: 16px;
                    line-height: 1.6;
                    color: #555555;
                }
                .contact-details {
                    margin-top: 20px;
                    padding: 10px;
                    background-color: #f9f9f9;
                    border: 1px solid #e2e2e2;
                    border-radius: 5px;
                }
                .email-footer {
                    margin-top: 30px;
                    font-size: 14px;
                    color: #777777;
                    text-align: center;
                }
            </style>
        </head>
        <body>
            <div class="email-container">
                <div class="email-header">
                    <strong>New Contact Form Submission</strong>
                </div>
                <div class="email-body">
                    <p>Dear Event Team,</p>
                    <p>You have received a new message from the contact form!</p>
                    <div class="contact-details">
                        <p><strong>First Name:</strong> ${message.firstName}</p>
                        <p><strong>Last Name:</strong> ${message.lastName}</p>
                        <p><strong>Email:</strong> ${message.email}</p>
                        <p><strong>Phone:</strong> ${message.phonenumber}</p>
                        <p><strong>Message:</strong> ${message.message}</p>
                    </div>
                    <p>Best regards,</p>
                    <p><strong>Happy Events</strong></p>
                </div>
                <div class="email-footer">
                    <p>&copy; 2024 Happy Events | All rights reserved</p>
                </div>
            </div>
        </body>
        </html>`,
        contentType: "text/html" // Set the content type to HTML
    };

    // Send the email
    check smtpClient->sendMessage(email);
}



// Function to store message information in MySQL
isolated function storeMessage(MessageRecord newMessage) returns int|error {
    sql:ExecutionResult result = check eventDbClient->execute(`
        INSERT INTO messages (firstname, lastname, email, phonenumber, message)
        VALUES (${newMessage.firstName}, ${newMessage.lastName}, ${newMessage.email},
                ${newMessage.phonenumber}, ${newMessage.message})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        // Call the email function directly
    check sendContactEmail(newMessage); // Replace with sendRegistrationEmail if that's your intended function

        return lastInsertId;  // Return the ID of the newly created message
    } else {
        return error("Unable to obtain last insert ID");
    }
}



