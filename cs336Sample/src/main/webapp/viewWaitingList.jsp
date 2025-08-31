<%@ page import="java.sql.*" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) s.getAttribute("userEmail");
  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>View Waitlist</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    table { border-collapse: collapse; width: 100%; margin-top: 1em; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background-color: #eee; }
    .topbar { text-align: right; margin-bottom: 1em; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="repHome.jsp">🏠 HomePage</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>View Flight Waitlist</h2>

<form method="get">
  <label>Select Flight:</label>
  <select name="flightID" required>
    <option value="">-- Select --</option>
<%
  ResultSet allFlights = conn.createStatement().executeQuery("SELECT flightID, flightNum FROM FLIGHT");
  String selectedFlightID = request.getParameter("flightID");
  while (allFlights.next()) {
    String fid = allFlights.getString("flightID");
    String fnum = allFlights.getString("flightNum");
%>
    <option value="<%= fid %>" <%= fid.equals(selectedFlightID) ? "selected" : "" %>>Flight #<%= fnum %> (ID: <%= fid %>)</option>
<% } allFlights.close(); %>
  </select>
  <button type="submit">Check Waiting List</button>
</form>

<%
  if (selectedFlightID != null && !selectedFlightID.isEmpty()) {
    try {
      PreparedStatement ps = conn.prepareStatement(
        "SELECT w.cid, c.fname, c.lname, w.dateOfRequest " +
        "FROM WAITLIST w JOIN CUSTOMER c ON w.cid = c.cid " +
        "WHERE w.flightID = ?"
      );
      ps.setInt(1, Integer.parseInt(selectedFlightID));
      ResultSet rs = ps.executeQuery();

      out.println("<h3>Waiting List for Flight ID: " + selectedFlightID + "</h3>");
      out.println("<table><tr><th>Customer ID</th><th>Name</th><th>Date of Request</th></tr>");

      boolean found = false;
      while (rs.next()) {
        found = true;
        out.println("<tr>");
        out.println("<td>" + rs.getInt("cid") + "</td>");
        out.println("<td>" + rs.getString("fname") + " " + rs.getString("lname") + "</td>");
        out.println("<td>" + rs.getString("dateOfRequest") + "</td>");
        out.println("</tr>");
      }
      out.println("</table>");
      if (!found) out.println("<p>No customers are currently on the waitlist for this flight.</p>");

      rs.close(); ps.close();
    } catch (Exception e) {
      out.println("<p style='color:red;'>❌ Error: " + e.getMessage() + "</p>");
    }
  }

  conn.close();
%>

</body>
</html>
