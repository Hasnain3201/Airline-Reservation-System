<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
  PreparedStatement ps = null;
  ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Most Active Flights</title>
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

<h2>Most Active Flights (by Tickets Sold)</h2>

<%
  try {
    String sql =
      "SELECT F.flightID, F.flightNum, A.name AS airline, COUNT(T.ticketID) AS ticketsSold " +
      "FROM TICKET T " +
      "JOIN FLIGHT F ON T.flightID = F.flightID " +
      "JOIN AIRLINE A ON F.airlineID = A.airlineID " +
      "GROUP BY F.flightID " +
      "ORDER BY ticketsSold DESC " + 
      "LIMIT 10";

    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();
%>

<table>
  <tr>
    <th>Flight #</th>
    <th>Airline</th>
    <th>Tickets Sold</th>
  </tr>
<%
    while (rs.next()) {
%>
  <tr>
    <td><%= rs.getString("flightNum") %></td>
    <td><%= rs.getString("airline") %></td>
    <td><%= rs.getInt("ticketsSold") %></td>
  </tr>
<%
    }
    rs.close();
    ps.close();
    conn.close();
  } catch (Exception e) {
%>
  <p style="color:red;">Error loading active flights: <%= e.getMessage() %></p>
<%
  }
%>
</table>

</body>
</html>
