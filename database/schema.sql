CREATE DATABASE IF NOT EXISTS cs336project;
USE cs336project;

CREATE TABLE IF NOT EXISTS CUSTOMER (
  cid INT AUTO_INCREMENT PRIMARY KEY,
  fname VARCHAR(80) NOT NULL,
  lname VARCHAR(80) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password VARCHAR(120) NOT NULL,
  address VARCHAR(255),
  dob DATE
);

CREATE TABLE IF NOT EXISTS ADMIN (
  adminID INT AUTO_INCREMENT PRIMARY KEY,
  fname VARCHAR(80) NOT NULL,
  lname VARCHAR(80) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS CUSTOMERREP (
  repID INT AUTO_INCREMENT PRIMARY KEY,
  fname VARCHAR(80) NOT NULL,
  lname VARCHAR(80) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS AIRLINE (
  airlineID VARCHAR(10) PRIMARY KEY,
  name VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS AIRPORT (
  airportID VARCHAR(10) PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  city VARCHAR(120) NOT NULL,
  country VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS AIRCRAFT (
  aircraftID INT PRIMARY KEY,
  model VARCHAR(120) NOT NULL,
  seatCapacity INT NOT NULL,
  airlineID VARCHAR(10) NOT NULL,
  FOREIGN KEY (airlineID) REFERENCES AIRLINE(airlineID)
);

CREATE TABLE IF NOT EXISTS FLIGHT (
  flightID INT PRIMARY KEY,
  flightNum INT NOT NULL,
  departureTime DATETIME NOT NULL,
  arrivalTime DATETIME NOT NULL,
  daysOfWeek VARCHAR(80),
  flightType VARCHAR(40),
  airlineID VARCHAR(10) NOT NULL,
  aircraftID INT NOT NULL,
  DepartureAirportID VARCHAR(10) NOT NULL,
  ArrivalAirportID VARCHAR(10) NOT NULL,
  FOREIGN KEY (airlineID) REFERENCES AIRLINE(airlineID),
  FOREIGN KEY (aircraftID) REFERENCES AIRCRAFT(aircraftID),
  FOREIGN KEY (DepartureAirportID) REFERENCES AIRPORT(airportID),
  FOREIGN KEY (ArrivalAirportID) REFERENCES AIRPORT(airportID)
);

CREATE TABLE IF NOT EXISTS PASSENGER (
  passengerID INT AUTO_INCREMENT PRIMARY KEY,
  fname VARCHAR(80) NOT NULL,
  mname VARCHAR(80),
  lname VARCHAR(80) NOT NULL,
  idNumber VARCHAR(80) NOT NULL UNIQUE,
  dob DATE NOT NULL,
  createdByCID INT,
  FOREIGN KEY (createdByCID) REFERENCES CUSTOMER(cid)
);

CREATE TABLE IF NOT EXISTS TICKET (
  ticketID INT AUTO_INCREMENT PRIMARY KEY,
  totalFare DECIMAL(10,2) NOT NULL,
  bookingFee DECIMAL(10,2) NOT NULL,
  purchaseDateTime DATETIME NOT NULL,
  class VARCHAR(40) NOT NULL,
  cancellable BOOLEAN NOT NULL,
  cid INT NOT NULL,
  flightID INT NOT NULL,
  passengerID INT NOT NULL,
  legNumber INT NOT NULL DEFAULT 1,
  seatNumber VARCHAR(10) NOT NULL,
  FOREIGN KEY (cid) REFERENCES CUSTOMER(cid),
  FOREIGN KEY (flightID) REFERENCES FLIGHT(flightID),
  FOREIGN KEY (passengerID) REFERENCES PASSENGER(passengerID)
);

CREATE TABLE IF NOT EXISTS WAITLIST (
  waitlistID INT AUTO_INCREMENT PRIMARY KEY,
  cid INT NOT NULL,
  flightID INT NOT NULL,
  dateOfRequest DATETIME NOT NULL,
  FOREIGN KEY (cid) REFERENCES CUSTOMER(cid),
  FOREIGN KEY (flightID) REFERENCES FLIGHT(flightID)
);

CREATE TABLE IF NOT EXISTS QUESTION (
  questionID INT PRIMARY KEY,
  qtext TEXT NOT NULL,
  atext TEXT,
  qdate DATETIME NOT NULL,
  adate DATETIME,
  cid INT NOT NULL,
  repID INT,
  FOREIGN KEY (cid) REFERENCES CUSTOMER(cid),
  FOREIGN KEY (repID) REFERENCES CUSTOMERREP(repID)
);

INSERT IGNORE INTO ADMIN (adminID, fname, lname, email, password)
VALUES (1, 'Admin', 'User', 'admin@demo.com', 'admin123');

INSERT IGNORE INTO CUSTOMERREP (repID, fname, lname, email, password)
VALUES (1, 'Alex', 'Representative', 'rep@demo.com', 'rep123');

INSERT IGNORE INTO CUSTOMER (cid, fname, lname, email, password, address, dob)
VALUES (1, 'Jordan', 'Customer', 'customer@demo.com', 'customer123', '1 Demo Way', '1998-05-01');

INSERT IGNORE INTO AIRLINE (airlineID, name)
VALUES ('UA', 'United Airways'), ('SKY', 'Skyline Express');

INSERT IGNORE INTO AIRPORT (airportID, name, city, country)
VALUES
  ('EWR', 'Newark Liberty International Airport', 'Newark', 'United States'),
  ('LAX', 'Los Angeles International Airport', 'Los Angeles', 'United States'),
  ('ORD', 'Chicago O Hare International Airport', 'Chicago', 'United States');

INSERT IGNORE INTO AIRCRAFT (aircraftID, model, seatCapacity, airlineID)
VALUES (1001, 'Boeing 737', 6, 'UA'), (2001, 'Airbus A320', 8, 'SKY');

INSERT IGNORE INTO FLIGHT (
  flightID, flightNum, departureTime, arrivalTime, daysOfWeek, flightType,
  airlineID, aircraftID, DepartureAirportID, ArrivalAirportID
) VALUES
  (501, 1201, '2026-07-01 08:15:00', '2026-07-01 11:20:00', 'Mon Wed Fri', 'Domestic', 'UA', 1001, 'EWR', 'LAX'),
  (502, 2202, '2026-07-03 14:00:00', '2026-07-03 16:05:00', 'Tue Thu Sat', 'Domestic', 'SKY', 2001, 'LAX', 'ORD'),
  (503, 1305, '2026-07-05 09:45:00', '2026-07-05 12:30:00', 'Daily', 'Domestic', 'UA', 1001, 'ORD', 'EWR');

INSERT IGNORE INTO PASSENGER (passengerID, fname, mname, lname, idNumber, dob, createdByCID)
VALUES (1, 'Jordan', NULL, 'Customer', 'DEMO-PASS-001', '1998-05-01', 1);

INSERT IGNORE INTO TICKET (
  ticketID, totalFare, bookingFee, purchaseDateTime, class, cancellable,
  cid, flightID, passengerID, legNumber, seatNumber
) VALUES (1, 100.00, 10.00, '2026-05-16 10:00:00', 'Economy', false, 1, 501, 1, 1, '1A');

INSERT IGNORE INTO QUESTION (questionID, qtext, atext, qdate, adate, cid, repID)
VALUES
  (1, 'Can I change my seat after booking?', 'Yes, a representative can update eligible reservations.', '2026-05-16 09:00:00', '2026-05-16 09:30:00', 1, 1),
  (2, 'How do I join a waitlist?', NULL, '2026-05-16 11:00:00', NULL, 1, NULL);
