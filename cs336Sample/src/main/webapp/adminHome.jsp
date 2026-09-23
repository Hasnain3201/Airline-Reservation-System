<%@ page language="java" import="javax.servlet.http.*, java.sql.*, java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) s.getAttribute("userEmail");

  double revenue = 0;
  int tickets = 0, customers = 0, reps = 0, flights = 0;
  List<Object[]> byClass = new ArrayList<>();
  double maxClass = 0;
  try (Connection conn = new ApplicationDB().getConnection();
       Statement st = conn.createStatement()) {
    ResultSet r = st.executeQuery("SELECT COUNT(*), COALESCE(SUM(totalFare + bookingFee), 0) FROM TICKET");
    if (r.next()) { tickets = r.getInt(1); revenue = r.getDouble(2); }
    r = st.executeQuery("SELECT COUNT(*) FROM CUSTOMER");
    if (r.next()) customers = r.getInt(1);
    r = st.executeQuery("SELECT COUNT(*) FROM CUSTOMERREP");
    if (r.next()) reps = r.getInt(1);
    r = st.executeQuery("SELECT COUNT(*) FROM FLIGHT");
    if (r.next()) flights = r.getInt(1);
    r = st.executeQuery("SELECT class, COUNT(*) AS n, SUM(totalFare + bookingFee) AS rev FROM TICKET GROUP BY class ORDER BY rev DESC");
    while (r.next()) {
      double rev = r.getDouble("rev");
      maxClass = Math.max(maxClass, rev);
      byClass.add(new Object[] { r.getString("class"), r.getInt("n"), rev });
    }
  } catch (Exception err) {
    // fail silently
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Control tower"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="home"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C1</span> Concourse C &middot; Control tower</div>
      <h1>The view from the <em>tower.</em></h1>
      <p class="lede">Signed in as <%= esc(email) %>. Everything moving through the terminal, at a glance.</p>
    </div>
    <div class="head-actions">
      <span class="caps" style="align-self:center">Tower time</span>
      <span class="flap flap-light flap-lg" data-clock>00:00</span>
    </div>
  </header>

  <section class="stats reveal reveal-2">
    <div class="stat is-ink">
      <span class="label caps"><svg class="ico"><use href="#i-receipt"/></svg> Revenue</span>
      <div class="value"><%= money(revenue) %></div>
      <div class="foot">Fares + booking fees, all time</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-luggage"/></svg> Tickets</span>
      <div class="value"><%= tickets %></div>
      <div class="foot">Seats sold across the network</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-group"/></svg> People</span>
      <div class="value"><%= customers %></div>
      <div class="foot">Customers &middot; <%= reps %> <%= reps == 1 ? "representative" : "representatives" %></div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-takeoff"/></svg> Flights</span>
      <div class="value"><%= flights %></div>
      <div class="foot">On the schedule</div>
    </div>
  </section>

  <section class="section grid grid-aside">
    <nav class="gates reveal reveal-3" aria-label="Reports">
      <a class="gate-row" href="manageUsers.jsp">
        <span class="gate-sign">C2</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-group"/></svg>Customers &amp; representatives</span><span class="gr-sub">Add, edit and remove accounts</span></span>
        <span class="gr-status pill pill-sand">People</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="salesReport.jsp">
        <span class="gate-sign">C3</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-chart"/></svg>Monthly sales report</span><span class="gr-sub">Tickets and revenue for any month</span></span>
        <span class="gr-status pill">Report</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="reservationLookup.jsp">
        <span class="gate-sign">C4</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-search"/></svg>Reservation lookup</span><span class="gr-sub">Find bookings by flight or customer</span></span>
        <span class="gr-status pill">Search</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="revenueSummary.jsp">
        <span class="gate-sign">C5</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-receipt"/></svg>Revenue summary</span><span class="gr-sub">By flight, airline or customer</span></span>
        <span class="gr-status pill">Report</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="topCustomer.jsp">
        <span class="gate-sign">C6</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-trophy"/></svg>Top revenue customer</span><span class="gr-sub">Our most valuable flyer</span></span>
        <span class="gr-status pill pill-sand">Insight</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="activeFlights.jsp">
        <span class="gate-sign">C7</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-takeoff"/></svg>Most active flights</span><span class="gr-sub">Ranked by tickets sold</span></span>
        <span class="gr-status pill pill-sand">Insight</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
    </nav>

    <section class="card reveal reveal-4">
      <div class="card-head">
        <h3><svg class="ico"><use href="#i-chart"/></svg> Revenue by cabin</h3>
        <span class="caps">All time</span>
      </div>
<% if (byClass.isEmpty()) { %>
      <p class="muted">No tickets sold yet.</p>
<% } else { %>
      <div class="bars">
<%   for (Object[] c : byClass) {
       double rev = (Double) c[2];
       int pct = maxClass > 0 ? (int) Math.round(rev * 100 / maxClass) : 0; %>
        <div class="bar-row">
          <span><b><%= esc(c[0]) %></b><br><span class="caps"><%= c[1] %> tickets</span></span>
          <div class="bar-track"><div class="bar-fill" style="--w:<%= pct %>%"></div></div>
          <span class="mono" style="font-weight:600"><%= money(rev) %></span>
        </div>
<%   } %>
      </div>
<% } %>
      <div class="flightpath-rule" style="margin:26px 0 18px"></div>
      <div class="btn-row">
        <a class="btn btn-sm" href="salesReport.jsp"><svg class="ico"><use href="#i-chart"/></svg> Monthly report</a>
        <a class="btn btn-ghost btn-sm" href="revenueSummary.jsp">Revenue detail</a>
      </div>
    </section>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
