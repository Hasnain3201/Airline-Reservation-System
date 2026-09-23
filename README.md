<div align="center">

<img src="docs/screenshots/01-login.png" alt="Contrail check-in page with a route map, boarding-pass sign-in and split-flap departures board" width="100%">

# Contrail — Airline Reservation System

**Every journey begins at the gate.**

A Java / JSP / MySQL reservation system for passengers, customer representatives and administrators,
wrapped in a hand-crafted airport-terminal interface of boarding passes, split-flap boards and passport stamps.

<p>
  <img src="https://img.shields.io/badge/Java-JSP%20%2F%20JDBC-2F5A80?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java JSP JDBC">
  <img src="https://img.shields.io/badge/Apache-Tomcat%209-D8C4A2?style=for-the-badge&logo=apachetomcat&logoColor=1C2E40" alt="Apache Tomcat 9">
  <img src="https://img.shields.io/badge/MySQL-5.7%20%7C%208-5B8DBB?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/UI-Zero%20dependencies-1C2E40?style=for-the-badge" alt="Zero dependency UI">
</p>

[The design](#the-design) ·
[Tour](#a-tour-of-the-terminal) ·
[Features](#features-by-role) ·
[Getting started](#getting-started) ·
[Design system](#design-system-reference) ·
[Project structure](#project-structure)

</div>

---

## Overview

Contrail is a traditional server-rendered JSP application: customers search and book flights, representatives run the operations desk, and administrators watch the whole network from the control tower. Everything talks to MySQL over JDBC, and every page is rendered by Tomcat — there is no front-end build step, framework or package manager.

The interface is built around one idea: **the app should feel like walking through a quiet, sunlit airport terminal**. Instead of generic cards and dashboards, each screen borrows a real object from air travel — a boarding pass, a departures board, a luggage tag, an air-traffic-control flight strip — and turns it into UI.

| | |
| --- | --- |
| **3 roles** | Passenger, representative ("Ops desk") and admin ("Control tower") |
| **29 pages** | All redesigned on one shared design system |
| **1 stylesheet, 1 script** | `assets/contrail.css` and `assets/contrail.js`, no libraries |
| **Real data everywhere** | The departures board, seat maps and charts are all driven by live SQL |

---

## The design

### Visual language

Every UI element maps to something you'd find in an airport:

| Airport object | Where it lives in the app |
| --- | --- |
| **Boarding pass** with perforated stub and barcode | Sign-in form, flight results, trips, booking confirmation |
| **Split-flap departures board** (letters shuffle into place) | Login page, ops desk, airport boards, busiest-flights ranking, live clocks |
| **Wayfinding signs** with gate numbers | Main navigation; every page has a gate (`A1`–`A10` passengers, `B1`–`B8` reps, `C1`–`C7` admins) |
| **Luggage tags** | The signed-in user chip and the demo-account shortcuts on the login page |
| **Cabin portholes** with drifting clouds and a lowering shade | Passenger lounge hero |
| **Aircraft cabin seat map** | Seat selection for passengers and representatives |
| **Passport pages** with a machine-readable zone | Saved travelling companions |
| **Passport stamps** (`CONFIRMED`, `STANDBY`, `ARRIVED`, `SOLD OUT`) | Result pages, past trips, full flights |
| **ATC flight progress strips** | Reservation amendments and waitlists on the ops desk |
| **Route map** with planes gliding along great-circle arcs | Login page |
| **Runway centreline** | Page footer |
| **PA announcements** | Alerts and messages ("Attention passenger…") |

### Palette

| Swatch | Token | Hex | Used for |
| --- | --- | --- | --- |
| ![](https://img.shields.io/badge/-%20%20%20%20-E1EDF7?style=flat-square) | `--sky-100` | `#E1EDF7` | Wayfinding signs, highlights |
| ![](https://img.shields.io/badge/-%20%20%20%20-A7C8E3?style=flat-square) | `--sky-300` | `#A7C8E3` | Flight paths, seat outlines |
| ![](https://img.shields.io/badge/-%20%20%20%20-5B8DBB?style=flat-square) | `--sky-500` | `#5B8DBB` | Icons, italic headline accents |
| ![](https://img.shields.io/badge/-%20%20%20%20-FBF8F1?style=flat-square) | `--paper` | `#FBF8F1` | Page background (with a subtle paper grain) |
| ![](https://img.shields.io/badge/-%20%20%20%20-F2E9DA?style=flat-square) | `--sand-100` | `#F2E9DA` | Luggage tags, ticket stubs |
| ![](https://img.shields.io/badge/-%20%20%20%20-D8C4A2?style=flat-square) | `--sand-300` | `#D8C4A2` | Borders, perforations, runway |
| ![](https://img.shields.io/badge/-%20%20%20%20-1C2E40?style=flat-square) | `--ink` | `#1C2E40` | Text, split-flap boards, primary buttons |
| ![](https://img.shields.io/badge/-%20%20%20%20-F3E6CB?style=flat-square) | `--flap` | `#F3E6CB` | Split-flap letters |

Status colours are used sparingly: a muted green for confirmations, terracotta for stamps and errors, and amber for "boarding" remarks.

### Typography

| Role | Typeface | Why |
| --- | --- | --- |
| Headlines | **Fraunces** (soft, italic accents) | The warmth of a vintage travel poster |
| Interface | **Instrument Sans** | Clean and quiet, never competes with the headlines |
| Ticket data, codes, labels | **IBM Plex Mono** | The printed look of boarding passes and flight strips |

### Motion

Motion is small and purposeful: split-flap letters settle one tile at a time, planes follow dashed routes on the map, clouds drift past the portholes, stamps "thunk" onto result pages, and tickets tilt slightly on hover. Everything respects `prefers-reduced-motion`.

---

## A tour of the terminal

### Concourse A · Passengers

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/02-passenger-lounge.png" alt="Passenger lounge"></td>
    <td width="50%"><img src="docs/screenshots/03-search.png" alt="Flight search"></td>
  </tr>
  <tr>
    <td><b>A1 · Passenger lounge</b><br>A time-of-day greeting, a live flap clock, cabin windows with drifting clouds, your next boarding pass and gate-sign shortcuts.</td>
    <td><b>A2 · Search</b><br>A giant boarding-pass form. Airport codes update as you choose, the swap button spins, and timing preferences tuck into a drawer. Popular routes sit below.</td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/04-results.png" alt="Flight results"></td>
    <td><img src="docs/screenshots/05-seat-map.png" alt="Seat map"></td>
  </tr>
  <tr>
    <td><b>A3 · Results</b><br>Every flight is a boarding pass with the route arc, duration, seats left and a tear-off "Book seat" stub. Full flights offer the waitlist instead.</td>
    <td><b>A4 · Check-in</b><br>Pick a seat on a real cabin map (taken seats are hatched), choose a saved passenger or enter a new one, and pick a cabin. The seat readout flips as you choose.</td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/06-confirmation.png" alt="Booking confirmation"></td>
    <td><img src="docs/screenshots/07-my-trips.png" alt="My trips"></td>
  </tr>
  <tr>
    <td><b>A5 · Confirmation</b><br>A passport stamp lands on the page — <code>CONFIRMED</code>, <code>WAITLIST</code> or <code>DENIED</code> — above your printed boarding pass.</td>
    <td><b>A6 · My trips</b><br>Upcoming boarding passes with refund status and cancel actions; flown trips fade out and get an <code>ARRIVED</code> stamp.</td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/08-passengers.png" alt="Passengers"></td>
    <td><img src="docs/screenshots/09-info-desk.png" alt="Information desk"></td>
  </tr>
  <tr>
    <td><b>A8 · Passport control</b><br>Travelling companions as passport pages, complete with a machine-readable zone. Edit, save or remove in place.</td>
    <td><b>A9 · Information desk</b><br>Searchable questions and answers from the crew. Unanswered notes show as pending; "A10" is a postcard for asking a new one.</td>
  </tr>
</table>

### Concourse B · Operations desk (representatives)

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/10-ops-desk.png" alt="Ops desk"></td>
    <td width="50%"><img src="docs/screenshots/11-flight-strips.png" alt="Flight strips"></td>
  </tr>
  <tr>
    <td><b>B1 · Ops desk</b><br>Live counts for open questions, waitlists, upcoming flights and tickets, plus a "Next out" split-flap board. Tap a row to open that flight's waitlist.</td>
    <td><b>B4 · Amendments</b><br>A customer's tickets as ATC flight strips, colour-coded by cabin. Change class or seat inline, or strike a ticket from the manifest.</td>
  </tr>
  <tr>
    <td colspan="2"><img src="docs/screenshots/12-airport-board.png" alt="Airport board"></td>
  </tr>
  <tr>
    <td colspan="2"><b>B7 · Airport boards</b><br>Departures and arrivals for any airport in the network, straight off the split-flap board. Also on the desk: <b>B2</b> booking on behalf of a customer (with the same seat map), <b>B5</b> fleet, airport and schedule management, <b>B6</b> standby lists and <b>B8</b> the passenger inbox.</td>
  </tr>
</table>

### Concourse C · Control tower (administrators)

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/13-control-tower.png" alt="Control tower"></td>
    <td width="50%"><img src="docs/screenshots/14-sales-report.png" alt="Sales report"></td>
  </tr>
  <tr>
    <td><b>C1 · Control tower</b><br>Revenue, tickets, people and flights at a glance, with revenue by cabin drawn as striped bars.</td>
    <td><b>C3 · Monthly sales</b><br>Pick any month for total revenue, tickets sold, average ticket and a per-cabin breakdown.</td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/15-top-flyer.png" alt="Top flyer"></td>
    <td><img src="docs/screenshots/16-busiest-flights.png" alt="Busiest flights"></td>
  </tr>
  <tr>
    <td><b>C6 · Top flyer</b><br>The most valuable customer on a Sky Club membership card, next to a top-five leaderboard.</td>
    <td><b>C7 · Busiest routes</b><br>The ten most active flights on a split-flap board, with a load bar (tickets sold ÷ seat capacity).</td>
  </tr>
</table>

Also in the tower: **C2** customer and representative management, **C4** reservation lookup by flight or customer, and **C5** revenue detail by flight, airline or customer.

### On the go

The whole terminal is responsive. Navigation becomes a swipeable sign strip, tickets stack their stubs, and boards scroll sideways.

<p align="center">
  <img src="docs/screenshots/17-mobile-login.png" alt="Mobile check-in" width="280">
  &nbsp;&nbsp;&nbsp;
  <img src="docs/screenshots/18-mobile-lounge.png" alt="Mobile passenger lounge" width="280">
</p>

---

## Features by role

<details open>
<summary><b>Passengers</b> — Concourse A</summary>

- Sign in (or tap a demo luggage tag to autofill credentials).
- Search one-way or round-trip flights by origin, destination, date (with ±3 flexible days), airline, take-off and landing windows, and sort order.
- See seats remaining on every flight; full flights offer a waitlist.
- Book on a visual seat map with a saved or new passenger and a choice of Economy, Business or First (Business and First are cancellable).
- Review upcoming and past trips; cancel reservations.
- Get an in-app announcement when a seat opens on a waitlisted flight.
- Manage saved passengers (add, edit, remove).
- Browse and search the Q&A desk, and post new questions.

</details>

<details>
<summary><b>Customer representatives</b> — Concourse B</summary>

- Live desk overview: open questions, waitlist size, upcoming flights, tickets issued.
- Book flights on behalf of any customer, using their saved passengers and the cabin seat map.
- Amend reservations: change class (fares re-price automatically) or seat, or delete tickets.
- Manage airports, aircraft and the full flight schedule in editable tables.
- View standby lists per flight in request order.
- View departure and arrival boards for any airport.
- Answer customer questions from the inbox.

</details>

<details>
<summary><b>Administrators</b> — Concourse C</summary>

- Network overview: total revenue, tickets, customers, representatives and flights, plus revenue by cabin.
- Manage customers and representatives (add, edit, delete).
- Monthly sales report with a per-class breakdown.
- Reservation lookup by flight and/or customer.
- Revenue summaries by flight, airline or customer, with fare and fee totals.
- Top revenue-generating customer and leaderboard.
- Ten most active flights by tickets sold, with load factor.

</details>

---

## Getting started

### Prerequisites

| Tool | Version |
| --- | --- |
| JDK | 8 or newer (tested on 21) |
| Apache Tomcat | 9.x |
| MySQL | 5.7 or 8.x |
| MySQL Connector/J | Bundled in `cs336Sample/src/main/webapp/WEB-INF/lib/` |

### 1. Create the database

```bash
mysql -u root -p < database/schema.sql

# optional but recommended: more airports, future flights, tickets, a full flight
# (to demo the waitlist) and extra Q&A for a livelier terminal
mysql -u root -p < database/demo_data.sql
```

### 2. Point the app at MySQL

The app reads its connection from environment variables (defaults shown in `ApplicationDB.java`):

```bash
export DB_URL="jdbc:mysql://localhost:3306/cs336project?useSSL=false&allowPublicKeyRetrieval=true"
export DB_USER="root"
export DB_PASSWORD="your_mysql_password"
```

> **Tip:** With Tomcat you can put these lines in `$CATALINA_HOME/bin/setenv.sh` so they're picked up on every start.

### 3. Deploy

**Option A — IDE.** Import `cs336Sample` as a Dynamic Web Project in Eclipse or IntelliJ IDEA, attach it to Tomcat 9 and start the server.

**Option B — command line.** Build an exploded webapp and drop it into Tomcat:

```bash
APP=$CATALINA_HOME/webapps/cs336Sample
mkdir -p "$APP"
cp -r cs336Sample/src/main/webapp/. "$APP/"
javac -d "$APP/WEB-INF/classes" cs336Sample/src/main/java/com/cs336/pkg/ApplicationDB.java
$CATALINA_HOME/bin/startup.sh
```

### 4. Board

Open [http://localhost:8080/cs336Sample/](http://localhost:8080/cs336Sample/) and check in with one of the demo accounts. You can also tap a luggage tag on the login page to fill them in:

| Role | Email | Password | Lands on |
| --- | --- | --- | --- |
| Passenger | `customer@demo.com` | `customer123` | A1 · Passenger lounge |
| Representative | `rep@demo.com` | `rep123` | B1 · Ops desk |
| Administrator | `admin@demo.com` | `admin123` | C1 · Control tower |

`demo_data.sql` also adds passengers `priya@demo.com`, `mateo@demo.com` and `hana@demo.com` (passwords `priya123`, `mateo123`, `hana123`).

### Suggested demo flow

1. **Passenger:** search `EWR → LAX` → book seat on the cabin map → see the `CONFIRMED` stamp → open *My trips*.
2. **Passenger:** open flight `UA 1188 BOS → ORD` (it's full in the demo data) → join the waitlist.
3. **Representative:** check *Waitlist* for that flight → answer a question in the *Inbox* → amend a ticket on the flight strips.
4. **Admin:** open the *Control tower* → run the September 2026 *Sales* report → see who tops the *Top flyer* leaderboard.

---

## Design system reference

All pages share three small JSP fragments and a single stylesheet and script.

| File | What it does |
| --- | --- |
| `WEB-INF/jspf/head.jsp` | `<head>` contents: fonts, favicon, stylesheet and script |
| `WEB-INF/jspf/nav.jsp` | Wayfinding navigation, user luggage tag and logout (items depend on the `role` parameter) |
| `WEB-INF/jspf/sprite.jsp` | Inline SVG icon sprite (`<use href="#i-plane"/>`, `#i-luggage`, `#i-tower`, …) |
| `WEB-INF/jspf/foot.jsp` | Runway footer |
| `WEB-INF/jspf/util.jspf` | Helpers: HTML escaping, date/time/duration formatting, money, and boarding-pass route markup |
| `WEB-INF/jspf/seatmap.jspf` | The cabin seat map, shared by passenger and representative booking |
| `assets/contrail.css` | Design tokens and every component |
| `assets/contrail.js` | Split-flap animation, live clocks, greetings, login autofill, origin/destination swap, seat readout, confirm dialogs |

A typical page looks like this:

```jsp
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="My trips"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp">
  <jsp:param name="role" value="customer"/>
  <jsp:param name="active" value="trips"/>
</jsp:include>
<main class="shell">
  <header class="page-head">
    <div class="eyebrow"><span class="gate-sign">A6</span> Concourse A · Boarding passes</div>
    <h1>My <em>trips.</em></h1>
  </header>
  <%= routeHtml("EWR", "Newark", dep, "LAX", "Los Angeles", arr) %>
</main>
<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
```

### Components

| Class | Component |
| --- | --- |
| `.ticket`, `.ticket-main`, `.ticket-stub`, `.route`, `.barcode` | Boarding pass with notched perforation |
| `.board`, `[data-flap]`, `.flap-light`, `[data-clock]` | Split-flap board, tiles and live clock |
| `.wayfinder`, `.gate-sign`, `.gate-row` | Wayfinding navigation, gate badges and gate-sign action rows |
| `.luggage`, `.crew-tags` | Luggage tags |
| `.stamp` (`.is-round`, `.is-go`, `.is-stamp`, `.is-sand`, `.stamp-in`) | Grungy passport stamps |
| `.strip`, `.strip-tab` | ATC flight progress strips |
| `.fuselage`, `.seat-grid`, `.seat`, `.class-picker` | Cabin seat map and cabin selector |
| `.passport`, `.mrz` | Passport cards |
| `.cabin`, `.porthole` | Cabin wall with animated windows |
| `.announce` (`.is-go`, `.is-stamp`, `.is-amber`) | PA-style announcements |
| `.manifest`, `.table-wrap` | Manifest-style data tables |
| `.stat`, `.bars`, `.bar-row` | Stat tiles and striped bar charts |
| `.btn` (`.btn-ghost`, `.btn-sky`, `.btn-danger`, `.btn-sm`, `.btn-lg`) | Buttons |
| `.segmented`, `.check`, `.field` | Form controls |
| `.empty` | Illustrated empty states |

---

## Project structure

```text
.
├── database/
│   ├── schema.sql              # tables + base seed data and demo accounts
│   └── demo_data.sql           # optional extra airports, flights, tickets, Q&A
├── docs/
│   └── screenshots/            # images used in this README
├── cs336Sample/
│   └── src/main/
│       ├── java/com/cs336/pkg/
│       │   └── ApplicationDB.java      # JDBC connection helper (env-configurable)
│       └── webapp/
│           ├── assets/
│           │   ├── contrail.css        # design system
│           │   └── contrail.js         # interactions
│           ├── WEB-INF/
│           │   ├── jspf/               # shared head, nav, sprite, footer, helpers, seat map
│           │   ├── lib/                # MySQL Connector/J
│           │   └── web.xml
│           ├── login.jsp  checkLogin.jsp  logout.jsp
│           ├── customerHome.jsp  searchFlights.jsp  flightResults.jsp
│           ├── bookFlight.jsp  confirmBooking.jsp  viewReservations.jsp
│           ├── cancelReservation.jsp  cancelBooking.jsp  managePassengers.jsp
│           ├── browseQnA.jsp  postQuestion.jsp
│           ├── repHome.jsp  makeReservation.jsp  confirmBookingRep.jsp
│           ├── editReservation.jsp  viewFlights.jsp  viewWaitingList.jsp
│           ├── viewAirportFlights.jsp  answerQuestions.jsp
│           ├── adminHome.jsp  manageUsers.jsp  salesReport.jsp
│           └── reservationLookup.jsp  revenueSummary.jsp  topCustomer.jsp  activeFlights.jsp
└── README.md
```

### Data model

| Table | Holds |
| --- | --- |
| `CUSTOMER`, `CUSTOMERREP`, `ADMIN` | Accounts for each role |
| `AIRLINE`, `AIRPORT`, `AIRCRAFT` | The network and fleet (aircraft seat capacity drives the seat map) |
| `FLIGHT` | Scheduled flights between airports |
| `PASSENGER` | Travellers saved by a customer |
| `TICKET` | Booked seats with class, fare, fee and refundability |
| `WAITLIST` | Standby requests for full flights |
| `QUESTION` | Q&A between customers and representatives |

---

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Database connection fails | Confirm MySQL is running and `DB_URL`, `DB_USER` and `DB_PASSWORD` match your setup. |
| `Public Key Retrieval is not allowed` or auth errors on MySQL 8 | Add `allowPublicKeyRetrieval=true` to `DB_URL`, or create a user with `IDENTIFIED WITH mysql_native_password` (the bundled Connector/J is 5.1.x). |
| Login fails | Load `database/schema.sql` and use one of the demo accounts above. The login page will say so if the database is unreachable. |
| The departures board says "temporarily unavailable" | The login page couldn't query flights — check the database connection. |
| Few flights or empty "upcoming" lists | The base seed flights are in July 2026; load `database/demo_data.sql` for future flights. |
| Fonts look plain | Headline and mono fonts load from Google Fonts; offline, the app falls back to system serif and monospace fonts. |
| MySQL driver missing | Keep the connector JAR in `WEB-INF/lib`. |

---

## Author

**Hasnain Shahzad**

- GitHub: [Hasnain3201](https://github.com/Hasnain3201)
- LinkedIn: [hasnain-shahzad-cs3201](https://www.linkedin.com/in/hasnain-shahzad-cs3201/)

<p align="center"><sub>Please keep your belongings with you at all times.</sub></p>
