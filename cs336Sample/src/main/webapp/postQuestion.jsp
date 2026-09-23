<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>

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
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Ask a question"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="qna"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A10</span> Concourse A &middot; Information desk</div>
      <h1>Leave a note for the <em>crew.</em></h1>
      <p class="lede">Baggage, seats, waitlists, lounges &mdash; ask anything. A representative will answer and it'll appear on the information desk for everyone.</p>
    </div>
  </header>

<% if (message != null) { %>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Not sent</strong><p><%= esc(message) %></p></div></div>
<% } %>

  <div class="grid grid-aside">
    <form method="post" action="postQuestion.jsp" class="card reveal reveal-2" style="padding:0; overflow:hidden">
      <div class="pass-band" style="border-radius:0">
        <span><svg class="ico"><use href="#i-chat"/></svg>&nbsp; Postcard to the desk</span>
        <span>Par avion</span>
      </div>
      <div style="padding:26px">
        <div class="field">
          <label for="question">Your question</label>
          <textarea name="question" id="question" required placeholder="Dear crew, I was wondering&hellip;"></textarea>
        </div>
        <div class="btn-row" style="margin-top:18px; justify-content:space-between">
          <span class="caps">From: <%= esc(email) %></span>
          <button type="submit" class="btn">Send to the desk <svg class="ico ico-go"><use href="#i-arrow"/></svg></button>
        </div>
      </div>
    </form>

    <aside class="card card-sky reveal reveal-3">
      <div class="card-head"><h3><svg class="ico"><use href="#i-info"/></svg> Before you ask</h3></div>
      <p class="muted">Many questions have already been answered by our representatives.</p>
      <div class="stamp is-sand" style="margin:10px 0 22px">Airmail<small>Answered in hours</small></div>
      <div><a class="btn btn-ghost" href="browseQnA.jsp"><svg class="ico"><use href="#i-search"/></svg> Browse the desk</a></div>
    </aside>
  </div>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
