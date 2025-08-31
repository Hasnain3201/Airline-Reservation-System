# Airline-Reservation-System

# ✈️ Airline Reservation System  

A full-stack airline reservation system where users can search, filter, and book flights with real-time availability.  
Built with **Java, JSP/Servlets, MySQL**, and deployed on **Apache Tomcat**.  

---

## ✨ Features  
- Flight search & filtering  
- User accounts & role-based authentication (`admin`, `agent`, `customer`)  
- Booking creation, cancellation, and booking history  
- Inventory management & concurrency-safe seat allocation  
- Secure credential handling via environment variables  

---

## 🧱 Tech Stack  
- **Backend:** Java 17, JSP/Servlets (Tomcat 9)  
- **Frontend:** JSP, HTML, CSS  
- **Database:** MySQL 8, JDBC  
- **Build/CI:** Maven, GitHub Actions  

---

## 🗄️ Database Schema  
Core tables:  
- `users` – stores login credentials & roles  
- `flights` – flight metadata  
- `seats` – seat inventory per flight  
- `bookings` – reservations linked to users & seats  

See [`db/schema.sql`](db/schema.sql) and [`db/seed.sql`](db/seed.sql) for details.  

---

## 🚀 Getting Started  

### 1. Clone the repository  
```bash
git clone https://github.com/<your-username>/airline-reservation-system.git
cd airline-reservation-system
2. Create & seed the database
sql
Copy code
CREATE DATABASE airline CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'airline_user'@'%' IDENTIFIED BY 'airline_pass';
GRANT ALL PRIVILEGES ON airline.* TO 'airline_user'@'%';
FLUSH PRIVILEGES;

SOURCE db/schema.sql;
SOURCE db/seed.sql;
3. Configure environment variables
Copy .env.example to .env and set your values:

ini
Copy code
DB_URL=jdbc:mysql://localhost:3306/airline?useSSL=false&serverTimezone=UTC
DB_USER=airline_user
DB_PASS=airline_pass
4. Build & deploy
bash
Copy code
mvn clean package
cp target/airline-reservation-system.war $TOMCAT_HOME/webapps/
Then open: http://localhost:8080/airline-reservation-system

🧪 Demo Accounts
admin@demo.com / admin123

agent@demo.com / agent123

user@demo.com / user123

