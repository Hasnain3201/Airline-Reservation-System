# Airline Reservation System

<p align="center">
  <strong>A Java, JSP, and MySQL reservation system with customer booking, representative operations, and admin reporting workflows.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Java-JSP%20%2F%20JDBC-007396?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java JSP JDBC">
  <img src="https://img.shields.io/badge/Server-Apache%20Tomcat-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black" alt="Apache Tomcat">
  <img src="https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/Schema-Demo%20Seed%20Data-16a34a?style=for-the-badge" alt="Demo seed data">
</p>

## Preview

Application screenshots will be added after a local Tomcat and MySQL runtime is available. This workspace has the MySQL client, but the MySQL server is not running and no Tomcat executable is available, so JSP pages cannot be deployed or screen-captured here without staging misleading static images.

Target capture set after local deployment:

| Screen | What it should show |
| --- | --- |
| Login | Role-based entry point |
| Search Flights | Customer search form backed by airport/airline seed data |
| Flight Results | Bookable outbound and return flights |
| Reservations | Customer itinerary and cancellation flow |
| Admin / Representative | Reporting, user management, and flight operations pages |

## Overview

Airline Reservation System is a traditional JSP web application for searching flights, booking seats, managing reservations, answering customer questions, and reviewing administrative reports. It is designed for Apache Tomcat and MySQL and now includes a starter schema with demo seed data so the project can be brought up locally with fewer missing setup pieces.

## Highlights

- Customer login, flight search, booking, cancellation, and reservation history.
- Representative workflows for reservations, passengers, airport flights, waitlists, and Q&A.
- Administrator workflows for user management, sales reports, revenue summaries, top customers, and active flights.
- Environment-based database configuration through `DB_URL`, `DB_USER`, and `DB_PASSWORD`.
- Sample MySQL schema and seed data in `database/schema.sql`.

## Tech Stack

| Layer | Tools |
| --- | --- |
| Backend | Java, JSP, JDBC |
| Server | Apache Tomcat 9 recommended |
| Database | MySQL |
| Driver | MySQL Connector/J in `WEB-INF/lib` |
| UI | JSP, HTML, shared "Contrail" design system (`assets/contrail.css`, `assets/contrail.js`, `WEB-INF/jspf/`) |

## Project Structure

```text
.
├── database/
│   └── schema.sql
├── cs336Sample/
│   └── src/main/
│       ├── java/com/cs336/pkg/ApplicationDB.java
│       └── webapp/
│           ├── WEB-INF/
│           ├── login.jsp
│           ├── searchFlights.jsp
│           ├── flightResults.jsp
│           ├── adminHome.jsp
│           └── repHome.jsp
└── README.md
```

## Getting Started

### Prerequisites

- JDK 8+
- Apache Tomcat 9
- MySQL 5.7+ or MySQL 8
- MySQL Connector/J in `cs336Sample/src/main/webapp/WEB-INF/lib/`

### Database Setup

```bash
mysql -u root -p < database/schema.sql
# optional: extra airports, future flights, tickets and questions for a fuller demo
mysql -u root -p < database/demo_data.sql
```

Demo accounts included in the schema:

| Role | Email | Password |
| --- | --- | --- |
| Customer | `customer@demo.com` | `customer123` |
| Representative | `rep@demo.com` | `rep123` |
| Admin | `admin@demo.com` | `admin123` |

### Environment

Set database credentials before starting Tomcat:

```bash
export DB_URL="jdbc:mysql://localhost:3306/cs336project?useSSL=false"
export DB_USER="root"
export DB_PASSWORD="your_mysql_password"
```

### Run

1. Import `cs336Sample` as a Dynamic Web Project in Eclipse or IntelliJ IDEA.
2. Attach the project to Apache Tomcat 9.
3. Start MySQL and load `database/schema.sql`.
4. Start Tomcat.
5. Open:

```text
http://localhost:8080/cs336Sample/login.jsp
```

## Demo Flow

| Role | Flow |
| --- | --- |
| Customer | Log in, search flights, book a seat, manage passengers, view reservations, cancel eligible bookings. |
| Representative | Log in, make/edit reservations, manage flights, review waitlists, answer customer questions. |
| Admin | Log in, manage users, review sales reports, inspect revenue, and identify top customers/flights. |

## Verification

Compile the shared database helper:

```bash
javac -d /tmp/airline-classes cs336Sample/src/main/java/com/cs336/pkg/ApplicationDB.java
```

Full JSP verification requires a running Tomcat server plus a reachable MySQL database loaded with `database/schema.sql`.

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Database connection fails | Confirm MySQL is running and `DB_URL`, `DB_USER`, and `DB_PASSWORD` match your local setup. |
| Login fails | Load `database/schema.sql` and use one of the demo accounts above. |
| MySQL driver missing | Keep the connector JAR in `WEB-INF/lib`. |
| JSP page shows SQL errors | Re-run the schema file and confirm the active database is `cs336project`. |

## Author

**Hasnain Shahzad**

- GitHub: [Hasnain3201](https://github.com/Hasnain3201)
- LinkedIn: [hasnain-shahzad-cs3201](https://www.linkedin.com/in/hasnain-shahzad-cs3201/)
