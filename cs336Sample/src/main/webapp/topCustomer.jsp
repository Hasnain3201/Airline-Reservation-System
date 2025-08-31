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
  <title>Top Customer by Revenue</title>
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

<h2>Top Revenue-Generating Customer</h2>

<%
  try {
    String sql =
      "SELECT C.cid, C.fname, C.lname, SUM(T.totalFare + T.bookingFee) AS revenue " +
      "FROM CUSTOMER C " +
      "JOIN TICKET T ON C.cid = T.cid " +
      "GROUP BY C.cid " +
      "ORDER BY revenue DESC " +
      "LIMIT 1";

    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();

    if (rs.next()) {
%>
<table>
  <tr>
    <th>Customer ID</th>
    <th>Name</th>
    <th>Total Revenue ($)</th>
  </tr>
  <tr>
    <td><%= rs.getInt("cid") %></td>
    <td><%= rs.getString("fname") %> <%= rs.getString("lname") %></td>
    <td><%= rs.getDouble("revenue") %></td>
  </tr>
</table>
<%
    } else {
%>
  <p style="color:red;">No customer records found.</p>
<%
    }

    rs.close();
    ps.close();
    conn.close();

  } catch (Exception e) {
%>
  <p style="color:red;">Error loading data: <%= e.getMessage() %></p>
<%
  }
%>

</body>
</html>
