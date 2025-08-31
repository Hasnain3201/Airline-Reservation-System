<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page import="java.time.*, java.time.format.DateTimeParseException" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) s.getAttribute("userEmail");
  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();

  // ACTIONS FIRST
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
      if (request.getParameter("addAirport") != null) {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO AIRPORT VALUES (?, ?, ?, ?)");
        ps.setString(1, request.getParameter("airportID"));
        ps.setString(2, request.getParameter("name"));
        ps.setString(3, request.getParameter("city"));
        ps.setString(4, request.getParameter("country"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("editAirport") != null) {
        PreparedStatement ps = conn.prepareStatement("UPDATE AIRPORT SET name=?, city=?, country=? WHERE airportID=?");
        ps.setString(1, request.getParameter("name"));
        ps.setString(2, request.getParameter("city"));
        ps.setString(3, request.getParameter("country"));
        ps.setString(4, request.getParameter("airportID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("deleteAirport") != null) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM AIRPORT WHERE airportID=?");
        ps.setString(1, request.getParameter("airportID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("addAircraft") != null) {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO AIRCRAFT VALUES (?, ?, ?, ?)");
        ps.setInt(1, Integer.parseInt(request.getParameter("aircraftID")));
        ps.setString(2, request.getParameter("model"));
        ps.setInt(3, Integer.parseInt(request.getParameter("seatCapacity")));
        ps.setString(4, request.getParameter("airlineID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("editAircraft") != null) {
        PreparedStatement ps = conn.prepareStatement("UPDATE AIRCRAFT SET model=?, seatCapacity=?, airlineID=? WHERE aircraftID=?");
        ps.setString(1, request.getParameter("model"));
        ps.setInt(2, Integer.parseInt(request.getParameter("seatCapacity")));
        ps.setString(3, request.getParameter("airlineID"));
        ps.setInt(4, Integer.parseInt(request.getParameter("aircraftID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("deleteAircraft") != null) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM AIRCRAFT WHERE aircraftID=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("aircraftID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("addFlight") != null) {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO FLIGHT VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        ps.setInt(1, Integer.parseInt(request.getParameter("flightID")));
        ps.setInt(2, Integer.parseInt(request.getParameter("flightNum")));
        ps.setString(3, request.getParameter("departureTime").replace("T", " ") + ":00");
        ps.setString(4, request.getParameter("arrivalTime").replace("T", " ") + ":00");
        ps.setString(5, request.getParameter("daysOfWeek"));
        ps.setString(6, request.getParameter("flightType"));
        ps.setString(7, request.getParameter("airlineID"));
        ps.setInt(8, Integer.parseInt(request.getParameter("aircraftID")));
        ps.setString(9, request.getParameter("DepartureAirportID"));
        ps.setString(10, request.getParameter("ArrivalAirportID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("editFlight") != null) {
        PreparedStatement ps = conn.prepareStatement("UPDATE FLIGHT SET flightNum=?, departureTime=?, arrivalTime=?, daysOfWeek=?, flightType=?, airlineID=?, aircraftID=?, DepartureAirportID=?, ArrivalAirportID=? WHERE flightID=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("flightNum")));
        ps.setString(2, request.getParameter("departureTime").replace("T", " ") + ":00");
        ps.setString(3, request.getParameter("arrivalTime").replace("T", " ") + ":00");
        ps.setString(4, request.getParameter("daysOfWeek"));
        ps.setString(5, request.getParameter("flightType"));
        ps.setString(6, request.getParameter("airlineID"));
        ps.setInt(7, Integer.parseInt(request.getParameter("aircraftID")));
        ps.setString(8, request.getParameter("DepartureAirportID"));
        ps.setString(9, request.getParameter("ArrivalAirportID"));
        ps.setInt(10, Integer.parseInt(request.getParameter("flightID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("deleteFlight") != null) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM FLIGHT WHERE flightID=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("flightID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      }
    } catch (Exception e) {
      out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Flights, Aircraft, and Airports</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 2em; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background-color: #eee; }
    .topbar { text-align: right; margin-bottom: 1em; }
    form.inline { display:inline; margin:0; padding:0; }
    input, select { width: 100%; box-sizing: border-box; }
    .readonly { background: #f9f9f9; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="repHome.jsp">🏠 HomePage</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Manage Airports</h2>
<table>
  <tr><th>ID</th><th>Name</th><th>City</th><th>Country</th><th>Action</th></tr>
<%
  ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM AIRPORT");
  while (rs.next()) {
%>
<form method="post" class="inline">
<tr>
  <td><input name="airportID" value="<%= rs.getString("airportID") %>" readonly class="readonly"></td>
  <td><input name="name" value="<%= rs.getString("name") %>"></td>
  <td><input name="city" value="<%= rs.getString("city") %>"></td>
  <td><input name="country" value="<%= rs.getString("country") %>"></td>
  <td><button name="editAirport">Update</button> <button name="deleteAirport">Delete</button></td>
</tr>
</form>
<% } %>
<form method="post"><tr>
  <td><input name="airportID" required></td>
  <td><input name="name" required></td>
  <td><input name="city" required></td>
  <td><input name="country" required></td>
  <td><button name="addAirport">Add</button></td>
</tr></form>
</table>

<h2>Manage Aircraft</h2>
<table>
  <tr><th>ID</th><th>Model</th><th>Seat Capacity</th><th>Airline</th><th>Action</th></tr>
<%
  rs = conn.createStatement().executeQuery("SELECT * FROM AIRCRAFT");
  while (rs.next()) {
%>
<form method="post" class="inline"><tr>
  <td><input name="aircraftID" value="<%= rs.getInt("aircraftID") %>" readonly class="readonly"></td>
  <td><input name="model" value="<%= rs.getString("model") %>"></td>
  <td><input name="seatCapacity" value="<%= rs.getInt("seatCapacity") %>"></td>
  <td><input name="airlineID" value="<%= rs.getString("airlineID") %>"></td>
  <td><button name="editAircraft">Update</button> <button name="deleteAircraft">Delete</button></td>
</tr></form>
<% } %>
<form method="post"><tr>
  <td><input name="aircraftID" required></td>
  <td><input name="model" required></td>
  <td><input name="seatCapacity" required></td>
  <td><input name="airlineID" required></td>
  <td><button name="addAircraft">Add</button></td>
</tr></form>
</table>

<h2>Manage Flights</h2>
<%
  ResultSet airlines = conn.createStatement().executeQuery("SELECT airlineID FROM AIRLINE");
  List<String> airlineList = new ArrayList<>();
  while (airlines.next()) airlineList.add(airlines.getString(1));
  airlines.close();

  ResultSet airports = conn.createStatement().executeQuery("SELECT airportID FROM AIRPORT");
  List<String> airportList = new ArrayList<>();
  while (airports.next()) airportList.add(airports.getString(1));
  airports.close();

  ResultSet aircrafts = conn.createStatement().executeQuery("SELECT aircraftID FROM AIRCRAFT");
  List<Integer> aircraftList = new ArrayList<>();
  while (aircrafts.next()) aircraftList.add(aircrafts.getInt(1));
  aircrafts.close();
%>
<table>
  <tr><th>ID</th><th>#</th><th>Dep</th><th>Arr</th><th>Days</th><th>Type</th><th>Airline</th><th>Aircraft</th><th>From</th><th>To</th><th>Action</th></tr>
<%
  rs = conn.createStatement().executeQuery("SELECT * FROM FLIGHT");
  while (rs.next()) {
%>
<form method="post" class="inline"><tr>
  <td><input name="flightID" value="<%= rs.getInt("flightID") %>" readonly class="readonly"></td>
  <td><input name="flightNum" value="<%= rs.getInt("flightNum") %>"></td>
  <td><input type="datetime-local" name="departureTime" value="<%= rs.getTimestamp("departureTime").toLocalDateTime().toString().replace(" ", "T") %>"></td>
  <td><input type="datetime-local" name="arrivalTime" value="<%= rs.getTimestamp("arrivalTime").toLocalDateTime().toString().replace(" ", "T") %>"></td>
  <td><input name="daysOfWeek" value="<%= rs.getString("daysOfWeek") %>"></td>
  <td><input name="flightType" value="<%= rs.getString("flightType") %>"></td>
  <td><select name="airlineID"><% for (String a : airlineList) { %><option value="<%= a %>" <%= a.equals(rs.getString("airlineID")) ? "selected" : "" %>><%= a %></option><% } %></select></td>
  <td><select name="aircraftID"><% for (int ac : aircraftList) { %><option value="<%= ac %>" <%= ac == rs.getInt("aircraftID") ? "selected" : "" %>><%= ac %></option><% } %></select></td>
  <td><select name="DepartureAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>" <%= ap.equals(rs.getString("DepartureAirportID")) ? "selected" : "" %>><%= ap %></option><% } %></select></td>
  <td><select name="ArrivalAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>" <%= ap.equals(rs.getString("ArrivalAirportID")) ? "selected" : "" %>><%= ap %></option><% } %></select></td>
  <td><button name="editFlight">Update</button> <button name="deleteFlight">Delete</button></td>
</tr></form>
<% } %>
<form method="post"><tr>
  <td><input name="flightID" required></td>
  <td><input name="flightNum" required></td>
  <td><input type="datetime-local" name="departureTime" required></td>
  <td><input type="datetime-local" name="arrivalTime" required></td>
  <td><input name="daysOfWeek" required></td>
  <td><input name="flightType" required></td>
  <td><select name="airlineID"><% for (String a : airlineList) { %><option value="<%= a %>"><%= a %></option><% } %></select></td>
  <td><select name="aircraftID"><% for (int ac : aircraftList) { %><option value="<%= ac %>"><%= ac %></option><% } %></select></td>
  <td><select name="DepartureAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>"><%= ap %></option><% } %></select></td>
  <td><select name="ArrivalAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>"><%= ap %></option><% } %></select></td>
  <td><button name="addFlight">Add</button></td>
</tr></form>
</table>

<%
  conn.close();
%>

</body>
</html>
