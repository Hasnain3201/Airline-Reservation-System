<%@ page language="java" import="javax.servlet.http.*" contentType="text/html; charset=UTF-8" %>
<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) s.getAttribute("userEmail");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Admin Dashboard</title>
</head>
<body>
  <h2>Welcome, <%= email %> (Admin)</h2>

    <ul>
        <li><a href="manageUsers.jsp">Manage Customers & Representatives</a></li>
        <li><a href="salesReport.jsp">Monthly Sales Report</a></li>
        <li><a href="reservationLookup.jsp">Find Reservations by Flight or Customer</a></li>
        <li><a href="revenueSummary.jsp">Revenue Summary by Flight, Airline, or Customer</a></li>
        <li><a href="topCustomer.jsp">Top Revenue-Generating Customer</a></li>
        <li><a href="activeFlights.jsp">Most Active Flights</a></li>
        <li><a href="logout.jsp">Log out</a></li>
    </ul>
</body>
</html>

