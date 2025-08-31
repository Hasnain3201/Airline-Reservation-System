<%@ page import="java.sql.*, java.util.Date" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
  HttpSession s = request.getSession(false);
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();

  int repID = -1;
  try (PreparedStatement ps = conn.prepareStatement("SELECT repID FROM CUSTOMERREP WHERE email = ?")) {
    ps.setString(1, email);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) repID = rs.getInt("repID");
    rs.close();
  }

  String questionID = request.getParameter("questionID");
  String answerText = request.getParameter("answer");

  if (questionID != null && answerText != null && !answerText.trim().isEmpty()) {
    try (PreparedStatement update = conn.prepareStatement(
      "UPDATE QUESTION SET atext=?, adate=NOW(), repID=? WHERE questionID=?")) {
      update.setString(1, answerText.trim());
      update.setInt(2, repID);
      update.setInt(3, Integer.parseInt(questionID));
      update.executeUpdate();
      response.sendRedirect("answerQuestions.jsp");
      return;
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Answer Questions</title>
  <style>
    .topbar { text-align: right; margin-bottom: 1em; }
    .question-nav { margin: 1em 0; padding: 0.5em; background: #f4f4f4; }
    .box { border: 1px solid #ccc; padding: 1em; margin: 1em 0; }
    textarea { width: 100%; }
  </style>
</head>
<body>

<div class="topbar">
  Logged in as <strong><%= email %></strong> |
  <a href="repHome.jsp">🏠 HomePage</a> |
  <a href="logout.jsp">Logout</a>
</div>

<h2>Unanswered Questions</h2>

<div class="question-nav">
  <b>Select Question:</b>
  <form method="get">
    <select name="questionID" onchange="this.form.submit()">
      <option disabled selected>-- Choose a Question --</option>
      <%
        PreparedStatement nav = conn.prepareStatement("SELECT questionID, qtext FROM QUESTION WHERE atext IS NULL");
        ResultSet all = nav.executeQuery();
        while (all.next()) {
          int qid = all.getInt("questionID");
          String label = all.getString("qtext");
      %>
        <option value="<%= qid %>" <%= ("" + qid).equals(questionID) ? "selected" : "" %>>
          ID <%= qid %>: <%= label.length() > 40 ? label.substring(0, 40) + "..." : label %>
        </option>
      <%
        }
        all.close();
        nav.close();
      %>
    </select>
  </form>
</div>

<%
  if (questionID != null) {
    PreparedStatement ps = conn.prepareStatement(
      "SELECT Q.qtext, Q.qdate, C.fname, C.lname FROM QUESTION Q JOIN CUSTOMER C ON Q.cid = C.cid WHERE Q.questionID = ?");
    ps.setInt(1, Integer.parseInt(questionID));
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
%>

<form method="post">
  <div class="box">
    <input type="hidden" name="questionID" value="<%= questionID %>"/>
    <b>Question from:</b> <%= rs.getString("fname") %> <%= rs.getString("lname") %><br/>
    <b>Date:</b> <%= rs.getString("qdate") %><br/>
    <b>Text:</b><br/>
    <p><%= rs.getString("qtext") %></p>

    <label>Reply:</label><br/>
    <textarea name="answer" rows="4" required></textarea><br/>
    <button type="submit">Submit Answer</button>
  </div>
</form>

<%
    } else {
      out.println("<p><i>No question found.</i></p>");
    }
    rs.close();
    ps.close();
  } else {
    out.println("<p><i>Select a question to begin.</i></p>");
  }

  conn.close();
%>

</body>
</html>
