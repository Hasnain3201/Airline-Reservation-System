<%@ page session="true" import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  String email = (String) session.getAttribute("userEmail");
  if (email == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  ApplicationDB db = new ApplicationDB();
  int cid = -1;

  String tripSelect =
    "SELECT t.ticketID, f.flightNum, f.airlineID, a.name AS airline, " +
    "ap1.airportID AS depCode, ap1.city AS depCity, f.departureTime, " +
    "ap2.airportID AS arrCode, ap2.city AS arrCity, f.arrivalTime, " +
    "t.class, t.seatNumber, t.cancellable, t.totalFare, t.bookingFee, p.fname, p.lname " +
    "FROM TICKET t " +
    "JOIN FLIGHT f ON t.flightID = f.flightID " +
    "JOIN AIRLINE a ON f.airlineID = a.airlineID " +
    "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
    "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
    "JOIN PASSENGER p ON t.passengerID = p.passengerID ";

  try (Connection conn = db.getConnection()) {
    try (PreparedStatement getCid = conn.prepareStatement("SELECT cid FROM CUSTOMER WHERE email = ?")) {
      getCid.setString(1, email);
      ResultSet rs = getCid.executeQuery();
      if (rs.next()) cid = rs.getInt("cid");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="My trips"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="trips"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A6</span> Concourse A &middot; Baggage &amp; boarding passes</div>
      <h1>My <em>trips.</em></h1>
      <p class="lede">Every boarding pass you hold, from tomorrow's early departure to the ones already stamped in your passport.</p>
    </div>
    <div class="head-actions">
      <a class="btn" href="searchFlights.jsp"><svg class="ico"><use href="#i-plus"/></svg> Book another</a>
    </div>
  </header>

  <section class="reveal reveal-2">
    <div class="section-title">
      <h2>Upcoming</h2>
      <span class="caps">Ready for boarding</span>
    </div>
    <div class="ticket-list">
<%
    try (PreparedStatement stmt = conn.prepareStatement(
         tripSelect + "WHERE t.cid = ? AND f.departureTime >= NOW() ORDER BY f.departureTime")) {
      stmt.setInt(1, cid);
      ResultSet rs = stmt.executeQuery();
      boolean any = false;
      while (rs.next()) {
        any = true;
        boolean refundable = rs.getBoolean("cancellable");
        Timestamp dep = rs.getTimestamp("departureTime");
%>
      <article class="ticket is-hoverable">
        <div class="ticket-main">
          <div class="ticket-top">
            <%= carrierHtml(rs.getString("airlineID"), rs.getString("airline"), "Flight " + esc(rs.getString("airlineID")) + " " + rs.getInt("flightNum") + " &middot; Ticket #" + rs.getInt("ticketID")) %>
            <span class="pill <%= refundable ? "pill-go" : "pill-sand" %>"><%= refundable ? "Refundable" : "Non-refundable" %></span>
          </div>
          <%= routeHtml(rs.getString("depCode"), rs.getString("depCity"), dep, rs.getString("arrCode"), rs.getString("arrCity"), rs.getTimestamp("arrivalTime")) %>
          <div class="ticket-meta">
            <div class="meta-item"><span class="label">Passenger</span><span class="val"><%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></span></div>
            <div class="meta-item"><span class="label">Class</span><span class="val"><%= esc(rs.getString("class")) %></span></div>
            <div class="meta-item"><span class="label">Seat</span><span class="val"><%= esc(rs.getString("seatNumber")) %></span></div>
            <div class="meta-item"><span class="label">Boarding</span><span class="val"><%= fmtTime(new java.util.Date(dep.getTime() - 40L * 60000L)) %></span></div>
          </div>
        </div>
        <div class="ticket-stub">
          <div>
            <span class="label">Paid</span>
            <div class="price"><%= money(rs.getDouble("totalFare") + rs.getDouble("bookingFee")) %></div>
          </div>
          <div class="barcode"></div>
          <a class="btn btn-danger btn-sm" href="cancelReservation.jsp?ticketID=<%= rs.getInt("ticketID") %>"
             data-confirm="<%= refundable ? "Cancel this reservation?" : "This fare is non-refundable. Cancel this reservation anyway?" %>">
            <svg class="ico"><use href="#i-trash"/></svg> Cancel trip
          </a>
        </div>
      </article>
<%
      }
      if (!any) {
%>
      <div class="empty">
        <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
          <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
          <g transform="translate(58 28)" fill="#C2A67B"><use href="#i-luggage" width="44" height="44"/></g>
        </svg>
        <h3>Bags packed, nowhere to go</h3>
        <p>No upcoming reservations. Your next adventure is a search away.</p>
        <a class="btn" href="searchFlights.jsp" style="margin-top:10px">Search flights <svg class="ico ico-go"><use href="#i-arrow"/></svg></a>
      </div>
<%
      }
    }
%>
    </div>
  </section>

  <section class="section reveal reveal-3">
    <div class="section-title">
      <h2>Past <em>journeys</em></h2>
      <span class="caps">Stamped &amp; flown</span>
    </div>
    <div class="ticket-list">
<%
    try (PreparedStatement stmt2 = conn.prepareStatement(
         tripSelect + "WHERE t.cid = ? AND f.departureTime < NOW() ORDER BY f.departureTime DESC")) {
      stmt2.setInt(1, cid);
      ResultSet rs2 = stmt2.executeQuery();
      boolean any = false;
      while (rs2.next()) {
        any = true;
%>
      <article class="ticket is-past">
        <div class="ticket-main">
          <div class="ticket-top">
            <%= carrierHtml(rs2.getString("airlineID"), rs2.getString("airline"), "Flight " + esc(rs2.getString("airlineID")) + " " + rs2.getInt("flightNum")) %>
            <span class="pill pill-sand no-dot">Flown</span>
          </div>
          <%= routeHtml(rs2.getString("depCode"), rs2.getString("depCity"), rs2.getTimestamp("departureTime"), rs2.getString("arrCode"), rs2.getString("arrCity"), rs2.getTimestamp("arrivalTime")) %>
          <div class="ticket-meta">
            <div class="meta-item"><span class="label">Passenger</span><span class="val"><%= esc(rs2.getString("fname")) %> <%= esc(rs2.getString("lname")) %></span></div>
            <div class="meta-item"><span class="label">Class</span><span class="val"><%= esc(rs2.getString("class")) %></span></div>
            <div class="meta-item"><span class="label">Seat</span><span class="val"><%= esc(rs2.getString("seatNumber")) %></span></div>
            <div class="meta-item"><span class="label">Paid</span><span class="val"><%= money(rs2.getDouble("totalFare") + rs2.getDouble("bookingFee")) %></span></div>
          </div>
        </div>
        <div class="ticket-stub" style="align-items:center; justify-content:center">
          <div class="stamp is-round">Arrived<small><%= esc(rs2.getString("arrCode")) %></small></div>
        </div>
      </article>
<%
      }
      if (!any) {
%>
      <div class="empty">
        <h3>A blank passport</h3>
        <p>Flights you've taken will be stamped here.</p>
      </div>
<%
      }
    }
  }
%>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
