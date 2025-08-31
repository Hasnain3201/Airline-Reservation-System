<%@ page import="java.sql.*, java.util.*" %>
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
  PreparedStatement ps;
  ResultSet rs;

  int cid = -1;
  try {
    ps = conn.prepareStatement("SELECT cid FROM CUSTOMER WHERE email = ?");
    ps.setString(1, email);
    rs = ps.executeQuery();
    if (rs.next()) cid = rs.getInt("cid");
    rs.close(); ps.close();
  } catch (Exception err) { out.println("<p>Error: " + err.getMessage() + "</p>"); }

  if (cid == -1) {
    out.println("<p>Could not retrieve customer ID.</p>");
    return;
  }

  String action = request.getParameter("action");
  String msg = null;

  if ("add".equals(action)) {
    String idNum = request.getParameter("idNumber");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String dob = request.getParameter("dob");

    if (idNum != null && fname != null && lname != null && dob != null) {
      try {
        ps = conn.prepareStatement(
          "INSERT INTO PASSENGER (idNumber, fname, lname, dob, createdByCID) VALUES (?, ?, ?, ?, ?)");
        ps.setString(1, idNum);
        ps.setString(2, fname);
        ps.setString(3, lname);
        ps.setDate(4, java.sql.Date.valueOf(dob));
        ps.setInt(5, cid);
        ps.executeUpdate();
        ps.close();
        msg = "Passenger added.";
      } catch (Exception e) {
        msg = "Failed to add: " + e.getMessage();
      }
    }
  }

  if ("delete".equals(action)) {
    String idNum = request.getParameter("idNumber");
    if (idNum != null) {
      try {
        ps = conn.prepareStatement("DELETE FROM PASSENGER WHERE idNumber = ? AND createdByCID = ?");
        ps.setString(1, idNum);
        ps.setInt(2, cid);
        ps.executeUpdate();
        ps.close();
        msg = "Passenger deleted.";
      } catch (Exception e) {
        msg = "Failed to delete: " + e.getMessage();
      }
    }
  }

  if ("update".equals(action)) {
    String idNum = request.getParameter("idNumber");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String dob = request.getParameter("dob");

    if (idNum != null && fname != null && lname != null && dob != null) {
      try {
        ps = conn.prepareStatement(
          "UPDATE PASSENGER SET fname = ?, lname = ?, dob = ? WHERE idNumber = ? AND createdByCID = ?");
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setDate(3, java.sql.Date.valueOf(dob));
        ps.setString(4, idNum);
        ps.setInt(5, cid);
        ps.executeUpdate();
        ps.close();
        msg = "Passenger updated.";
      } catch (Exception e) {
        msg = "Failed to update: " + e.getMessage();
      }
    }
  }

%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Passengers</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align:right; margin-bottom:1em; }
    .topbar a { margin-left:1em; }
    table { border-collapse: collapse; width: 100%; margin-top: 1em; }
    th, td { border: 1px solid #ccc; padding: 0.5em; }
    th { background: #eee; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="customerHome.jsp">🏠 Home</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>My Passengers</h2>

<% if (msg != null) { %>
  <p style="color:green;"><%= msg %></p>
<% } %>

<table>
  <tr>
    <th>ID #</th><th>First</th><th>Last</th><th>DOB</th><th>Actions</th>
  </tr>
<%
  ps = conn.prepareStatement("SELECT idNumber, fname, lname, dob FROM PASSENGER WHERE createdByCID = ?");
  ps.setInt(1, cid);
  rs = ps.executeQuery();
  while (rs.next()) {
%>
  <form method="post">
  <tr>
    <td><input type="text" name="idNumber" value="<%= rs.getString("idNumber") %>" readonly /></td>
    <td><input type="text" name="fname" value="<%= rs.getString("fname") %>" /></td>
    <td><input type="text" name="lname" value="<%= rs.getString("lname") %>" /></td>
    <td><input type="date" name="dob" value="<%= rs.getDate("dob") %>" /></td>
    <td>
      <button type="submit" name="action" value="update">Update</button>
      <button type="submit" name="action" value="delete">Delete</button>
    </td>
  </tr>
  </form>
<%
  }
  rs.close();
  ps.close();
%>
</table>

<h3>Add New Passenger</h3>
<form method="post">
  <label>ID Number: <input name="idNumber" required /></label><br/>
  <label>First Name: <input name="fname" required /></label><br/>
  <label>Last Name: <input name="lname" required /></label><br/>
  <label>DOB: <input type="date" name="dob" required /></label><br/>
  <button type="submit" name="action" value="add">Add Passenger</button>
</form>

</body>
</html>
