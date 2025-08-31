<%@ page language="java" import="javax.servlet.http.*, java.sql.*" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) s.getAttribute("userEmail");

  int cid = -1;
  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement getCid = conn.prepareStatement("SELECT cid FROM CUSTOMER WHERE email = ?")) {
    getCid.setString(1, email);
    ResultSet rs = getCid.executeQuery();
    if (rs.next()) {
      cid = rs.getInt("cid");
    }
  } catch (Exception err) {
    // fail silently
  }

  boolean showAlert = false;
  if (cid > 0 && s.getAttribute("waitlistAlertFor_" + cid) != null) {
    showAlert = true;
    s.removeAttribute("waitlistAlertFor_" + cid);
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Customer Dashboard</title>
  <style>
    .alert { color: green; font-weight: bold; border: 1px solid #0c0; padding: 0.8em; margin: 1em 0; }
  </style>
</head>
<body>

<h2>Welcome, <%= email %>!</h2>

<% if (showAlert) { %>
  <div class="alert">
    🚨 A seat has opened up on a flight you’re waitlisted for! Act fast to book it.
  </div>
<% } %>

<ul>
  <li><a href="searchFlights.jsp">Search Flights</a></li>
  <li><a href="viewReservations.jsp">My Reservations</a></li>
  <li><a href="managePassengers.jsp">My Passengers</a></li>
  <li><a href="browseQnA.jsp">Browse Q&A</a></li>
  <li><a href="postQuestion.jsp">Post a Question</a></li>
  <li><a href="logout.jsp">Log out</a></li>
</ul>

</body>
</html>
