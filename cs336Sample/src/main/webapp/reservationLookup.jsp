<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String selectedFlight = request.getParameter("flightID");
  String selectedCustomer = request.getParameter("cid");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Reservation Lookup</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align:right; margin-bottom:1em; }
    .topbar a { margin-left:1em; }
    table { border-collapse: collapse; margin-top: 1em; width: 100%; }
    th, td { border: 1px solid #ccc; padding: 0.5em; }
    th { background: #eee; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong>
  <a href="adminHome.jsp">🏠 Admin Home</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Reservation Lookup</h2>

<form method="get" action="reservationLookup.jsp">
  <label for="flightID">Select Flight:</label>
  <select name="flightID" id="flightID">
    <option value="">-- None --</option>
    <%
      try (PreparedStatement ps = conn.prepareStatement("SELECT flightID, flightNum FROM FLIGHT")) {
        ResultSet r = ps.executeQuery();
        while (r.next()) {
          String fid = r.getString("flightID");
    %>
      <option value="<%= fid %>" <%= fid.equals(selectedFlight) ? "selected" : "" %>>
        Flight #<%= r.getString("flightNum") %>
      </option>
    <%
        }
      }
    %>
  </select>

  <label for="cid">Select Customer:</label>
  <select name="cid" id="cid">
    <option value="">-- None --</option>
    <%
      try (PreparedStatement ps = conn.prepareStatement("SELECT cid, fname, lname FROM CUSTOMER")) {
        ResultSet r = ps.executeQuery();
        while (r.next()) {
          String cid = r.getString("cid");
    %>
      <option value="<%= cid %>" <%= cid.equals(selectedCustomer) ? "selected" : "" %>>
        <%= r.getString("fname") %> <%= r.getString("lname") %>
      </option>
    <%
        }
      }
    %>
  </select>

  <input type="submit" value="Search" />
</form>

<%
  if ((selectedFlight != null && !selectedFlight.isEmpty()) || (selectedCustomer != null && !selectedCustomer.isEmpty())) {
    StringBuilder query = new StringBuilder(
      "SELECT T.ticketID, T.totalFare, T.purchaseDateTime, T.class, T.seatNumber, " +
      "F.flightNum, C.fname AS custF, C.lname AS custL, " +
      "P.fname AS passF, P.lname AS passL " +
      "FROM TICKET T " +
      "JOIN CUSTOMER C ON T.cid = C.cid " +
      "JOIN FLIGHT F ON T.flightID = F.flightID " +
      "JOIN PASSENGER P ON T.passengerID = P.passengerID " +
      "WHERE 1=1 "
    );

    if (selectedFlight != null && !selectedFlight.isEmpty()) {
      query.append("AND T.flightID = ? ");
    }
    if (selectedCustomer != null && !selectedCustomer.isEmpty()) {
      query.append("AND T.cid = ? ");
    }

    PreparedStatement ps = conn.prepareStatement(query.toString());

    try {
      int paramIdx = 1;
      if (selectedFlight != null && !selectedFlight.isEmpty()) {
        ps.setInt(paramIdx++, Integer.parseInt(selectedFlight));
      }
      if (selectedCustomer != null && !selectedCustomer.isEmpty()) {
        ps.setInt(paramIdx++, Integer.parseInt(selectedCustomer));
      }

      ResultSet rs = ps.executeQuery();
%>
<h3>Matching Reservations</h3>
<table>
  <tr>
    <th>Ticket ID</th>
    <th>Customer Name</th>
    <th>Passenger Name</th>
    <th>Flight #</th>
    <th>Class</th>
    <th>Seat #</th>
    <th>Fare</th>
    <th>Purchase Time</th>
  </tr>
<%
      boolean hasResults = false;
      while (rs.next()) {
        hasResults = true;
%>
  <tr>
    <td><%= rs.getInt("ticketID") %></td>
    <td><%= rs.getString("custF") %> <%= rs.getString("custL") %></td>
    <td><%= rs.getString("passF") %> <%= rs.getString("passL") %></td>
    <td><%= rs.getInt("flightNum") %></td>
    <td><%= rs.getString("class") %></td>
    <td><%= rs.getString("seatNumber") %></td>
    <td>$<%= rs.getDouble("totalFare") %></td>
    <td><%= rs.getTimestamp("purchaseDateTime") %></td>
  </tr>
<%
      }
      if (!hasResults) {
%>
  <tr><td colspan="8"><em>No reservations found.</em></td></tr>
<%
      }
      rs.close();
    } catch (NumberFormatException ex) {
%>
  <p style="color:red;">Invalid input: Customer or Flight ID is not a number.</p>
<%
    }

    ps.close();
  }

  conn.close();
%>
</table>

</body>
</html>
