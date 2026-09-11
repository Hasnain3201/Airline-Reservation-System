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
  String month = request.getParameter("month");
  String year = request.getParameter("year");

  double totalRevenue = 0;
  int totalTickets = 0;
  String reportError = null;

  class ClassSummary {
    String name;
    int count;
    double revenue;
    ClassSummary(String name, int count, double revenue) {
      this.name = name;
      this.count = count;
      this.revenue = revenue;
    }
  }

  java.util.List<ClassSummary> classData = new java.util.ArrayList<>();

  if (month != null && year != null) {
    try {
      ApplicationDB db = new ApplicationDB();
      Connection conn = db.getConnection();

      java.time.YearMonth ym = java.time.YearMonth.of(Integer.parseInt(year.trim()), Integer.parseInt(month.trim()));
      String startDate = ym.atDay(1) + " 00:00:00";
      String endDate = ym.atEndOfMonth() + " 23:59:59";

      // Total Summary
      PreparedStatement ps = conn.prepareStatement(
        "SELECT COUNT(*) AS ticketCount, SUM(totalFare + bookingFee) AS revenue " +
        "FROM TICKET WHERE purchaseDateTime BETWEEN ? AND ?");
      ps.setString(1, startDate);
      ps.setString(2, endDate);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        totalTickets = rs.getInt("ticketCount");
        totalRevenue = rs.getDouble("revenue");
      }
      rs.close();
      ps.close();

      // Per Class Breakdown
      PreparedStatement ps2 = conn.prepareStatement(
        "SELECT class, COUNT(*) AS count, SUM(totalFare + bookingFee) AS revenue " +
        "FROM TICKET WHERE purchaseDateTime BETWEEN ? AND ? GROUP BY class ORDER BY revenue DESC");
      ps2.setString(1, startDate);
      ps2.setString(2, endDate);
      ResultSet rs2 = ps2.executeQuery();
      while (rs2.next()) {
        String cls = rs2.getString("class");
        int count = rs2.getInt("count");
        double rev = rs2.getDouble("revenue");
        classData.add(new ClassSummary(cls, count, rev));
      }
      rs2.close();
      ps2.close();
      conn.close();
    } catch (Exception e) {
      reportError = e.getMessage();
    }
  }

  java.time.LocalDate today = java.time.LocalDate.now();
  String selMonth = month != null ? month : String.format("%02d", today.getMonthValue());
  String selYear = year != null ? year : Integer.toString(today.getYear());
  String[] monthNames = {"January","February","March","April","May","June","July","August","September","October","November","December"};
  String monthLabel = month;
  try { monthLabel = monthNames[Integer.parseInt(month) - 1]; } catch (Exception ignored) { }
  double maxRev = 0;
  for (ClassSummary c : classData) maxRev = Math.max(maxRev, c.revenue);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Monthly sales"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="sales"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C3</span> Concourse C &middot; Ledger</div>
      <h1>Monthly <em>sales.</em></h1>
      <p class="lede">Tickets sold and revenue earned for any month, broken down by cabin.</p>
    </div>
  </header>

  <form method="get" action="salesReport.jsp" class="card reveal reveal-2" style="margin-bottom:28px">
    <div class="fields" style="grid-template-columns: minmax(0,1fr) minmax(0,1fr) auto; align-items:end">
      <div class="field">
        <label for="month">Month</label>
        <select name="month" id="month" required>
<% for (int m = 1; m <= 12; m++) { String mm = String.format("%02d", m); %>
          <option value="<%= mm %>" <%= mm.equals(selMonth) ? "selected" : "" %>><%= mm %> &middot; <%= monthNames[m - 1] %></option>
<% } %>
        </select>
      </div>
      <div class="field">
        <label for="year">Year</label>
        <input type="text" name="year" id="year" value="<%= esc(selYear) %>" placeholder="e.g. 2026" pattern="[0-9]{4}" required />
      </div>
      <button type="submit" class="btn"><svg class="ico"><use href="#i-chart"/></svg> Generate report</button>
    </div>
  </form>

<% if (reportError != null) { %>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Report unavailable</strong><p>Error retrieving report: <%= esc(reportError) %></p></div></div>
<% } %>

<%
  if (month != null && year != null) {
%>
  <div class="section-title reveal reveal-3">
    <h2><%= esc(monthLabel) %> <em><%= esc(year) %></em></h2>
    <span class="caps">Report for <%= esc(month) %>/<%= esc(year) %></span>
  </div>

  <section class="stats reveal reveal-3" style="grid-template-columns: repeat(3, minmax(0,1fr))">
    <div class="stat is-ink">
      <span class="label caps"><svg class="ico"><use href="#i-receipt"/></svg> Total revenue</span>
      <div class="value"><%= money(totalRevenue) %></div>
      <div class="foot">Fares + booking fees</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-luggage"/></svg> Tickets sold</span>
      <div class="value"><%= totalTickets %></div>
      <div class="foot">Purchased this month</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-chart"/></svg> Average ticket</span>
      <div class="value"><%= totalTickets > 0 ? money(totalRevenue / totalTickets) : "$0.00" %></div>
      <div class="foot">Revenue per seat</div>
    </div>
  </section>

  <section class="section grid grid-2 reveal reveal-4">
    <div class="card">
      <div class="card-head"><h3><svg class="ico"><use href="#i-seat"/></svg> Revenue by ticket class</h3></div>
<% if (classData.isEmpty()) { %>
      <p class="muted">No ticket class data found.</p>
<% } else { %>
      <div class="bars">
<%   for (ClassSummary row : classData) { %>
        <div class="bar-row">
          <span><b><%= esc(row.name) %></b></span>
          <div class="bar-track"><div class="bar-fill" style="--w:<%= maxRev > 0 ? Math.round(row.revenue * 100 / maxRev) : 0 %>%"></div></div>
          <span class="mono" style="font-weight:600"><%= money(row.revenue) %></span>
        </div>
<%   } %>
      </div>
<% } %>
    </div>
    <div class="table-wrap">
      <table class="manifest">
        <thead><tr><th>Class</th><th class="right">Tickets sold</th><th class="right">Revenue</th></tr></thead>
        <tbody>
<%
    for (ClassSummary row : classData) {
%>
          <tr><td><b><%= esc(row.name) %></b></td><td class="right num"><%= row.count %></td><td class="right num"><%= money(row.revenue) %></td></tr>
<%
    }
    if (classData.isEmpty()) {
%>
          <tr><td colspan="3" class="empty-cell">No ticket class data found.</td></tr>
<%
    }
%>
        </tbody>
        <tfoot><tr><td>Total</td><td class="right num"><%= totalTickets %></td><td class="right num"><%= money(totalRevenue) %></td></tr></tfoot>
      </table>
    </div>
  </section>
<%
  }
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
