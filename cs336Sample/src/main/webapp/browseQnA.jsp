<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  String email = (String) session.getAttribute("userEmail");
  if (email == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String search = request.getParameter("search");
  boolean filtered = (search != null && !search.trim().isEmpty());

  ApplicationDB db = new ApplicationDB();
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Browse Q&A</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align: right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
    table { border-collapse: collapse; width: 100%; margin-top: 1em; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background: #eee; }
    form { margin-top: 1em; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="customerHome.jsp">🏠 HomePage</a> |
  <a href="searchFlights.jsp">Search Flights</a> |
  <a href="viewReservations.jsp">My Reservations</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Customer Q&A</h2>

<form method="get" action="browseQnA.jsp">
  <label>Search Q/A: <input type="text" name="search" value="<%= search != null ? search : "" %>" /></label>
  <button type="submit">Search</button>
  <a href="browseQnA.jsp">Clear</a>
</form>

<table>
  <tr>
    <th>ID</th>
    <th>Question</th>
    <th>Answer</th>
    <th>Asked On</th>
  </tr>

<%
  String query = "SELECT questionID, qtext, atext, qdate FROM QUESTION";
  if (filtered) {
    query += " WHERE qtext LIKE ? OR atext LIKE ?";
  }
  query += " ORDER BY qdate DESC";

  try (Connection conn = db.getConnection();
       PreparedStatement ps = conn.prepareStatement(query)) {
    if (filtered) {
      ps.setString(1, "%" + search + "%");
      ps.setString(2, "%" + search + "%");
    }

    ResultSet rs = ps.executeQuery();
    boolean any = false;
    while (rs.next()) {
      any = true;
%>
  <tr>
    <td><%= rs.getInt("questionID") %></td>
    <td><%= rs.getString("qtext") %></td>
    <td><%= rs.getString("atext") != null ? rs.getString("atext") : "<em>Unanswered</em>" %></td>
    <td><%= rs.getTimestamp("qdate") %></td>
  </tr>
<%
    }
    if (!any) {
%>
  <tr><td colspan="4" style="text-align:center;"><em>No Q&A posts found.</em></td></tr>
<%
    }
  } catch (Exception err) {
%>
  <tr><td colspan="4" style="color:red;text-align:center;">Failed to load Q&A</td></tr>
<%
  }
%>
</table>

<p><a href="postQuestion.jsp">✍️ Ask a New Question</a></p>

</body>
</html>
