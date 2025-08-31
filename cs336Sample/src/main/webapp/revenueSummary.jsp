<%@ page import="java.sql.*" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String summaryType = request.getParameter("type");
  String selectedID = request.getParameter("filterID");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
  PreparedStatement ps = null;
  ResultSet r = null;
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Revenue Summary</title>
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

<h2>Revenue Summary</h2>

<form method="get" action="revenueSummary.jsp">
  <label>Choose category:</label>
  <select name="type" onchange="this.form.submit()">
    <option value="">-- Select --</option>
    <option value="flight" <%= "flight".equals(summaryType) ? "selected" : "" %>>Flight</option>
    <option value="airline" <%= "airline".equals(summaryType) ? "selected" : "" %>>Airline</option>
    <option value="customer" <%= "customer".equals(summaryType) ? "selected" : "" %>>Customer</option>
  </select>

<%
  if ("flight".equals(summaryType)) {
%>
  <label for="filterID">Flight:</label>
  <select name="filterID">
    <option value="">-- Select Flight --</option>
    <%
      ps = conn.prepareStatement("SELECT flightID, flightNum FROM FLIGHT");
      r = ps.executeQuery();
      while (r.next()) {
        String fid = r.getString("flightID");
    %>
      <option value="<%= fid %>" <%= fid.equals(selectedID) ? "selected" : "" %>>
        Flight #<%= r.getString("flightNum") %>
      </option>
    <%
      }
      r.close(); ps.close();
    %>
  </select>
<%
  } else if ("airline".equals(summaryType)) {
%>
  <label for="filterID">Airline:</label>
  <select name="filterID">
    <option value="">-- Select Airline --</option>
    <%
      ps = conn.prepareStatement("SELECT airlineID, name FROM AIRLINE");
      r = ps.executeQuery();
      while (r.next()) {
        String aid = r.getString("airlineID");
    %>
      <option value="<%= aid %>" <%= aid.equals(selectedID) ? "selected" : "" %>>
        <%= r.getString("name") %>
      </option>
    <%
      }
      r.close(); ps.close();
    %>
  </select>
<%
  } else if ("customer".equals(summaryType)) {
%>
  <label for="filterID">Customer:</label>
  <select name="filterID">
    <option value="">-- Select Customer --</option>
    <%
      ps = conn.prepareStatement("SELECT cid, fname, lname FROM CUSTOMER");
      r = ps.executeQuery();
      while (r.next()) {
        String cid = r.getString("cid");
    %>
      <option value="<%= cid %>" <%= cid.equals(selectedID) ? "selected" : "" %>>
        <%= r.getString("fname") %> <%= r.getString("lname") %>
      </option>
    <%
      }
      r.close(); ps.close();
    %>
  </select>
<%
  }
%>
  <input type="submit" value="Get Revenue" />
</form>

<%
  if (selectedID != null && !selectedID.isEmpty()) {
    String sql = "";
    if ("flight".equals(summaryType)) {
      sql = "SELECT T.ticketID, T.purchaseDateTime, T.class, T.totalFare, T.bookingFee " +
            "FROM TICKET T JOIN FLIGHT F ON T.flightID = F.flightID " +
            "WHERE F.flightID = ?";
    } else if ("airline".equals(summaryType)) {
      sql = "SELECT T.ticketID, T.purchaseDateTime, T.class, T.totalFare, T.bookingFee " +
            "FROM TICKET T JOIN FLIGHT F ON T.flightID = F.flightID " +
            "JOIN AIRLINE A ON F.airlineID = A.airlineID " +
            "WHERE A.airlineID = ?";
    } else if ("customer".equals(summaryType)) {
      sql = "SELECT T.ticketID, T.purchaseDateTime, T.class, T.totalFare, T.bookingFee " +
            "FROM TICKET T WHERE T.cid = ?";
    }

    ps = conn.prepareStatement(sql);
    ps.setString(1, selectedID);
    r = ps.executeQuery();

    double total = 0;
%>
<h3>Detailed Revenue Breakdown</h3>
<table>
  <tr>
    <th>Ticket ID</th>
    <th>Purchase Date</th>
    <th>Class</th>
    <th>Fare</th>
    <th>Booking Fee</th>
    <th>Total</th>
  </tr>
<%
    while (r.next()) {
      double fare = r.getDouble("totalFare");
      double fee  = r.getDouble("bookingFee");
      total += (fare + fee);
%>
  <tr>
    <td><%= r.getInt("ticketID") %></td>
    <td><%= r.getTimestamp("purchaseDateTime") %></td>
    <td><%= r.getString("class") %></td>
    <td><%= fare %></td>
    <td><%= fee %></td>
    <td><%= fare + fee %></td>
  </tr>
<%
    }
    r.close(); ps.close();
%>
  <tr>
    <th colspan="5">Total Revenue</th>
    <th><%= total %></th>
  </tr>
</table>
<%
  }

  conn.close();
%>

</body>
</html>
