<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" contentType="text/html; charset=UTF-8" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) s.getAttribute("userEmail");
  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();

  String selectedAirport = request.getParameter("airportID");
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>View Airport Flights</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align: right; margin-bottom: 1em; }
    table { border-collapse: collapse; width: 100%; margin-top: 1em; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background-color: #eee; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="repHome.jsp">🏠 HomePage</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>View Flights for an Airport</h2>
<form method="get">
  <label>Select Airport:</label>
  <select name="airportID" onchange="this.form.submit()" required>
    <option value="">-- Select --</option>
<%
  ResultSet rsAirports = conn.createStatement().executeQuery("SELECT airportID FROM AIRPORT");
  while (rsAirports.next()) {
    String aid = rsAirports.getString("airportID");
%>
    <option value="<%= aid %>" <%= aid.equals(selectedAirport) ? "selected" : "" %>><%= aid %></option>
<% } rsAirports.close(); %>
  </select>
</form>

<%
  if (selectedAirport != null && !selectedAirport.isEmpty()) {
%>
  <h3>Departing Flights from <%= selectedAirport %></h3>
  <table>
    <tr><th>Flight ID</th><th>Flight Number</th><th>Departure</th><th>Arrival</th></tr>
<%
    PreparedStatement psDep = conn.prepareStatement("SELECT flightID, flightNum, departureTime, arrivalTime FROM FLIGHT WHERE DepartureAirportID = ?");
    psDep.setString(1, selectedAirport);
    ResultSet rsDep = psDep.executeQuery();
    while (rsDep.next()) {
%>
    <tr>
      <td><%= rsDep.getInt("flightID") %></td>
      <td><%= rsDep.getInt("flightNum") %></td>
      <td><%= rsDep.getString("departureTime") %></td>
      <td><%= rsDep.getString("arrivalTime") %></td>
    </tr>
<%
    }
    rsDep.close();
    psDep.close();
%>
  </table>

  <h3>Arriving Flights to <%= selectedAirport %></h3>
  <table>
    <tr><th>Flight ID</th><th>Flight Number</th><th>Departure</th><th>Arrival</th></tr>
<%
    PreparedStatement psArr = conn.prepareStatement("SELECT flightID, flightNum, departureTime, arrivalTime FROM FLIGHT WHERE ArrivalAirportID = ?");
    psArr.setString(1, selectedAirport);
    ResultSet rsArr = psArr.executeQuery();
    while (rsArr.next()) {
%>
    <tr>
      <td><%= rsArr.getInt("flightID") %></td>
      <td><%= rsArr.getInt("flightNum") %></td>
      <td><%= rsArr.getString("departureTime") %></td>
      <td><%= rsArr.getString("arrivalTime") %></td>
    </tr>
<%
    }
    rsArr.close();
    psArr.close();
  }
  conn.close();
%>
  </table>
</body>
</html>
