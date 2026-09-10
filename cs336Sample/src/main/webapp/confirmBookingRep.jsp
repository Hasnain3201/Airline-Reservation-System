<%@ page import="java.sql.*,java.math.BigDecimal,javax.servlet.http.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>

<%
  HttpSession s = request.getSession(false);
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String repEmail = (String) session.getAttribute("userEmail");

  int flightID = Integer.parseInt(request.getParameter("flightID"));
  int cid = Integer.parseInt(request.getParameter("cid"));
  int passengerID = Integer.parseInt(request.getParameter("passengerID"));
  int legNumber = 1;
  String cls = request.getParameter("ticketClass");
  String seat = request.getParameter("seatNumber");

  BigDecimal totalFare;
  if ("First".equalsIgnoreCase(cls)) {
    totalFare = new BigDecimal("700.00");
  } else if ("Business".equalsIgnoreCase(cls)) {
    totalFare = new BigDecimal("400.00");
  } else {
    totalFare = new BigDecimal("100.00");
  }

  BigDecimal bookingFee = new BigDecimal("10.00");
  boolean cancellable = !"Economy".equalsIgnoreCase(cls);

  String reason = null;
  boolean confirmed = false;

  ApplicationDB db = new ApplicationDB();
  try (Connection conn = db.getConnection()) {
    conn.setAutoCommit(false);

    // 1. Check if seat already taken
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

    // 2. Check if passenger already booked on this flight
    if (reason == null) {
      try (PreparedStatement checkExisting = conn.prepareStatement(
        "SELECT COUNT(*) FROM TICKET WHERE flightID = ? AND passengerID = ?")) {
        checkExisting.setInt(1, flightID);
        checkExisting.setInt(2, passengerID);
        ResultSet checkRs = checkExisting.executeQuery();
        if (checkRs.next() && checkRs.getInt(1) > 0) {
          reason = "This passenger is already booked on this flight.";
        }
      }
    }

    // 3. Insert ticket if no error
    if (reason == null) {
      try (PreparedStatement pst = conn.prepareStatement(
        "INSERT INTO TICKET(totalFare, bookingFee, purchaseDateTime, `class`, cancellable, " +
        "cid, flightID, passengerID, legNumber, seatNumber) " +
        "VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?)")) {
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
        confirmed = true;
      }
    }

    conn.commit();
  } catch (Exception err) {
    if (reason == null) reason = "Error: " + err.getMessage();
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Reservation result"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="make"/></jsp:include>

<main class="shell">
  <section class="result-hero">
<% if (confirmed) { %>
    <div class="stamp is-go is-round stamp-in">Issued<small>Ops desk &middot; B3</small></div>
    <h1>Reservation <em>confirmed.</em></h1>
    <p class="lede"><%= esc(cls) %> seat <%= esc(seat) %> on flight #<%= flightID %> is booked for customer #<%= cid %>. Total charged: <%= money(totalFare.add(bookingFee).doubleValue()) %><%= cancellable ? " (cancellable)" : " (non-refundable)" %>.</p>
<% } else { %>
    <div class="stamp is-stamp is-round stamp-in">Denied<small>Ops desk &middot; B3</small></div>
    <h1>Reservation <em>failed.</em></h1>
    <p class="lede"><%= esc(reason) %></p>
<% } %>
    <div class="btn-row">
      <a class="btn" href="makeReservation.jsp?cid=<%= cid %>&amp;flightID=<%= flightID %>"><svg class="ico"><use href="#i-back"/></svg> Back to reservation page</a>
      <a class="btn btn-ghost" href="editReservation.jsp?cid=<%= cid %>"><svg class="ico"><use href="#i-edit"/></svg> View customer's tickets</a>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
