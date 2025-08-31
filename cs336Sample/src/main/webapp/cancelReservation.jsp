<%@ page session="true" import="java.sql.*" %>
<%@ page import="java.util.Set, java.util.HashSet" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  String email = (String) session.getAttribute("userEmail");
  if (email == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String ticketID = request.getParameter("ticketID");
  if (ticketID == null) {
    response.sendRedirect("viewReservations.jsp");
    return;
  }

  boolean deleted = false;
  boolean valid = false;

  ApplicationDB db = new ApplicationDB();

  try (Connection conn = db.getConnection()) {
    conn.setAutoCommit(false);

    // 1. Get CID from session email
    int cid = -1;
    try (PreparedStatement getCid = conn.prepareStatement(
         "SELECT cid FROM CUSTOMER WHERE email = ?")) {
      getCid.setString(1, email);
      ResultSet rs = getCid.executeQuery();
      if (rs.next()) {
        cid = rs.getInt("cid");
      } else {
        out.println("<p>Could not verify your customer ID.</p>");
        return;
      }
    }

    // 2. Check ownership and get flightID
    int flightID = -1;
    try (PreparedStatement verify = conn.prepareStatement(
         "SELECT flightID FROM TICKET WHERE ticketID = ? AND cid = ?")) {
      verify.setInt(1, Integer.parseInt(ticketID));
      verify.setInt(2, cid);
      ResultSet rs = verify.executeQuery();
      if (rs.next()) {
        flightID = rs.getInt("flightID");
        valid = true;
      }
    }

    // 3. Delete the ticket if valid
    if (valid) {
      try (PreparedStatement del = conn.prepareStatement(
           "DELETE FROM TICKET WHERE ticketID = ? AND cid = ?")) {
        del.setInt(1, Integer.parseInt(ticketID));
        del.setInt(2, cid);
        deleted = (del.executeUpdate() > 0);
      }
    }

    // 4. Notify waitlist in current sessions (via session attributes)
    if (deleted && flightID > 0) {
      try (PreparedStatement getWL = conn.prepareStatement(
           "SELECT cid FROM WAITLIST WHERE flightID = ?")) {
        getWL.setInt(1, flightID);
        ResultSet rs = getWL.executeQuery();
        while (rs.next()) {
          int wlCid = rs.getInt("cid");
          session.setAttribute("waitlistAlertFor_" + wlCid, true);
        }
      }
    }

    conn.commit();
  } catch (Exception err) {
    // Silent fail
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Cancel Reservation</title>
  <style>
    body { font-family: sans-serif; }
    .topbar { text-align:right; margin-bottom:1em; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Cancel Reservation</h2>

<%
  if (!valid) {
%>
  <p style="color:red;">Reservation not found or not authorized.</p>
<%
  } else if (deleted) {
%>
  <p>Your reservation has been <strong>cancelled</strong>.</p>
  <p style="color:green;">Waitlisted users in this session will be notified.</p>
<%
  } else {
%>
  <p style="color:red;">Could not cancel this reservation.</p>
<%
  }
%>

<p><a href="viewReservations.jsp">← Back to Reservations</a></p>

</body>
</html>
