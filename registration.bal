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

isolated function sendRegistrationEmail(RegistrationRecord registration) returns error? {
    email:SmtpClient smtpClient = check new ("smtp.gmail.com", "manothushanth@gmail.com", "yvowfmmgkgxzzxfn");

    email:Message email = {
        to: registration.email,
        subject: "Registration Confirmation",
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
                .event-details {
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
                    <strong>Registration Confirmation</strong>
                </div>
                <div class="email-body">
                    <p>Dear ${registration.name},</p>
                    <p>Thank you for registering for the event!</p>
                    <div class="event-details">
                        <p><strong>Name:</strong> ${registration.name}</p>
                        <p><strong>Email:</strong> ${registration.email}</p>
                        <p><strong>Phone:</strong> ${registration.phonenumber}</p>
                        <p><strong>NIC:</strong> ${registration.nic}</p>
                    </div>
                    <p>We look forward to seeing you at the event!</p>
                    <p>Best regards,</p>
                    <p><strong>Event Team</strong></p>
                </div>
                <div class="email-footer">
                    <p>&copy; 2024 Event Team | All rights reserved</p>
                </div>
            </div>
        </body>
        </html>`,
        contentType: "text/html" // Set the content type to HTML
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
