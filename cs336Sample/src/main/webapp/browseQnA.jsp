<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
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
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Information desk"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="qna"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A9</span> Concourse A &middot; Information desk</div>
      <h1>Ask the <em>crew.</em></h1>
      <p class="lede">Questions from fellow travellers, answered by our representatives. Can't find yours? Leave a note at the desk.</p>
    </div>
    <div class="head-actions">
      <a class="btn" href="postQuestion.jsp"><svg class="ico"><use href="#i-chat"/></svg> Ask a question</a>
    </div>
  </header>

  <form method="get" action="browseQnA.jsp" class="searchbar reveal reveal-2" style="margin-bottom:28px">
    <svg class="ico"><use href="#i-search"/></svg>
    <input type="text" name="search" value="<%= esc(search) %>" placeholder="Search questions and answers&hellip; baggage, seats, waitlist" aria-label="Search Q&amp;A" />
<% if (filtered) { %>
    <a class="btn btn-ghost btn-sm" href="browseQnA.jsp">Clear</a>
<% } %>
    <button type="submit" class="btn btn-sm">Search</button>
  </form>

  <div class="qa-list reveal reveal-3">
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
      String answer = rs.getString("atext");
%>
    <article class="qa">
      <div class="qa-no"><%= String.format("%02d", rs.getInt("questionID")) %><small>Query</small></div>
      <div>
        <div class="qa-q"><%= esc(rs.getString("qtext")) %></div>
<% if (answer != null) { %>
        <div class="qa-a"><svg class="ico"><use href="#i-chat"/></svg><%= esc(answer) %></div>
<% } else { %>
        <div class="qa-a is-open"><svg class="ico"><use href="#i-hourglass"/></svg>Awaiting a reply from the crew&hellip;</div>
<% } %>
        <div class="qa-meta">
          <span class="caps">Asked <%= fmtDateTime(rs.getTimestamp("qdate")) %></span>
          <span class="pill <%= answer != null ? "pill-go" : "pill-sand" %>"><%= answer != null ? "Answered" : "Unanswered" %></span>
        </div>
      </div>
    </article>
<%
    }
    if (!any) {
%>
    <div class="empty">
      <h3>No notes at the desk</h3>
      <p><%= filtered ? "Nothing matches \"" + esc(search) + "\". Try another word, or ask the crew directly." : "No Q&amp;A posts yet. Be the first to ask." %></p>
      <a class="btn" href="postQuestion.jsp" style="margin-top:10px"><svg class="ico"><use href="#i-chat"/></svg> Ask a question</a>
    </div>
<%
    }
  } catch (Exception err) {
%>
    <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Desk closed</strong><p>Failed to load Q&amp;A.</p></div></div>
<%
  }
%>
  </div>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
