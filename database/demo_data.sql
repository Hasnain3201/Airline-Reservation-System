-- Optional extra demo data. Load after schema.sql:
--   mysql -u root -p < database/demo_data.sql
USE cs336project;

INSERT IGNORE INTO AIRLINE (airlineID, name)
VALUES ('CRL', 'Cirrus Air'), ('BLT', 'Baltic Blue');

INSERT IGNORE INTO AIRPORT (airportID, name, city, country)
VALUES
  ('JFK', 'John F. Kennedy International Airport', 'New York', 'United States'),
  ('SFO', 'San Francisco International Airport', 'San Francisco', 'United States'),
  ('SEA', 'Seattle-Tacoma International Airport', 'Seattle', 'United States'),
  ('BOS', 'Logan International Airport', 'Boston', 'United States'),
  ('MIA', 'Miami International Airport', 'Miami', 'United States'),
  ('DEN', 'Denver International Airport', 'Denver', 'United States'),
  ('LHR', 'Heathrow Airport', 'London', 'United Kingdom'),
  ('CDG', 'Charles de Gaulle Airport', 'Paris', 'France'),
  ('HND', 'Haneda Airport', 'Tokyo', 'Japan');

INSERT IGNORE INTO AIRCRAFT (aircraftID, model, seatCapacity, airlineID)
VALUES
  (1002, 'Embraer E175', 16, 'UA'),
  (2002, 'Boeing 757-200', 18, 'SKY'),
  (3001, 'Airbus A321neo', 24, 'CRL'),
  (4001, 'Boeing 787-9', 30, 'BLT');

INSERT IGNORE INTO FLIGHT (
  flightID, flightNum, departureTime, arrivalTime, daysOfWeek, flightType,
  airlineID, aircraftID, DepartureAirportID, ArrivalAirportID
) VALUES
  (601, 1410, '2026-10-02 07:05:00', '2026-10-02 10:20:00', 'Fri', 'Domestic', 'UA', 1002, 'EWR', 'LAX'),
  (602, 318,  '2026-10-04 18:40:00', '2026-10-05 06:55:00', 'Sun', 'International', 'BLT', 4001, 'JFK', 'LHR'),
  (603, 721,  '2026-10-06 09:30:00', '2026-10-06 12:05:00', 'Tue Thu', 'Domestic', 'CRL', 3001, 'SFO', 'SEA'),
  (604, 1188, '2026-10-08 06:15:00', '2026-10-08 08:10:00', 'Daily', 'Domestic', 'UA', 1001, 'BOS', 'ORD'),
  (605, 2240, '2026-10-10 13:25:00', '2026-10-10 17:45:00', 'Sat', 'Domestic', 'SKY', 2002, 'DEN', 'MIA'),
  (606, 904,  '2026-10-12 21:10:00', '2026-10-13 10:30:00', 'Mon', 'International', 'BLT', 4001, 'EWR', 'CDG'),
  (607, 1202, '2026-10-15 08:15:00', '2026-10-15 11:20:00', 'Mon Wed Fri', 'Domestic', 'UA', 1002, 'EWR', 'LAX'),
  (608, 1203, '2026-10-19 15:00:00', '2026-10-19 23:25:00', 'Mon Wed Fri', 'Domestic', 'UA', 1002, 'LAX', 'EWR'),
  (609, 730,  '2026-10-22 11:45:00', '2026-10-23 15:10:00', 'Thu', 'International', 'CRL', 3001, 'SEA', 'HND'),
  (610, 2203, '2026-10-24 10:20:00', '2026-10-24 12:25:00', 'Tue Thu Sat', 'Domestic', 'SKY', 2002, 'LAX', 'ORD'),
  (611, 1306, '2026-11-03 09:45:00', '2026-11-03 12:30:00', 'Daily', 'Domestic', 'UA', 1002, 'ORD', 'EWR'),
  (612, 725,  '2026-11-14 16:30:00', '2026-11-14 19:55:00', 'Sat', 'Domestic', 'CRL', 3001, 'MIA', 'JFK');

