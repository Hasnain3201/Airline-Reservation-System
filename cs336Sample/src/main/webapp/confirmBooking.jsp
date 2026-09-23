<%@ page import="java.sql.*,java.math.BigDecimal,javax.servlet.http.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  int    flightID    = Integer.parseInt(request.getParameter("flightID"));
  int    legNumber   = Integer.parseInt(request.getParameter("legNumber"));
  String cls         = request.getParameter("ticketClass");
  String seat        = request.getParameter("seatNumber");
  String idNumber    = request.getParameter("idNumber");
  String firstName   = request.getParameter("p_fname");
  String lastName    = request.getParameter("p_lname");
  java.sql.Date dob  = java.sql.Date.valueOf(request.getParameter("p_dob"));
  String email       = (String) session.getAttribute("userEmail");

  BigDecimal totalFare  = new BigDecimal("100.00");
  BigDecimal bookingFee = new BigDecimal("10.00");
  boolean cancellable   = !"Economy".equals(cls);

  String reason = null;
  boolean waitlisted = false;

  ApplicationDB db = new ApplicationDB();
  try (Connection conn = db.getConnection()) {
    conn.setAutoCommit(false);

    int cid = -1;
    try (PreparedStatement getCid = conn.prepareStatement(
      "SELECT cid FROM CUSTOMER WHERE email = ?")) {
      getCid.setString(1, email);
      ResultSet rs = getCid.executeQuery();
      if (rs.next()) cid = rs.getInt("cid");
    }

    // 1. Get or insert passenger
    int passengerID = -1;
    try (PreparedStatement chkPass = conn.prepareStatement(
      "SELECT passengerID FROM PASSENGER WHERE idNumber = ?")) {
      chkPass.setString(1, idNumber);
      ResultSet rs = chkPass.executeQuery();
      if (rs.next()) {
        passengerID = rs.getInt("passengerID");
      }
    }

    if (passengerID == -1) {
      try (PreparedStatement insPass = conn.prepareStatement(
        "INSERT INTO PASSENGER(fname,mname,lname,idNumber,dob,createdByCID) " +
        "VALUES(?,NULL,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
        insPass.setString(1, firstName);
        insPass.setString(2, lastName);
        insPass.setString(3, idNumber);
        insPass.setDate(4, dob);
        insPass.setInt(5, cid);
        insPass.executeUpdate();

        ResultSet keys = insPass.getGeneratedKeys();
        if (keys.next()) passengerID = keys.getInt(1);
      }
    }

    if (passengerID == -1) {
      reason = "Could not locate or create passenger.";
    }

    // 2. Check duplicate ticket for same passenger on same flight
    if (reason == null) {
      try (PreparedStatement dup = conn.prepareStatement(
        "SELECT COUNT(*) FROM TICKET WHERE flightID = ? AND passengerID = ?")) {
        dup.setInt(1, flightID);
        dup.setInt(2, passengerID);
        ResultSet dupRs = dup.executeQuery();
        if (dupRs.next() && dupRs.getInt(1) > 0) {
          reason = "Passenger already has a ticket for this flight.";
        }
      }
    }

    // 3. Check if seat already taken
    if (reason == null) {
      try (PreparedStatement chkSeat = conn.prepareStatement(
        "SELECT COUNT(*) FROM TICKET WHERE flightID = ? AND legNumber = ? AND seatNumber = ?")) {
        chkSeat.setInt(1, flightID);
        chkSeat.setInt(2, legNumber);
        chkSeat.setString(3, seat);
        ResultSet rs = chkSeat.executeQuery();
        if (rs.next() && rs.getInt(1) > 0) {
          reason = "Seat " + seat + " is already booked.";
        }
      }
    }

    // 4. Check seat capacity
    int capacity = 0;
    try (PreparedStatement getCap = conn.prepareStatement(
      "SELECT a.seatCapacity FROM FLIGHT f JOIN AIRCRAFT a ON f.aircraftID = a.aircraftID WHERE f.flightID = ?")) {
      getCap.setInt(1, flightID);
      ResultSet rs = getCap.executeQuery();
      if (rs.next()) capacity = rs.getInt("seatCapacity");
    }

    // 5. Count current tickets
    int ticketCount = 0;
    try (PreparedStatement countTickets = conn.prepareStatement(
      "SELECT COUNT(*) FROM TICKET WHERE flightID = ?")) {
      countTickets.setInt(1, flightID);
      ResultSet rs = countTickets.executeQuery();
      if (rs.next()) ticketCount = rs.getInt(1);
    }

    // 6. Handle waitlisting
    if (ticketCount >= capacity && reason == null) {
      waitlisted = true;
      if (cid > 0) {
        try (PreparedStatement insW = conn.prepareStatement(
          "INSERT INTO WAITLIST(cid, flightID, dateOfRequest) VALUES(?,?,NOW())")) {
          insW.setInt(1, cid);
          insW.setInt(2, flightID);
          insW.executeUpdate();
        }
      } else {
        reason = "Could not retrieve customer ID.";
      }
    }

    // 7. Insert ticket if not waitlisted
    if (!waitlisted && reason == null) {
      try (PreparedStatement pst = conn.prepareStatement(
        "INSERT INTO TICKET(totalFare,bookingFee,purchaseDateTime,`class`,cancellable," +
        "cid,flightID,passengerID,legNumber,seatNumber) " +
        "VALUES(?,?,NOW(),?,?,?,?,?,?,?)")) {
        pst.setBigDecimal(1, totalFare);
        pst.setBigDecimal(2, bookingFee);
        pst.setString(3, cls);
        pst.setBoolean(4, cancellable);
        pst.setInt(5, cid);
        pst.setInt(6, flightID);
        pst.setInt(7, passengerID);
        pst.setInt(8, legNumber);
        pst.setString(9, seat);
        pst.executeUpdate();
      }

      // ✅ REMOVE from waitlist if they were previously on it
      try (PreparedStatement delWait = conn.prepareStatement(
        "DELETE FROM WAITLIST WHERE cid = ? AND flightID = ?")) {
        delWait.setInt(1, cid);
        delWait.setInt(2, flightID);
        delWait.executeUpdate();
      }
    }

    conn.commit();
  } catch (Exception err) {
    if (reason == null) reason = "Error: " + err.getMessage();
  }

  String[] fl = null;
  Timestamp flDep = null, flArr = null;
  try (Connection conn = db.getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT f.airlineID, a.name AS airline, f.flightNum, f.departureTime, f.arrivalTime, " +
         "ap1.airportID AS depCode, ap1.city AS depCity, ap2.airportID AS arrCode, ap2.city AS arrCity " +
         "FROM FLIGHT f JOIN AIRLINE a ON f.airlineID = a.airlineID " +
         "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
         "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID WHERE f.flightID = ?")) {
    ps.setInt(1, flightID);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      fl = new String[] { rs.getString("airlineID"), rs.getString("airline"), rs.getString("flightNum"),
                          rs.getString("depCode"), rs.getString("depCity"), rs.getString("arrCode"), rs.getString("arrCity") };
      flDep = rs.getTimestamp("departureTime");
      flArr = rs.getTimestamp("arrivalTime");
    }
  } catch (Exception ignored) {
  }

  boolean confirmed = reason == null && !waitlisted;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Booking status"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="trips"/></jsp:include>

