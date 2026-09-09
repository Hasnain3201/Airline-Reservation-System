<%@ page language="java" import="javax.servlet.http.*, java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) s.getAttribute("userEmail");

  int cid = -1;
  String fname = null;
  int upcomingCount = 0;
  int passengerCount = 0;
  String[] next = null;
  Timestamp nextDep = null, nextArr = null;

  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement getCid = conn.prepareStatement("SELECT cid, fname FROM CUSTOMER WHERE email = ?")) {
    getCid.setString(1, email);
    ResultSet rs = getCid.executeQuery();
    if (rs.next()) {
      cid = rs.getInt("cid");
      fname = rs.getString("fname");
    }

    if (cid > 0) {
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT COUNT(*) FROM TICKET t JOIN FLIGHT f ON t.flightID = f.flightID WHERE t.cid = ? AND f.departureTime >= NOW()")) {
        ps.setInt(1, cid);
        ResultSet r = ps.executeQuery();
        if (r.next()) upcomingCount = r.getInt(1);
      }
      try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM PASSENGER WHERE createdByCID = ?")) {
        ps.setInt(1, cid);
        ResultSet r = ps.executeQuery();
        if (r.next()) passengerCount = r.getInt(1);
      }
      try (PreparedStatement ps = conn.prepareStatement(
             "SELECT f.airlineID, a.name AS airline, f.flightNum, f.departureTime, f.arrivalTime, " +
             "ap1.airportID AS depCode, ap1.city AS depCity, ap2.airportID AS arrCode, ap2.city AS arrCity, " +
             "t.class, t.seatNumber, p.fname, p.lname " +
             "FROM TICKET t JOIN FLIGHT f ON t.flightID = f.flightID " +
             "JOIN AIRLINE a ON f.airlineID = a.airlineID " +
             "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
             "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
             "JOIN PASSENGER p ON t.passengerID = p.passengerID " +
             "WHERE t.cid = ? AND f.departureTime >= NOW() ORDER BY f.departureTime LIMIT 1")) {
        ps.setInt(1, cid);
        ResultSet r = ps.executeQuery();
        if (r.next()) {
          next = new String[] {
            r.getString("airlineID"), r.getString("airline"), r.getString("flightNum"),
            r.getString("depCode"), r.getString("depCity"), r.getString("arrCode"), r.getString("arrCity"),
            r.getString("class"), r.getString("seatNumber"), r.getString("fname") + " " + r.getString("lname")
          };
          nextDep = r.getTimestamp("departureTime");
          nextArr = r.getTimestamp("arrivalTime");
        }
      }
    }
  } catch (Exception err) {
    // fail silently
  }

  boolean showAlert = false;
  if (cid > 0 && s.getAttribute("waitlistAlertFor_" + cid) != null) {
    showAlert = true;
    s.removeAttribute("waitlistAlertFor_" + cid);
  }

  String displayName = fname != null ? fname : email;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Passenger lounge"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="home"/></jsp:include>

<main class="shell">
  <section class="hello">
    <div class="reveal">
      <div class="eyebrow"><span class="gate-sign">A1</span> Concourse A &middot; Passenger lounge</div>
      <h1><span data-greeting>Welcome back</span>,<br><em><%= esc(displayName) %>.</em></h1>
      <p class="lede">Your boarding passes, travelling companions and questions for the information desk are all waiting right here. Where shall we fly next?</p>
      <div class="clock">
        <span class="caps">Local time</span>
        <span class="flap flap-light flap-lg" data-clock>00:00</span>
        <span class="pill"><%= upcomingCount %> upcoming <%= upcomingCount == 1 ? "trip" : "trips" %></span>
        <span class="pill pill-sand"><%= passengerCount %> saved <%= passengerCount == 1 ? "passenger" : "passengers" %></span>
      </div>
    </div>
    <div class="cabin reveal reveal-3" aria-hidden="true">
      <div class="porthole is-dawn"><div class="shade"></div><div class="cloud-drift"><span></span><span></span><span></span></div><div class="glare"></div></div>
      <div class="porthole"><div class="shade"></div><div class="cloud-drift"><span></span><span></span><span></span></div><div class="wing"></div><div class="glare"></div></div>
      <div class="porthole is-dusk"><div class="shade"></div><div class="cloud-drift"><span></span><span></span><span></span></div><div class="glare"></div></div>
    </div>
  </section>

