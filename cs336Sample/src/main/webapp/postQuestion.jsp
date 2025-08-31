<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
  String email = (String) session.getAttribute("userEmail");
  if (email == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String question = request.getParameter("question");
  boolean submitted = (question != null && !question.trim().isEmpty());
  String message = null;

  if (submitted) {
    ApplicationDB db = new ApplicationDB();
    try (Connection conn = db.getConnection()) {
      int cid = -1;
      try (PreparedStatement getCid = conn.prepareStatement("SELECT cid FROM CUSTOMER WHERE email = ?")) {
        getCid.setString(1, email);
        ResultSet rs = getCid.executeQuery();
        if (rs.next()) {
          cid = rs.getInt("cid");
        } else {
          message = "User not found.";
        }
      }

      if (cid > 0) {
        int nextID = 1;
        try (Statement st = conn.createStatement();
             ResultSet maxRs = st.executeQuery("SELECT MAX(questionID) FROM QUESTION")) {
          if (maxRs.next()) nextID = maxRs.getInt(1) + 1;
        }

        try (PreparedStatement ps = conn.prepareStatement(
             "INSERT INTO QUESTION (questionID, qtext, qdate, cid) VALUES (?, ?, NOW(), ?)")) {
          ps.setInt(1, nextID);
          ps.setString(2, question.trim());
          ps.setInt(3, cid);
          ps.executeUpdate();
          response.sendRedirect("browseQnA.jsp");
          return;
        }
      }

    } catch (Exception err) {
      message = "Error submitting question.";
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Ask a Question</title>
  <style>
    body { font-family: sans-serif; margin: 2em; }
    .topbar { text-align: right; margin-bottom: 1em; }
    textarea { width: 100%; height: 120px; }
    form { margin-top: 1em; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="customerHome.jsp">🏠 HomePage</a> |
  <a href="browseQnA.jsp">Browse Q&A</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Post a Question</h2>

<% if (message != null) { %>
  <p style="color:red;"><%= message %></p>
<% } %>

<form method="post" action="postQuestion.jsp">
  <label for="question">Your Question:</label><br/>
  <textarea name="question" required></textarea><br/>
  <button type="submit">Submit</button>
</form>

</body>
</html>
