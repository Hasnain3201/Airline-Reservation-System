<%@ page language="java" import="javax.servlet.http.*, java.sql.*" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) s.getAttribute("userEmail");
  Integer repID = null;

  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT repID FROM CUSTOMERREP WHERE email = ?")) {
    ps.setString(1, email);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      repID = rs.getInt("repID");
      s.setAttribute("repID", repID); // Stored as Integer
    }
  } catch (Exception err) {
    // fail silently
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Customer Representative Dashboard</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align:right; margin-bottom: 1em; }
    .topbar a { margin-left: 1em; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong>
  <% if (repID != null) { %>
    (Rep ID: <%= repID %>)
  <% } %>
  | <a href="logout.jsp">Logout</a>
</div>

<h2>Welcome, <%= email %>!</h2>

<h3>What would you like to do today?</h3>

<ul>
  <li><a href="makeReservation.jsp">Make Flight Reservation</a></li>
  <li><a href="editReservation.jsp">Edit Flight Reservation</a></li>
  <li><a href="viewFlights.jsp">Manage Flights</a></li>
  <li><a href="viewWaitingList.jsp">View Waiting List</a></li>
  <li><a href="viewAirportFlights.jsp">View Flights at an Airport</a></li>
  <li><a href="answerQuestions.jsp">Answer User's Questions</a></li>
  <li><a href="logout.jsp">Logout</a></li>
</ul>

</body>
</html>