<% if (showAlert) { %>
  <div class="announce is-go reveal">
    <svg class="ico"><use href="#i-megaphone"/></svg>
    <div><strong>Attention passenger</strong><p>A seat has opened up on a flight you're waitlisted for. Act fast to book it.</p></div>
  </div>
<% } %>

  <section class="section grid grid-aside">
    <div class="reveal reveal-2">
      <div class="section-title">
        <h2>Your next <em>departure</em></h2>
        <a class="caps" href="viewReservations.jsp">All trips &rarr;</a>
      </div>
<% if (next != null) { %>
      <a class="ticket" href="viewReservations.jsp">
        <div class="ticket-main">
          <div class="ticket-top">
            <%= carrierHtml(next[0], next[1], "Flight " + esc(next[0]) + " " + esc(next[2])) %>
            <span class="pill pill-go">Confirmed</span>
          </div>
          <%= routeHtml(next[3], next[4], nextDep, next[5], next[6], nextArr) %>
          <div class="ticket-meta">
            <div class="meta-item"><span class="label">Passenger</span><span class="val"><%= esc(next[9]) %></span></div>
            <div class="meta-item"><span class="label">Class</span><span class="val"><%= esc(next[7]) %></span></div>
            <div class="meta-item"><span class="label">Seat</span><span class="val"><%= esc(next[8]) %></span></div>
            <div class="meta-item"><span class="label">Boarding</span><span class="val"><%= fmtTime(new java.util.Date(nextDep.getTime() - 40L * 60000L)) %></span></div>
          </div>
        </div>
        <div class="ticket-stub">
          <div>
            <span class="label">Seat</span>
            <div class="price"><%= esc(next[8]) %></div>
          </div>
          <div>
            <span class="label">Gate closes</span>
            <div class="mono" style="font-weight:600"><%= fmtTime(new java.util.Date(nextDep.getTime() - 15L * 60000L)) %></div>
          </div>
          <div class="barcode"></div>
        </div>
      </a>
<% } else { %>
      <div class="empty">
        <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
          <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
          <g transform="translate(46 26)"><use href="#i-cloud" width="46" height="30" style="color:#E1EDF7"/></g>
          <g transform="translate(92 14)"><use href="#i-cloud" width="30" height="20" style="color:#EEF5FB"/></g>
          <g transform="translate(66 44) rotate(90 14 14)" fill="#7FAAD0"><use href="#i-plane" width="28" height="28"/></g>
        </svg>
        <h3>Clear skies ahead</h3>
        <p>No upcoming departures on your itinerary yet. The whole map is open.</p>
        <a class="btn" href="searchFlights.jsp" style="margin-top:10px">Find a flight <svg class="ico ico-go"><use href="#i-arrow"/></svg></a>
      </div>
<% } %>
    </div>

    <div class="reveal reveal-3">
      <div class="section-title">
        <h2>Where <em>to?</em></h2>
        <span class="caps">Follow the signs</span>
      </div>
      <nav class="gates">
        <a class="gate-row" href="searchFlights.jsp">
          <span class="gate-sign">A2</span>
          <span><span class="gr-title"><svg class="ico"><use href="#i-takeoff"/></svg>Search flights</span><span class="gr-sub">Routes, dates &amp; flexible days</span></span>
          <span class="gr-status pill pill-go">Open</span>
          <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
        </a>
        <a class="gate-row" href="viewReservations.jsp">
          <span class="gate-sign">A6</span>
          <span><span class="gr-title"><svg class="ico"><use href="#i-luggage"/></svg>My trips</span><span class="gr-sub">Boarding passes &amp; history</span></span>
          <span class="gr-status pill"><%= upcomingCount %> ahead</span>
          <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
        </a>
        <a class="gate-row" href="managePassengers.jsp">
          <span class="gate-sign">A8</span>
          <span><span class="gr-title"><svg class="ico"><use href="#i-passport"/></svg>Passengers</span><span class="gr-sub">Travel companions on file</span></span>
          <span class="gr-status pill pill-sand"><%= passengerCount %> saved</span>
          <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
        </a>
        <a class="gate-row" href="browseQnA.jsp">
          <span class="gate-sign">A9</span>
          <span><span class="gr-title"><svg class="ico"><use href="#i-info"/></svg>Information desk</span><span class="gr-sub">Browse answers from our crew</span></span>
          <span class="gr-status pill pill-sand">Staffed</span>
          <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
        </a>
        <a class="gate-row" href="postQuestion.jsp">
          <span class="gate-sign">A10</span>
          <span><span class="gr-title"><svg class="ico"><use href="#i-chat"/></svg>Ask a question</span><span class="gr-sub">A representative will reply</span></span>
          <span class="gr-status pill pill-sand">Open</span>
          <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
        </a>
      </nav>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
