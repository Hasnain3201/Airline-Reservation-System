<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String month = request.getParameter("month");
  String year = request.getParameter("year");

  double totalRevenue = 0;
  int totalTickets = 0;

  class ClassSummary {
    String name;
    int count;
    double revenue;
    ClassSummary(String name, int count, double revenue) {
      this.name = name;
      this.count = count;
      this.revenue = revenue;
    }
  }

  java.util.List<ClassSummary> classData = new java.util.ArrayList<>();

  if (month != null && year != null) {
    try {
      ApplicationDB db = new ApplicationDB();
      Connection conn = db.getConnection();

      String startDate = year + "-" + month + "-01 00:00:00";
      String endDate = year + "-" + month + "-31 23:59:59";

      // Total Summary
      PreparedStatement ps = conn.prepareStatement(
        "SELECT COUNT(*) AS ticketCount, SUM(totalFare + bookingFee) AS revenue " +
        "FROM TICKET WHERE purchaseDateTime BETWEEN ? AND ?");
      ps.setString(1, startDate);
      ps.setString(2, endDate);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        totalTickets = rs.getInt("ticketCount");
        totalRevenue = rs.getDouble("revenue");
      }
      rs.close();
      ps.close();

      // Per Class Breakdown
      PreparedStatement ps2 = conn.prepareStatement(
        "SELECT class, COUNT(*) AS count, SUM(totalFare + bookingFee) AS revenue " +
        "FROM TICKET WHERE purchaseDateTime BETWEEN ? AND ? GROUP BY class");
      ps2.setString(1, startDate);
      ps2.setString(2, endDate);
      ResultSet rs2 = ps2.executeQuery();
      while (rs2.next()) {
        String cls = rs2.getString("class");
        int count = rs2.getInt("count");
        double rev = rs2.getDouble("revenue");
        classData.add(new ClassSummary(cls, count, rev));
      }
      rs2.close();
      ps2.close();
      conn.close();
    } catch (Exception e) {
      out.println("<p style='color:red;'>Error retrieving report: " + e.getMessage() + "</p>");
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Monthly Sales Report</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align: right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
    table { border-collapse: collapse; margin-top: 1em; }
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

<h2>Monthly Sales Report</h2>

<form method="get" action="salesReport.jsp">
  <label for="month">Month (MM):</label>
  <input type="text" name="month" placeholder="e.g. 05" required />
  <label for="year">Year (YYYY):</label>
  <input type="text" name="year" placeholder="e.g. 2025" required />
  <input type="submit" value="Generate Report" />
</form>

<%
  if (month != null && year != null) {
%>
  <h3>Report for <%= month %>/<%= year %></h3>
  <p><strong>Total Tickets Sold:</strong> <%= totalTickets %></p>
  <p><strong>Total Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>

  <h4>Revenue by Ticket Class</h4>
  <table>
    <tr><th>Class</th><th>Tickets Sold</th><th>Revenue</th></tr>
<%
    for (ClassSummary row : classData) {
%>
    <tr>
      <td><%= row.name %></td>
      <td><%= row.count %></td>
      <td>$<%= String.format("%.2f", row.revenue) %></td>
    </tr>
<%
    }
    if (classData.isEmpty()) {
%>
    <tr><td colspan="3"><em>No ticket class data found.</em></td></tr>
<%
    }
%>
  </table>
<%
  }
%>

</body>
</html>
