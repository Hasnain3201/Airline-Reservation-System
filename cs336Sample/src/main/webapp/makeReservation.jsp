<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%@ page import="javax.servlet.http.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  HttpSession s = request.getSession(false);
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String repEmail = (String) session.getAttribute("userEmail");
  String selectedCID = request.getParameter("cid");
  String selectedFlight = request.getParameter("flightID");
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Make Reservation</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align: right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
    select, input { margin: 0.5em 0; display: block; }
  </style>
  <script>
    function autoSubmit() {
      document.getElementById("reservationForm").submit();
    }
  </script>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= repEmail %></strong> |
  <a href="repHome.jsp">🏠 Rep Home</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Make Reservation for Customer</h2>

<form id="reservationForm" method="get" action="makeReservation.jsp">
  <label>Select Customer:</label>
  <select name="cid" onchange="autoSubmit()">
    <option value="">-- Select --</option>
<%
  ApplicationDB db = new ApplicationDB();
  try (Connection conn = db.getConnection();
       Statement stmt = conn.createStatement();
       ResultSet rs = stmt.executeQuery("SELECT cid, fname, lname FROM CUSTOMER")) {
    while (rs.next()) {
      String cid = rs.getString("cid");
%>
      <option value="<%= cid %>" <%= cid.equals(selectedCID) ? "selected" : "" %>>
        <%= rs.getString("fname") %> <%= rs.getString("lname") %>
      </option>
<%
    }
  }
%>
  </select>

<% if (selectedCID != null && !selectedCID.isEmpty()) { %>
  <label>Select Flight:</label>
  <select name="flightID" onchange="autoSubmit()">
    <option value="">-- Select --</option>
<%
  try (Connection conn = db.getConnection();
       Statement stmt = conn.createStatement();
       ResultSet rs = stmt.executeQuery("SELECT flightID, flightNum FROM FLIGHT")) {
    while (rs.next()) {
      String fid = rs.getString("flightID");
%>
      <option value="<%= fid %>" <%= fid.equals(selectedFlight) ? "selected" : "" %>>
        Flight #<%= rs.getString("flightNum") %>
      </option>
<%
    }
  }
%>
  </select>
</form>
<% } %>

<%
  int maxSeats = 100;
  Set<String> takenSeats = new HashSet<>();
  List<Map<String, String>> passengers = new ArrayList<>();
  String flightDetails = "";
  String error = null;

  if (selectedCID != null && selectedFlight != null && !selectedCID.isEmpty() && !selectedFlight.isEmpty()) {
    try (Connection conn = db.getConnection()) {
      PreparedStatement ps = conn.prepareStatement(
        "SELECT f.flightNum, ap1.city AS fromCity, ap2.city AS toCity, f.departureTime, f.arrivalTime, ac.seatCapacity " +
        "FROM FLIGHT f JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
        "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
        "JOIN AIRCRAFT ac ON f.aircraftID = ac.aircraftID " +
        "WHERE f.flightID = ?");
      ps.setInt(1, Integer.parseInt(selectedFlight));
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        maxSeats = rs.getInt("seatCapacity");
        flightDetails = "Flight #" + rs.getString("flightNum") + ": " + rs.getString("fromCity") + " → " +
                        rs.getString("toCity") + ", Departs: " + rs.getTimestamp("departureTime") +
                        ", Arrives: " + rs.getTimestamp("arrivalTime");
      }

      PreparedStatement psT = conn.prepareStatement("SELECT seatNumber FROM TICKET WHERE flightID = ?");
      psT.setInt(1, Integer.parseInt(selectedFlight));
      ResultSet rsT = psT.executeQuery();
      while (rsT.next()) takenSeats.add(rsT.getString("seatNumber"));

      PreparedStatement psPass = conn.prepareStatement(
        "SELECT passengerID, fname, lname FROM PASSENGER WHERE createdByCID = ?");
      psPass.setInt(1, Integer.parseInt(selectedCID));
      ResultSet rsP = psPass.executeQuery();
      while (rsP.next()) {
        Map<String, String> p = new HashMap<>();
        p.put("passengerID", rsP.getString("passengerID"));
        p.put("name", rsP.getString("fname") + " " + rsP.getString("lname"));
        passengers.add(p);
      }
    }
%>
<form method="post" action="confirmBookingRep.jsp">
  <input type="hidden" name="cid" value="<%= selectedCID %>"/>
  <input type="hidden" name="flightID" value="<%= selectedFlight %>"/>

  <p><strong><%= flightDetails %></strong></p>

  <label>Select Passenger:</label>
  <select name="passengerID" required>
    <option disabled selected>-- Select --</option>
<% for (Map<String, String> p : passengers) { %>
    <option value="<%= p.get("passengerID") %>"><%= p.get("name") %></option>
<% } %>
  </select>

  <label>Class:</label>
  <select name="ticketClass">
    <option>Economy</option>
    <option>Business</option>
    <option>First</option>
  </select>

  <label>Seat:</label>
  <select name="seatNumber" required>
<% for (int i = 1; i <= maxSeats; i++) {
     String sn = Integer.toString(i);
     boolean taken = takenSeats.contains(sn);
%>
    <option value="<%= sn %>" <%= taken ? "disabled" : "" %>>
      <%= sn %> <%= taken ? "(Taken)" : "" %>
    </option>
<% } %>
  </select>

  <p><button type="submit">Confirm Reservation</button></p>
</form>
<% } %>

</body>
</html>
