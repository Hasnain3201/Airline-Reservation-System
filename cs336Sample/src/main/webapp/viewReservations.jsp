<%@ page session="true" import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  String email = (String) session.getAttribute("userEmail");
  if (email == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  ApplicationDB db = new ApplicationDB();
  int cid = -1;

  try (Connection conn = db.getConnection()) {
    try (PreparedStatement getCid = conn.prepareStatement("SELECT cid FROM CUSTOMER WHERE email = ?")) {
      getCid.setString(1, email);
      ResultSet rs = getCid.executeQuery();
      if (rs.next()) cid = rs.getInt("cid");
    }
  %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>My Reservations</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align: right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 2em; }
    th, td { border: 1px solid #ccc; padding: 0.5em; text-align: left; }
    th { background: #eee; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong>
  <a href="customerHome.jsp">🏠 HomePage</a> |
  <a href="searchFlights.jsp">New Search</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Upcoming Reservations</h2>
<table>
  <tr>
    <th>Flight</th><th>From</th><th>To</th><th>Departs</th><th>Arrives</th>
    <th>Class</th><th>Seat</th><th>Passenger</th><th>Action</th>
  </tr>
<%
    try (PreparedStatement stmt = conn.prepareStatement(
         "SELECT t.ticketID, f.flightNum, ap1.city AS depCity, f.departureTime, " +
         "ap2.city AS arrCity, f.arrivalTime, t.class, t.seatNumber, " +
         "p.fname, p.lname " +
         "FROM TICKET t " +
         "JOIN FLIGHT f ON t.flightID = f.flightID " +
         "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
         "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
         "JOIN PASSENGER p ON t.passengerID = p.passengerID " +
         "WHERE t.cid = ? AND f.departureTime >= NOW()")) {
      stmt.setInt(1, cid);
      ResultSet rs = stmt.executeQuery();
      boolean any = false;
      while (rs.next()) {
        any = true;
%>
  <tr>
    <td><%= rs.getInt("flightNum") %></td>
    <td><%= rs.getString("depCity") %></td>
    <td><%= rs.getString("arrCity") %></td>
    <td><%= rs.getTimestamp("departureTime") %></td>
    <td><%= rs.getTimestamp("arrivalTime") %></td>
    <td><%= rs.getString("class") %></td>
    <td><%= rs.getString("seatNumber") %></td>
    <td><%= rs.getString("fname") %> <%= rs.getString("lname") %></td>
    <td><a href="cancelReservation.jsp?ticketID=<%= rs.getInt("ticketID") %>">Cancel</a></td>
  </tr>
<%
      }
      if (!any) {
%>
  <tr><td colspan="9"><em>No upcoming reservations.</em></td></tr>
<%
      }
    }
%>
</table>

<h2>Past Reservations</h2>
<table>
  <tr>
    <th>Flight</th><th>From</th><th>To</th><th>Departs</th><th>Arrives</th>
    <th>Class</th><th>Seat</th><th>Passenger</th>
  </tr>
<%
    try (PreparedStatement stmt2 = conn.prepareStatement(
         "SELECT f.flightNum, ap1.city AS depCity, f.departureTime, " +
         "ap2.city AS arrCity, f.arrivalTime, t.class, t.seatNumber, " +
         "p.fname, p.lname " +
         "FROM TICKET t " +
         "JOIN FLIGHT f ON t.flightID = f.flightID " +
         "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
         "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
         "JOIN PASSENGER p ON t.passengerID = p.passengerID " +
         "WHERE t.cid = ? AND f.departureTime < NOW()")) {
      stmt2.setInt(1, cid);
      ResultSet rs2 = stmt2.executeQuery();
      boolean any = false;
      while (rs2.next()) {
        any = true;
%>
  <tr>
    <td><%= rs2.getInt("flightNum") %></td>
    <td><%= rs2.getString("depCity") %></td>
    <td><%= rs2.getString("arrCity") %></td>
    <td><%= rs2.getTimestamp("departureTime") %></td>
    <td><%= rs2.getTimestamp("arrivalTime") %></td>
    <td><%= rs2.getString("class") %></td>
    <td><%= rs2.getString("seatNumber") %></td>
    <td><%= rs2.getString("fname") %> <%= rs2.getString("lname") %></td>
  </tr>
<%
      }
      if (!any) {
%>
  <tr><td colspan="8"><em>No past reservations.</em></td></tr>
<%
      }
    }
  }
%>
</table>

</body>
</html>
