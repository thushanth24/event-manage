
import ballerina/sql;

public function loginUser(string username, string password) returns boolean|error {
    sql:ParameterizedQuery query = `SELECT * FROM users WHERE username = ${username} AND password = ${password}`;
    boolean isAuthenticated = false;

    stream<User, sql:Error?> resultStream = dbClient->query(query);

    check from User user in resultStream
        do {
            if user.username == username && user.password == password {
                isAuthenticated = true;  // If match found, login is successful
            }
        };
    check resultStream.close();

    return isAuthenticated;
}
