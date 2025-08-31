<%@ page import="java.sql.*,java.math.BigDecimal,javax.servlet.http.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

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

  if (reason == null && !waitlisted) {
%>
  <h3>🎉 Booking confirmed!</h3>
<%
  } else if (waitlisted) {
%>
  <h3>✈️ Flight Full — You've been waitlisted.</h3>
  <p>We'll notify you if a seat becomes available.</p>
<%
  } else {
%>
  <h3>⚠️ Booking failed:</h3>
  <p><%= reason %></p>
<%
  }
%>

<p>
  <a href="viewReservations.jsp">→ My Reservations</a> |
  <a href="searchFlights.jsp">← Search Flights</a> |
  <a href="logout.jsp">Logout</a>
</p>
