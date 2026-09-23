<%@ page import="java.sql.*, java.util.Date" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
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
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Answer questions"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="answer"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B8</span> Concourse B &middot; Passenger inbox</div>
      <h1>Unanswered <em>questions.</em></h1>
      <p class="lede">Notes left at the information desk. Your reply is published for every traveller to read.</p>
    </div>
  </header>

  <div class="grid" style="grid-template-columns: minmax(0, .9fr) minmax(0, 1.3fr); align-items:start">
    <nav class="gates reveal reveal-2" aria-label="Unanswered questions">
<%
  PreparedStatement nav = conn.prepareStatement("SELECT questionID, qtext, qdate FROM QUESTION WHERE atext IS NULL ORDER BY qdate");
  ResultSet all = nav.executeQuery();
  boolean anyOpen = false;
  while (all.next()) {
    anyOpen = true;
    int qid = all.getInt("questionID");
    String label = all.getString("qtext");
    boolean current = ("" + qid).equals(questionID);
%>
      <a class="gate-row" href="answerQuestions.jsp?questionID=<%= qid %>" style="grid-template-columns:56px minmax(0,1fr) 40px;<%= current ? " border-color:var(--ink); background:var(--sky-50);" : "" %>">
        <span class="gate-sign" style="height:38px;min-width:48px">Q<%= qid %></span>
        <span><span class="gr-title" style="font-size:.95rem"><%= esc(label.length() > 60 ? label.substring(0, 60) + "..." : label) %></span><span class="gr-sub"><%= fmtDateTime(all.getTimestamp("qdate")) %></span></span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
<%
  }
  all.close();
  nav.close();
  if (!anyOpen) {
%>
      <div class="empty">
        <div class="stamp is-go">Inbox zero<small>All answered</small></div>
        <p style="margin-top:14px">Every passenger question has a reply. Nice work.</p>
      </div>
<%
  }
%>
    </nav>

    <div class="reveal reveal-3">
<%
  if (questionID != null) {
    PreparedStatement ps = conn.prepareStatement(
      "SELECT Q.qtext, Q.qdate, C.fname, C.lname FROM QUESTION Q JOIN CUSTOMER C ON Q.cid = C.cid WHERE Q.questionID = ?");
    ps.setInt(1, Integer.parseInt(questionID));
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
%>
      <form method="post" class="card" style="padding:0; overflow:hidden">
        <input type="hidden" name="questionID" value="<%= esc(questionID) %>"/>
        <div class="pass-band" style="border-radius:0">
          <span><svg class="ico"><use href="#i-chat"/></svg>&nbsp; Query #<%= esc(questionID) %></span>
          <span>From <%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></span>
        </div>
        <div style="padding:26px">
          <span class="caps">Asked <%= fmtDateTime(rs.getTimestamp("qdate")) %></span>
          <p class="qa-q" style="margin:10px 0 22px"><%= esc(rs.getString("qtext")) %></p>
          <div class="field">
            <label for="answer">Your reply</label>
            <textarea name="answer" id="answer" rows="5" required placeholder="Hi <%= esc(rs.getString("fname")) %>, thanks for asking&hellip;"></textarea>
          </div>
          <div class="btn-row" style="margin-top:18px; justify-content:flex-end">
            <button type="submit" class="btn">Publish answer <svg class="ico ico-go"><use href="#i-arrow"/></svg></button>
          </div>
        </div>
      </form>
<%
    } else {
%>
      <div class="empty"><h3>No question found</h3><p>It may already have been answered.</p></div>
<%
    }
    rs.close();
    ps.close();
  } else {
%>
      <div class="empty">
        <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
          <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
          <g transform="translate(56 24)" fill="#A7C8E3"><use href="#i-chat" width="48" height="48"/></g>
        </svg>
        <h3>Select a question to begin</h3>
        <p>Pick a note from the list and write your reply here.</p>
      </div>
<%
  }

  conn.close();
%>
    </div>
  </div>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
