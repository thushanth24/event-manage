import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/sql;

public type User record {|  // Changed Employee to User
    int id?;                 // Changed employee_id to id
    string firstname;        // Added firstname
    string lastname;         // Added lastname
    string email;            // Added email
    string username;         // Added username
    string password;         // Added password
    string phonenumber;      // Added phonenumber
|};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database="management" // Changed to management
);

isolated function createAccount(User newUser) returns int|error {  // Renamed to createAccount
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO users (firstname, lastname, email, username, password, phonenumber)
        VALUES (${newUser.firstname}, ${newUser.lastname}, ${newUser.email},
                ${newUser.username}, ${newUser.password}, ${newUser.phonenumber})
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;  // Return the ID of the newly created user
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function getUser(int id) returns User|error {  // Function to get user by ID
    User user = check dbClient->queryRow(
        `SELECT * FROM users WHERE id = ${id}`
    );
    return user;
}

isolated function getAllUsers() returns User[]|error {  // Function to get all users
    User[] users = [];
    stream<User, error?> resultStream = dbClient->query(
        `SELECT * FROM users`
    );
    check from User user in resultStream
        do {
            users.push(user);
        };
    check resultStream.close();
    return users;
}

isolated function updateUser(User user) returns int|error {  // Function to update user
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE users SET
            firstname = ${user.firstname}, 
            lastname = ${user.lastname},
            email = ${user.email},
            username = ${user.username},
            password = ${user.password},
            phonenumber = ${user.phonenumber}
        WHERE id = ${user.id}  
    `);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function removeUser(int id) returns int|error {  // Function to remove user
    sql:ExecutionResult result = check dbClient->execute(`
        DELETE FROM users WHERE id = ${id}
    `);
    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return affectedRowCount;
    } else {
        return error("Unable to obtain the affected row count");
    }
}
