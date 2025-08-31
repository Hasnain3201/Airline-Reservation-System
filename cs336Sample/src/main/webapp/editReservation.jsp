<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String selectedCID = request.getParameter("cid");

  ApplicationDB db = new ApplicationDB();

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    String ticketID = request.getParameter("ticketID");
    try (Connection conn = db.getConnection()) {
      if ("update".equals(action)) {
        String newClass = request.getParameter("ticketClass");
        String newSeat = request.getParameter("seatNumber");

        int fare = "First".equals(newClass) ? 700 : "Business".equals(newClass) ? 400 : 100;

        PreparedStatement update = conn.prepareStatement(
          "UPDATE TICKET SET class = ?, seatNumber = ?, totalFare = ? WHERE ticketID = ?"
        );
        update.setString(1, newClass);
        update.setString(2, newSeat);
        update.setInt(3, fare);
        update.setInt(4, Integer.parseInt(ticketID));
        update.executeUpdate();
      } else if ("delete".equals(action)) {
        PreparedStatement del = conn.prepareStatement(
          "DELETE FROM TICKET WHERE ticketID = ?"
        );
        del.setInt(1, Integer.parseInt(ticketID));
        del.executeUpdate();

        response.sendRedirect("editReservation.jsp?cid=" + selectedCID);
        return;
      }
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Reservations</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    table { border-collapse: collapse; width: 100%; margin-top: 1em; }
    th, td { border: 1px solid #ccc; padding: 0.5em; text-align: left; }
    .topbar { text-align: right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
  </style>
</head>
<body>
<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="repHome.jsp">🏠 Rep Home</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Edit Reservations</h2>

<form method="get">
  <label>Select Customer:</label>
  <select name="cid" onchange="this.form.submit()">
    <option value="">-- Select --</option>
<%
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
</form>

<%
if (selectedCID != null && !selectedCID.isEmpty()) {
  try (Connection conn = db.getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT t.ticketID, t.flightID, t.class, t.seatNumber, f.flightNum, t.passengerID, " +
         "p.fname, p.lname, ap1.city AS depCity, ap2.city AS arrCity, f.departureTime, f.arrivalTime, a.seatCapacity " +
         "FROM TICKET t " +
         "JOIN FLIGHT f ON t.flightID = f.flightID " +
         "JOIN AIRCRAFT a ON f.aircraftID = a.aircraftID " +
         "JOIN PASSENGER p ON t.passengerID = p.passengerID " +
         "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
         "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
         "WHERE t.cid = ?"
       )) {
    ps.setInt(1, Integer.parseInt(selectedCID));
    ResultSet rs = ps.executeQuery();
%>
<table>
  <tr>
    <th>Ticket ID</th><th>Flight #</th><th>Passenger</th><th>From</th><th>To</th>
    <th>Departs</th><th>Arrives</th><th>Class</th><th>Seat</th><th>Update</th><th>Delete</th>
  </tr>
<%
    while (rs.next()) {
      int ticketID = rs.getInt("ticketID");
      int flightID = rs.getInt("flightID");
      int seatCap = rs.getInt("seatCapacity");

      Set<String> takenSeats = new HashSet<>();
      try (PreparedStatement ps2 = conn.prepareStatement("SELECT seatNumber FROM TICKET WHERE flightID = ?")) {
        ps2.setInt(1, flightID);
        ResultSet rs2 = ps2.executeQuery();
        while (rs2.next()) takenSeats.add(rs2.getString("seatNumber"));
      }
%>
  <tr>
    <form method="post">
      <input type="hidden" name="cid" value="<%= selectedCID %>"/>
      <input type="hidden" name="ticketID" value="<%= ticketID %>"/>
      <td><%= ticketID %></td>
      <td><%= rs.getString("flightNum") %></td>
      <td><%= rs.getString("fname") %> <%= rs.getString("lname") %></td>
      <td><%= rs.getString("depCity") %></td>
      <td><%= rs.getString("arrCity") %></td>
      <td><%= rs.getTimestamp("departureTime") %></td>
      <td><%= rs.getTimestamp("arrivalTime") %></td>
      <td>
        <select name="ticketClass">
          <option<%= rs.getString("class").equals("Economy") ? " selected" : "" %>>Economy</option>
          <option<%= rs.getString("class").equals("Business") ? " selected" : "" %>>Business</option>
          <option<%= rs.getString("class").equals("First") ? " selected" : "" %>>First</option>
        </select>
      </td>
      <td>
        <select name="seatNumber">
<%
      for (int i = 1; i <= seatCap; i++) {
        String sn = Integer.toString(i);
        boolean taken = takenSeats.contains(sn) && !sn.equals(rs.getString("seatNumber"));
%>
          <option value="<%= sn %>" <%= sn.equals(rs.getString("seatNumber")) ? "selected" : "" %> <%= taken ? "disabled" : "" %>>
            <%= sn %> <%= taken ? "(Taken)" : "" %>
          </option>
<%
      }
%>
        </select>
      </td>
      <td>
        <button type="submit" name="action" value="update">Update</button>
      </td>
      <td>
        <button type="submit" name="action" value="delete">Delete</button>
      </td>
    </form>
  </tr>
<%
    }
%>
</table>
<%
  }
}
%>

</body>
</html>