<main class="shell">
  <section class="result-hero">
<% if (confirmed) { %>
    <div class="stamp is-go is-round stamp-in">Confirmed<small>Contrail &middot; T1</small></div>
    <h1>You're on the <em>manifest.</em></h1>
    <p class="lede">Your seat is locked in. Keep this boarding pass handy &mdash; it's also waiting under My trips.</p>
<% } else if (waitlisted) { %>
    <div class="stamp is-sand is-round stamp-in">Waitlist<small>Standby</small></div>
    <h1>Flight full &mdash; you're on <em>standby.</em></h1>
    <p class="lede">We'll notify you in the lounge if a seat becomes available on this flight.</p>
<% } else { %>
    <div class="stamp is-stamp is-round stamp-in">Denied<small>Gate agent</small></div>
    <h1>We couldn't <em>book</em> that seat.</h1>
    <p class="lede"><%= esc(reason) %></p>
<% } %>
  </section>

<% if (fl != null) { %>
  <article class="ticket reveal reveal-2" style="max-width:900px; margin:0 auto">
    <div class="ticket-main">
      <div class="ticket-top">
        <%= carrierHtml(fl[0], fl[1], "Flight " + esc(fl[0]) + " " + esc(fl[2])) %>
        <span class="pill <%= confirmed ? "pill-go" : waitlisted ? "pill-sand" : "pill-stamp" %>"><%= confirmed ? "Confirmed" : waitlisted ? "Waitlisted" : "Not booked" %></span>
      </div>
      <%= routeHtml(fl[3], fl[4], flDep, fl[5], fl[6], flArr) %>
      <div class="ticket-meta">
        <div class="meta-item"><span class="label">Passenger</span><span class="val"><%= esc(firstName) %> <%= esc(lastName) %></span></div>
        <div class="meta-item"><span class="label">Class</span><span class="val"><%= esc(cls) %></span></div>
        <div class="meta-item"><span class="label">Seat</span><span class="val"><%= confirmed ? esc(seat) : "--" %></span></div>
        <div class="meta-item"><span class="label">Refund</span><span class="val"><%= cancellable ? "Yes" : "No" %></span></div>
      </div>
    </div>
    <div class="ticket-stub">
      <div>
        <span class="label">Total paid</span>
        <div class="price"><%= confirmed ? money(totalFare.add(bookingFee).doubleValue()) : "$0.00" %><small>Fare <%= money(totalFare.doubleValue()) %> + fee <%= money(bookingFee.doubleValue()) %></small></div>
      </div>
      <div class="barcode"></div>
    </div>
  </article>
<% } %>

  <div class="btn-row reveal reveal-3" style="justify-content:center; margin-top:34px">
    <a class="btn" href="viewReservations.jsp"><svg class="ico"><use href="#i-luggage"/></svg> My trips</a>
    <a class="btn btn-ghost" href="searchFlights.jsp"><svg class="ico"><use href="#i-search"/></svg> Search flights</a>
  </div>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
