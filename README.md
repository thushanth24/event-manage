# event-manage
Hii Welcome to Happy Event , events management website!

It was developed using
HTML
CSS
JS for FrontEnd,
Ballerina for BackEnd,and
MySQL for database services !

Steps to gets the Output,

*******************************************STEP 1**************************************************

Adjust the Config.toml file in the project !
Change the USER & PASSWORD base on your MySQL credintials.

*******************************************STEP 2**************************************************

Start your MySQL server!

*******************************************STEP 3**************************************************

Create the Data Base in MySQL or MySQL workbench (Code is below onthis line)!

CREATE DATABASE IF NOT EXISTS management;
use management;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phonenumber VARCHAR(15) NOT NULL
);

select * from users;


CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    location VARCHAR(255),
    createdBy VARCHAR(255) NOT NULL
);

select * from events;


CREATE TABLE registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phonenumber VARCHAR(15),
    eventId INT,
    FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
);

ALTER TABLE registrations
ADD COLUMN nic VARCHAR(20) UNIQUE;

ALTER TABLE registrations
ADD CONSTRAINT unique_registration UNIQUE (nic, eventId);

CREATE TABLE viewers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phonenumber VARCHAR(15) NOT NULL,
    nic VARCHAR(12) NOT NULL UNIQUE  -- Adding NIC field as unique
);

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phonenumber VARCHAR(15) NOT NULL,
    message TEXT NOT NULL,
    createdat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


*******************************************STEP 4**************************************************
 
 Open the Project in an IDE and Run any of (.bal) file !

 *******************************************STEP 5**************************************************

 In the Project a file called HTML, Open that and run the (home.html) file to review our website!!!

 Cheers !!!
