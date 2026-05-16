# Airline Reservation System

<p align="center">
  <strong>A JSP and MySQL airline reservation platform with customer, representative, and administrator workflows.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Backend-Java-007396?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java">
  <img src="https://img.shields.io/badge/Web-JSP%20%2F%20Servlets-4b5563?style=for-the-badge" alt="JSP and Servlets">
  <img src="https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/Server-Tomcat-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black" alt="Tomcat">
</p>

## Preview

Screenshots have not been added yet because this workspace does not include the required Tomcat server, MySQL instance, or course database schema. After deploying locally, add screenshots to `screenshots/` such as `screenshots/login.png`, `screenshots/search-flights.png`, and `screenshots/reservations.png`.

## Overview

Airline Reservation System is a Java web application for searching flights, booking reservations, managing customer records, answering customer questions, and reviewing sales and revenue information. It is structured as a traditional JSP application intended to run on Apache Tomcat with a MySQL database.

The project keeps the original course-style JSP structure while improving the database configuration so credentials are no longer hardcoded in source code.

## Key Features

- Role-based login for customers, customer representatives, and administrators.
- Customer flight search, reservation booking, cancellation, and reservation history.
- Customer question posting and Q&A browsing.
- Representative tools for managing flights, passengers, reservations, waitlists, and customer questions.
- Administrator tools for user management, sales reports, revenue summaries, and top-customer views.
- Shared JDBC connection helper for database access.

## Tech Stack

| Area | Technology |
| --- | --- |
| Backend | Java, JSP, JDBC |
| Server | Apache Tomcat 9 recommended |
| Database | MySQL |
| Driver | MySQL Connector/J (`WEB-INF/lib`) |
| Frontend | JSP, HTML |

## Project Structure

```text
.
├── cs336Sample/
│   ├── src/main/java/com/cs336/pkg/
│   │   └── ApplicationDB.java
│   └── src/main/webapp/
│       ├── WEB-INF/
│       │   ├── lib/
│       │   └── web.xml
│       ├── login.jsp
│       ├── searchFlights.jsp
│       ├── makeReservation.jsp
│       ├── adminHome.jsp
│       └── repHome.jsp
└── README.md
```

## Getting Started

### Prerequisites

- JDK 8 or newer
- Apache Tomcat 9
- MySQL 5.7+ or MySQL 8
- The course/project database schema loaded into a database named `cs336project`

> The SQL schema is not included in this repository. The JSP pages expect tables such as `CUSTOMER`, `ADMIN`, `CUSTOMERREP`, `FLIGHT`, `TICKET`, and related reservation tables.

### Database Configuration

Set database credentials through environment variables before starting Tomcat:

```bash
export DB_URL="jdbc:mysql://localhost:3306/cs336project?useSSL=false"
export DB_USER="root"
export DB_PASSWORD="your_mysql_password"
```

If these variables are not set, the app defaults to:

| Variable | Default |
| --- | --- |
| `DB_URL` | `jdbc:mysql://localhost:3306/cs336project?useSSL=false` |
| `DB_USER` | `root` |
| `DB_PASSWORD` | empty string |

### Run Locally

1. Import `cs336Sample` as a Dynamic Web Project in Eclipse or IntelliJ IDEA.
2. Configure Apache Tomcat 9 as the application server.
3. Confirm the MySQL connector JAR exists under `cs336Sample/src/main/webapp/WEB-INF/lib/`.
4. Load the required MySQL schema and seed data.
5. Start Tomcat with the database environment variables set.
6. Open the application:

```text
http://localhost:8080/cs336Sample/login.jsp
```

## Demo Flow

| Role | Suggested Flow |
| --- | --- |
| Customer | Log in, search flights, book a reservation, view reservations, cancel an eligible booking. |
| Representative | Log in, review active flights, manage passengers, view reservations, answer customer questions. |
| Administrator | Log in, manage users, review sales reports, inspect revenue summaries, view top customers. |

Login credentials depend on the users seeded into your local MySQL database.

## Verification

The shared database helper can be compiled independently:

```bash
javac -d /tmp/airline-classes cs336Sample/src/main/java/com/cs336/pkg/ApplicationDB.java
```

Full JSP verification requires Tomcat plus the project database schema.

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Database connection fails | Confirm MySQL is running and `DB_URL`, `DB_USER`, and `DB_PASSWORD` are correct. |
| `ClassNotFoundException` for MySQL driver | Ensure the connector JAR is in `WEB-INF/lib`. |
| Login always fails | Confirm the local database has matching users in the role tables. |
| JSP pages show SQL errors | Confirm the course schema matches the table and column names used by the JSP pages. |

## Future Improvements

- Add the database schema and sample seed data if allowed by course/project requirements.
- Add screenshots after deploying against a local database.
- Move repeated JSP database logic into servlet/controller classes.
- Add server-side validation and clearer error pages.

## Author

**Hasnain Shahzad**

- GitHub: [Hasnain3201](https://github.com/Hasnain3201)
- LinkedIn: [hasnain-shahzad-cs3201](https://www.linkedin.com/in/hasnain-shahzad-cs3201/)