INSERT IGNORE INTO CUSTOMER (cid, fname, lname, email, password, address, dob)
VALUES
  (2, 'Priya', 'Nair', 'priya@demo.com', 'priya123', '48 Harbor Lane', '1991-11-12'),
  (3, 'Mateo', 'Alvarez', 'mateo@demo.com', 'mateo123', '9 Juniper Court', '1987-02-27'),
  (4, 'Hana', 'Sato', 'hana@demo.com', 'hana123', '210 Lantern Street', '1995-08-19');

INSERT IGNORE INTO PASSENGER (passengerID, fname, mname, lname, idNumber, dob, createdByCID)
VALUES
  (2, 'Avery', NULL, 'Customer', 'DEMO-PASS-002', '2001-03-14', 1),
  (3, 'Priya', NULL, 'Nair', 'P-NAIR-1991', '1991-11-12', 2),
  (4, 'Mateo', NULL, 'Alvarez', 'P-ALV-1987', '1987-02-27', 3),
  (5, 'Hana', NULL, 'Sato', 'P-SATO-1995', '1995-08-19', 4),
  (6, 'Lucia', NULL, 'Alvarez', 'P-ALV-2015', '2015-06-02', 3);

INSERT IGNORE INTO TICKET (
  ticketID, totalFare, bookingFee, purchaseDateTime, class, cancellable,
  cid, flightID, passengerID, legNumber, seatNumber
) VALUES
  (2,  400.00, 10.00, '2026-08-21 12:14:00', 'Business', true,  1, 607, 1, 1, '3'),
  (3,  100.00, 10.00, '2026-08-21 12:16:00', 'Economy',  false, 1, 608, 1, 1, '11'),
  (4,  700.00, 10.00, '2026-09-02 09:02:00', 'First',    true,  1, 602, 2, 1, '2'),
  (5,  100.00, 10.00, '2026-09-05 17:40:00', 'Economy',  false, 2, 603, 3, 1, '14'),
  (6,  400.00, 10.00, '2026-09-06 08:21:00', 'Business', true,  3, 606, 4, 1, '5'),
  (7,  400.00, 10.00, '2026-09-06 08:22:00', 'Business', true,  3, 606, 6, 1, '6'),
  (8,  100.00, 10.00, '2026-09-11 20:05:00', 'Economy',  false, 4, 609, 5, 1, '19'),
  (9,  100.00, 10.00, '2026-09-12 07:45:00', 'Economy',  false, 2, 604, 3, 1, '1'),
  (10, 100.00, 10.00, '2026-09-12 07:46:00', 'Economy',  false, 3, 604, 4, 1, '2'),
  (11, 100.00, 10.00, '2026-09-13 10:30:00', 'Economy',  false, 4, 604, 5, 1, '3'),
  (12, 400.00, 10.00, '2026-09-14 11:11:00', 'Business', true,  1, 604, 2, 1, '4'),
  (13, 100.00, 10.00, '2026-09-15 13:00:00', 'Economy',  false, 3, 604, 6, 1, '5'),
  (14, 700.00, 10.00, '2026-09-18 16:48:00', 'First',    true,  2, 602, 3, 1, '1'),
  (15, 100.00, 10.00, '2026-09-19 09:15:00', 'Economy',  false, 4, 610, 5, 1, '8'),
  (16, 100.00, 10.00, '2026-09-20 18:20:00', 'Economy',  false, 1, 604, 1, 1, '6');

INSERT IGNORE INTO WAITLIST (waitlistID, cid, flightID, dateOfRequest)
VALUES (1, 4, 604, '2026-09-20 19:02:00'), (2, 1, 501, '2026-06-28 08:00:00');

INSERT IGNORE INTO QUESTION (questionID, qtext, atext, qdate, adate, cid, repID)
VALUES
  (3, 'Is there a lounge at Newark for Business class passengers?', 'Yes. Business and First tickets include access to the Terminal C lounge, open from 5 AM.', '2026-09-03 14:20:00', '2026-09-03 15:02:00', 2, 1),
  (4, 'Can I bring a guitar on board as carry-on?', NULL, '2026-09-16 09:48:00', NULL, 3, NULL),
  (5, 'What happens to my Economy ticket if the flight is rescheduled?', NULL, '2026-09-21 22:10:00', NULL, 4, NULL);
