<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String action = request.getParameter("action");
  String type = request.getParameter("type");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();

  if ("delete".equals(action)) {
    String id = request.getParameter("id");
    String table = "customer".equals(type) ? "CUSTOMER" : "CUSTOMERREP";
    String idField = "customer".equals(type) ? "cid" : "repID";
    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM " + table + " WHERE " + idField + " = ?")) {
      ps.setInt(1, Integer.parseInt(id));
      ps.executeUpdate();
    }
  }

  if ("add".equals(action)) {
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String emailNew = request.getParameter("email");
    String password = request.getParameter("password");

    if ("customer".equals(type)) {
      String address = request.getParameter("address");
      String dob = request.getParameter("dob");
      try (PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO CUSTOMER (fname, lname, email, password, address, dob) VALUES (?, ?, ?, ?, ?, ?)")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailNew);
        ps.setString(4, password);
        ps.setString(5, address);
        ps.setDate(6, java.sql.Date.valueOf(dob));
        ps.executeUpdate();
      }
    } else {
      try (PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO CUSTOMERREP (fname, lname, email, password) VALUES (?, ?, ?, ?)")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailNew);
        ps.setString(4, password);
        ps.executeUpdate();
      }
    }
  }

  if ("edit".equals(action)) {
    String id = request.getParameter("id");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String emailEdit = request.getParameter("email");

    if ("customer".equals(type)) {
      String address = request.getParameter("address");
      String dob = request.getParameter("dob");
      try (PreparedStatement ps = conn.prepareStatement(
          "UPDATE CUSTOMER SET fname = ?, lname = ?, email = ?, address = ?, dob = ? WHERE cid = ?")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailEdit);
        ps.setString(4, address);
        ps.setDate(5, java.sql.Date.valueOf(dob));
        ps.setInt(6, Integer.parseInt(id));
        ps.executeUpdate();
      }
    } else {
      try (PreparedStatement ps = conn.prepareStatement(
          "UPDATE CUSTOMERREP SET fname = ?, lname = ?, email = ? WHERE repID = ?")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailEdit);
        ps.setInt(4, Integer.parseInt(id));
        ps.executeUpdate();
      }
    }
  }

  Statement stmt = conn.createStatement();
  ResultSet customers = stmt.executeQuery("SELECT * FROM CUSTOMER");
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Users</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align:right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong>
  <a href="adminHome.jsp">🏠 Admin Home</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Manage Customers</h2>
<table border="1">
  <tr><th>ID</th><th>Name</th><th>Email</th><th>Address</th><th>DOB</th><th>Actions</th></tr>
<%
  while (customers.next()) {
%>
  <tr>
    <form method="post" action="manageUsers.jsp">
      <input type="hidden" name="action" value="edit"/>
      <input type="hidden" name="type" value="customer"/>
      <input type="hidden" name="id" value="<%= customers.getInt("cid") %>"/>
      <td><%= customers.getInt("cid") %></td>
      <td>
        <input name="fname" value="<%= customers.getString("fname") %>"/>
        <input name="lname" value="<%= customers.getString("lname") %>"/>
      </td>
      <td><input name="email" value="<%= customers.getString("email") %>"/></td>
      <td><input name="address" value="<%= customers.getString("address") %>"/></td>
      <td><input name="dob" type="date" value="<%= customers.getDate("dob") %>"/></td>
      <td>
        <input type="submit" value="Update"/>
        <a href="manageUsers.jsp?action=delete&type=customer&id=<%= customers.getInt("cid") %>">Delete</a>
      </td>
    </form>
  </tr>
<%
  }
  customers.close();
%>
</table>

<h3>Add New Customer</h3>
<form method="post" action="manageUsers.jsp">
  <input type="hidden" name="action" value="add"/>
  <input type="hidden" name="type" value="customer"/>
  First Name: <input name="fname" required/>
  Last Name: <input name="lname" required/>
  Email: <input type="email" name="email" required/>
  Password: <input type="password" name="password" required/>
  Address: <input name="address" required/>
  DOB: <input type="date" name="dob" required/>
  <input type="submit" value="Add Customer"/>
</form>

<%
  ResultSet reps = stmt.executeQuery("SELECT * FROM CUSTOMERREP");
%>
<hr>
<h2>Manage Customer Representatives</h2>
<table border="1">
  <tr><th>ID</th><th>Name</th><th>Email</th><th>Actions</th></tr>
<%
  while (reps.next()) {
%>
  <tr>
    <form method="post" action="manageUsers.jsp">
      <input type="hidden" name="action" value="edit"/>
      <input type="hidden" name="type" value="rep"/>
      <input type="hidden" name="id" value="<%= reps.getInt("repID") %>"/>
      <td><%= reps.getInt("repID") %></td>
      <td>
        <input name="fname" value="<%= reps.getString("fname") %>"/>
        <input name="lname" value="<%= reps.getString("lname") %>"/>
      </td>
      <td><input name="email" value="<%= reps.getString("email") %>"/></td>
      <td>
        <input type="submit" value="Update"/>
        <a href="manageUsers.jsp?action=delete&type=rep&id=<%= reps.getInt("repID") %>">Delete</a>
      </td>
    </form>
  </tr>
<%
  }
  reps.close();
  conn.close();
%>
</table>

<h3>Add New Customer Representative</h3>
<form method="post" action="manageUsers.jsp">
  <input type="hidden" name="action" value="add"/>
  <input type="hidden" name="type" value="rep"/>
  First Name: <input name="fname" required/>
  Last Name: <input name="lname" required/>
  Email: <input type="email" name="email" required/>
  Password: <input type="password" name="password" required/>
  <input type="submit" value="Add Representative"/>
</form>

</body>
</html>
