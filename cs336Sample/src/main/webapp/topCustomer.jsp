<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
  PreparedStatement ps = null;
  ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Top flyer"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="top"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C6</span> Concourse C &middot; Frequent flyer club</div>
      <h1>Our top <em>flyer.</em></h1>
      <p class="lede">The customer who has generated the most revenue across every ticket they've bought.</p>
    </div>
  </header>

<%
  try {
    String sql =
      "SELECT C.cid, C.fname, C.lname, C.email, SUM(T.totalFare + T.bookingFee) AS revenue, COUNT(T.ticketID) AS trips " +
      "FROM CUSTOMER C " +
      "JOIN TICKET T ON C.cid = T.cid " +
      "GROUP BY C.cid, C.fname, C.lname, C.email " +
      "ORDER BY revenue DESC " +
      "LIMIT 5";

    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();

    if (rs.next()) {
      double topRevenue = rs.getDouble("revenue");
%>
  <section class="grid grid-aside">
    <article class="ticket reveal reveal-2" style="--stub:220px">
      <div class="ticket-main" style="padding:32px 34px">
        <div class="ticket-top">
          <div class="carrier"><span class="carrier-badge" style="background:var(--ink); color:var(--flap); border-color:var(--ink)"><svg class="ico"><use href="#i-trophy"/></svg></span>
            <div><div class="carrier-name">Contrail Sky Club</div><div class="carrier-sub">Member #<%= String.format("%05d", rs.getInt("cid")) %></div></div></div>
          <span class="pill pill-ink no-dot">Platinum</span>
        </div>
        <span class="label">Member</span>
        <div class="display" style="font-size:clamp(2.4rem,5vw,3.6rem); margin:6px 0 4px"><%= esc(rs.getString("fname")) %> <em><%= esc(rs.getString("lname")) %></em></div>
        <div class="muted"><%= esc(rs.getString("email")) %></div>
        <div class="ticket-meta" style="grid-template-columns: repeat(3, minmax(0,1fr))">
          <div class="meta-item"><span class="label">Customer ID</span><span class="val"><%= rs.getInt("cid") %></span></div>
          <div class="meta-item"><span class="label">Tickets</span><span class="val"><%= rs.getInt("trips") %></span></div>
          <div class="meta-item"><span class="label">Avg. ticket</span><span class="val"><%= money(topRevenue / Math.max(1, rs.getInt("trips"))) %></span></div>
        </div>
      </div>
      <div class="ticket-stub" style="align-items:center; text-align:center; justify-content:center; gap:18px">
        <div>
          <span class="label">Total revenue</span>
          <div class="price" style="margin-top:6px"><%= money(topRevenue) %></div>
        </div>
        <div class="stamp is-go stamp-in">Top flyer<small>No. 1</small></div>
      </div>
    </article>

    <aside class="card reveal reveal-3">
      <div class="card-head"><h3><svg class="ico"><use href="#i-list"/></svg> Leaderboard</h3><span class="caps">Top 5</span></div>
      <div class="bars">
        <div class="bar-row" style="grid-template-columns: 26px minmax(0,1fr) auto">
          <span class="code-chip">1</span>
          <div><b><%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></b><div class="bar-track" style="margin-top:6px"><div class="bar-fill" style="--w:100%"></div></div></div>
          <span class="mono" style="font-weight:600"><%= money(topRevenue) %></span>
        </div>
<%
      int rank = 1;
      while (rs.next()) {
        rank++;
        double rev = rs.getDouble("revenue");
%>
        <div class="bar-row" style="grid-template-columns: 26px minmax(0,1fr) auto">
          <span class="code-chip sand"><%= rank %></span>
          <div><b><%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></b><div class="bar-track" style="margin-top:6px"><div class="bar-fill" style="--w:<%= Math.round(rev * 100 / topRevenue) %>%; background: repeating-linear-gradient(-45deg, var(--sand-400) 0 8px, var(--sand-300) 8px 16px)"></div></div></div>
          <span class="mono" style="font-weight:600"><%= money(rev) %></span>
        </div>
<%
      }
%>
      </div>
    </aside>
  </section>
<%
    } else {
%>
  <div class="empty">
    <h3>No flyers yet</h3>
    <p>No customer records found.</p>
  </div>
<%
    }

    rs.close();
    ps.close();
    conn.close();

  } catch (Exception e) {
%>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Error</strong><p>Error loading data: <%= esc(e.getMessage()) %></p></div></div>
<%
  }
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
