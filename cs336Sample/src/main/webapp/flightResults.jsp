<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeParseException" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email     = (String) session.getAttribute("userEmail");
  String trip      = request.getParameter("trip");
  String dep       = request.getParameter("dep");
  String arr       = request.getParameter("arr");
  String date1     = request.getParameter("date1");
  String date2     = request.getParameter("date2");
  boolean flexible = "yes".equals(request.getParameter("flexible"));
  String filtAir   = request.getParameter("airline");
  String sortParam = request.getParameter("sort");
  String depStart  = request.getParameter("depStart");
  String depEnd    = request.getParameter("depEnd");
  String arrStart  = request.getParameter("arrStart");
  String arrEnd    = request.getParameter("arrEnd");

  LocalDate d1 = null, d2 = null;
  LocalDate start1 = null, end1 = null, start2 = null, end2 = null;

  try {
    if (date1 != null && !date1.isEmpty()) {
      d1 = LocalDate.parse(date1);
      start1 = flexible ? d1.minusDays(3) : d1;
      end1   = flexible ? d1.plusDays(3)  : d1;
    }
    if ("roundtrip".equals(trip) && date2 != null && !date2.isEmpty()) {
      d2 = LocalDate.parse(date2);
      start2 = flexible ? d2.minusDays(3) : d2;
      end2   = flexible ? d2.plusDays(3)  : d2;
    }
  } catch (DateTimeParseException e) {
    out.println("<p><strong>Invalid date format.</strong></p>");
  }

  String baseSQL =
    "SELECT f.flightID, f.flightNum, f.departureTime, f.arrivalTime, " +
    "TIMESTAMPDIFF(MINUTE, f.departureTime, f.arrivalTime) AS duration, " +
    "a.name AS airline, ap1.city AS depCity, ap2.city AS arrCity " +
    "FROM FLIGHT f " +
    "JOIN AIRLINE a ON f.airlineID = a.airlineID " +
    "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
    "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID ";

  String orderBy = "";
  switch (sortParam) {
    case "depAsc":  orderBy = " ORDER BY f.departureTime ASC"; break;
    case "depDesc": orderBy = " ORDER BY f.departureTime DESC"; break;
    case "arrAsc":  orderBy = " ORDER BY f.arrivalTime ASC"; break;
    case "arrDesc": orderBy = " ORDER BY f.arrivalTime DESC"; break;
    case "durAsc":  orderBy = " ORDER BY duration ASC"; break;
    case "durDesc": orderBy = " ORDER BY duration DESC"; break;
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Flight Results</title>
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
  <a href="viewReservations.jsp">My Reservations</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Outbound Flights</h2>
<table>
  <tr>
    <th>Airline</th><th>Flight #</th><th>Depart</th><th>From</th>
    <th>Arrive</th><th>To</th><th>Duration (min)</th><th>Action</th>
  </tr>
<%
  List<String> conds1 = new ArrayList<>();
  if (dep != null && !dep.isEmpty()) conds1.add("f.DepartureAirportID = ?");
  if (arr != null && !arr.isEmpty()) conds1.add("f.ArrivalAirportID = ?");
  if (start1 != null && end1 != null) conds1.add("DATE(f.departureTime) BETWEEN ? AND ?");
  if (filtAir != null && !filtAir.isEmpty()) conds1.add("f.airlineID = ?");
  if (depStart != null && !depStart.isEmpty()) conds1.add("TIME(f.departureTime) >= ?");
  if (depEnd != null && !depEnd.isEmpty()) conds1.add("TIME(f.departureTime) <= ?");
  if (arrStart != null && !arrStart.isEmpty()) conds1.add("TIME(f.arrivalTime) >= ?");
  if (arrEnd != null && !arrEnd.isEmpty()) conds1.add("TIME(f.arrivalTime) <= ?");

  String sql1 = baseSQL + (conds1.isEmpty() ? "" : " WHERE " + String.join(" AND ", conds1)) + orderBy;

  ApplicationDB db = new ApplicationDB();
  try (Connection c = db.getConnection();
       PreparedStatement ps = c.prepareStatement(sql1)) {
    int i = 1;
    if (dep != null && !dep.isEmpty()) ps.setString(i++, dep);
    if (arr != null && !arr.isEmpty()) ps.setString(i++, arr);
    if (start1 != null && end1 != null) {
      ps.setDate(i++, java.sql.Date.valueOf(start1));
      ps.setDate(i++, java.sql.Date.valueOf(end1));
    }
    if (filtAir != null && !filtAir.isEmpty()) ps.setString(i++, filtAir);
    if (depStart != null && !depStart.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(depStart + ":00"));
    if (depEnd != null && !depEnd.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(depEnd + ":00"));
    if (arrStart != null && !arrStart.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(arrStart + ":00"));
    if (arrEnd != null && !arrEnd.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(arrEnd + ":00"));

    ResultSet rs = ps.executeQuery();
    boolean any = false;
    while (rs.next()) {
      any = true;
%>
  <tr>
    <td><%= rs.getString("airline") %></td>
    <td><%= rs.getInt("flightNum") %></td>
    <td><%= rs.getTimestamp("departureTime") %></td>
    <td><%= rs.getString("depCity") %></td>
    <td><%= rs.getTimestamp("arrivalTime") %></td>
    <td><%= rs.getString("arrCity") %></td>
    <td><%= rs.getInt("duration") %></td>
    <td><a href="bookFlight.jsp?flightID=<%= rs.getInt("flightID") %>">Book</a></td>
  </tr>
<%
    }
    if (!any) {
%>
  <tr><td colspan="8"><em>No outbound flights found.</em></td></tr>
<%
    }
  } catch (Exception err) {
%>
  <tr><td colspan="8" style="color:red;"><strong>Error loading outbound.</strong></td></tr>
<%
  }
%>
</table>

<% if ("roundtrip".equals(trip)) { %>
<h2>Return Flights</h2>
<table>
  <tr>
    <th>Airline</th><th>Flight #</th><th>Depart</th><th>From</th>
    <th>Arrive</th><th>To</th><th>Duration (min)</th><th>Action</th>
  </tr>
<%
  List<String> conds2 = new ArrayList<>();
  if (arr != null && !arr.isEmpty()) conds2.add("f.DepartureAirportID = ?");
  if (dep != null && !dep.isEmpty()) conds2.add("f.ArrivalAirportID = ?");
  if (start2 != null && end2 != null) conds2.add("DATE(f.departureTime) BETWEEN ? AND ?");
  if (filtAir != null && !filtAir.isEmpty()) conds2.add("f.airlineID = ?");
  if (depStart != null && !depStart.isEmpty()) conds2.add("TIME(f.departureTime) >= ?");
  if (depEnd != null && !depEnd.isEmpty()) conds2.add("TIME(f.departureTime) <= ?");
  if (arrStart != null && !arrStart.isEmpty()) conds2.add("TIME(f.arrivalTime) >= ?");
  if (arrEnd != null && !arrEnd.isEmpty()) conds2.add("TIME(f.arrivalTime) <= ?");

  String sql2 = baseSQL + (conds2.isEmpty() ? "" : " WHERE " + String.join(" AND ", conds2)) + orderBy;

  try (Connection c2 = db.getConnection();
       PreparedStatement ps2 = c2.prepareStatement(sql2)) {
    int j = 1;
    if (arr != null && !arr.isEmpty()) ps2.setString(j++, arr);
    if (dep != null && !dep.isEmpty()) ps2.setString(j++, dep);
    if (start2 != null && end2 != null) {
      ps2.setDate(j++, java.sql.Date.valueOf(start2));
      ps2.setDate(j++, java.sql.Date.valueOf(end2));
    }
    if (filtAir != null && !filtAir.isEmpty()) ps2.setString(j++, filtAir);
    if (depStart != null && !depStart.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(depStart + ":00"));
    if (depEnd != null && !depEnd.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(depEnd + ":00"));
    if (arrStart != null && !arrStart.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(arrStart + ":00"));
    if (arrEnd != null && !arrEnd.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(arrEnd + ":00"));

    ResultSet rs2 = ps2.executeQuery();
    boolean any = false;
    while (rs2.next()) {
      any = true;
%>
  <tr>
    <td><%= rs2.getString("airline") %></td>
    <td><%= rs2.getInt("flightNum") %></td>
    <td><%= rs2.getTimestamp("departureTime") %></td>
    <td><%= rs2.getString("depCity") %></td>
    <td><%= rs2.getTimestamp("arrivalTime") %></td>
    <td><%= rs2.getString("arrCity") %></td>
    <td><%= rs2.getInt("duration") %></td>
    <td><a href="bookFlight.jsp?flightID=<%= rs2.getInt("flightID") %>">Book</a></td>
  </tr>
<%
    }
    if (!any) {
%>
  <tr><td colspan="8"><em>No return flights found.</em></td></tr>
<%
    }
  } catch (Exception err2) {
%>
  <tr><td colspan="8" style="color:red;"><strong>Error loading return.</strong></td></tr>
<%
  }
%>
</table>
<% } %>

</body>
</html>
