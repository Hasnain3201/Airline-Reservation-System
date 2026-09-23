<%@ page import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String summaryType = request.getParameter("type");
  String selectedID = request.getParameter("filterID");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
  PreparedStatement ps = null;
  ResultSet r = null;
  String selectedLabel = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Revenue summary"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="revenue"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C5</span> Concourse C &middot; Ledger</div>
      <h1>Follow the <em>revenue.</em></h1>
      <p class="lede">Every ticket's fare and fee, grouped by a single flight, an airline, or a customer.</p>
    </div>
  </header>

  <form method="get" action="revenueSummary.jsp" class="card reveal reveal-2" style="margin-bottom:28px">
    <div class="fields" style="grid-template-columns: auto minmax(0,1fr) auto; align-items:end">
      <div class="field">
        <span class="label">Group by</span>
        <div class="segmented" role="radiogroup" aria-label="Category">
          <input type="radio" name="type" id="tFlight" value="flight" <%= "flight".equals(summaryType) ? "checked" : "" %> onchange="var f=this.form.filterID; if (f) f.value=''; this.form.submit()">
          <label for="tFlight"><svg class="ico"><use href="#i-plane"/></svg>Flight</label>
          <input type="radio" name="type" id="tAirline" value="airline" <%= "airline".equals(summaryType) ? "checked" : "" %> onchange="var f=this.form.filterID; if (f) f.value=''; this.form.submit()">
          <label for="tAirline"><svg class="ico"><use href="#i-tower"/></svg>Airline</label>
          <input type="radio" name="type" id="tCustomer" value="customer" <%= "customer".equals(summaryType) ? "checked" : "" %> onchange="var f=this.form.filterID; if (f) f.value=''; this.form.submit()">
          <label for="tCustomer"><svg class="ico"><use href="#i-person"/></svg>Customer</label>
        </div>
      </div>
      <div class="field">
<%
  if ("flight".equals(summaryType)) {
%>
        <label for="filterID">Flight</label>
        <select name="filterID" id="filterID">
          <option value="">Select a flight&hellip;</option>
<%
      ps = conn.prepareStatement("SELECT flightID, flightNum, airlineID, DepartureAirportID AS dep, ArrivalAirportID AS arr FROM FLIGHT ORDER BY departureTime");
      r = ps.executeQuery();
      while (r.next()) {
        String fid = r.getString("flightID");
        String lbl = r.getString("airlineID") + " " + r.getString("flightNum") + " \u00B7 " + r.getString("dep") + "\u2013" + r.getString("arr");
        if (fid.equals(selectedID)) selectedLabel = lbl;
%>
          <option value="<%= fid %>" <%= fid.equals(selectedID) ? "selected" : "" %>><%= esc(lbl) %></option>
<%
      }
      r.close(); ps.close();
%>
        </select>
<%
  } else if ("airline".equals(summaryType)) {
%>
        <label for="filterID">Airline</label>
        <select name="filterID" id="filterID">
          <option value="">Select an airline&hellip;</option>
<%
      ps = conn.prepareStatement("SELECT airlineID, name FROM AIRLINE");
      r = ps.executeQuery();
      while (r.next()) {
        String aid = r.getString("airlineID");
        if (aid.equals(selectedID)) selectedLabel = r.getString("name");
%>
          <option value="<%= esc(aid) %>" <%= aid.equals(selectedID) ? "selected" : "" %>><%= esc(r.getString("name")) %></option>
<%
      }
      r.close(); ps.close();
%>
        </select>
<%
  } else if ("customer".equals(summaryType)) {
%>
        <label for="filterID">Customer</label>
        <select name="filterID" id="filterID">
          <option value="">Select a customer&hellip;</option>
<%
      ps = conn.prepareStatement("SELECT cid, fname, lname FROM CUSTOMER");
      r = ps.executeQuery();
      while (r.next()) {
        String cid = r.getString("cid");
        if (cid.equals(selectedID)) selectedLabel = r.getString("fname") + " " + r.getString("lname");
%>
          <option value="<%= cid %>" <%= cid.equals(selectedID) ? "selected" : "" %>><%= esc(r.getString("fname")) %> <%= esc(r.getString("lname")) %></option>
<%
      }
      r.close(); ps.close();
%>
        </select>
<%
  } else {
%>
        <label>Filter</label>
        <select disabled><option>Choose a category first</option></select>
<%
  }
%>
      </div>
      <button type="submit" class="btn"><svg class="ico"><use href="#i-receipt"/></svg> Get revenue</button>
    </div>
  </form>

<%
  if (selectedID != null && !selectedID.isEmpty()) {
    String sql = "";
    if ("flight".equals(summaryType)) {
      sql = "SELECT T.ticketID, T.purchaseDateTime, T.class, T.totalFare, T.bookingFee " +
            "FROM TICKET T JOIN FLIGHT F ON T.flightID = F.flightID " +
            "WHERE F.flightID = ?";
    } else if ("airline".equals(summaryType)) {
      sql = "SELECT T.ticketID, T.purchaseDateTime, T.class, T.totalFare, T.bookingFee " +
            "FROM TICKET T JOIN FLIGHT F ON T.flightID = F.flightID " +
            "JOIN AIRLINE A ON F.airlineID = A.airlineID " +
            "WHERE A.airlineID = ?";
    } else if ("customer".equals(summaryType)) {
      sql = "SELECT T.ticketID, T.purchaseDateTime, T.class, T.totalFare, T.bookingFee " +
            "FROM TICKET T WHERE T.cid = ?";
    }

    ps = conn.prepareStatement(sql);
    ps.setString(1, selectedID);
    r = ps.executeQuery();

    double total = 0;
    int count = 0;
%>
  <div class="section-title reveal reveal-3">
    <h2>Detailed <em>breakdown</em></h2>
    <span class="caps"><%= esc(summaryType) %> &middot; <%= esc(selectedLabel != null ? selectedLabel : selectedID) %></span>
  </div>
  <div class="table-wrap reveal reveal-3">
    <table class="manifest">
      <thead>
        <tr><th>Ticket</th><th>Purchased</th><th>Class</th><th class="right">Fare</th><th class="right">Booking fee</th><th class="right">Total</th></tr>
      </thead>
      <tbody>
<%
    while (r.next()) {
      double fare = r.getDouble("totalFare");
      double fee  = r.getDouble("bookingFee");
      total += (fare + fee);
      count++;
%>
        <tr>
          <td><span class="code-chip">#<%= r.getInt("ticketID") %></span></td>
          <td class="num"><%= fmtDateTime(r.getTimestamp("purchaseDateTime")) %></td>
          <td><%= esc(r.getString("class")) %></td>
          <td class="right num"><%= money(fare) %></td>
          <td class="right num"><%= money(fee) %></td>
          <td class="right num"><b><%= money(fare + fee) %></b></td>
        </tr>
<%
    }
    r.close(); ps.close();
    if (count == 0) {
%>
        <tr><td colspan="6" class="empty-cell">No tickets sold for this selection yet.</td></tr>
<%
    }
%>
      </tbody>
      <tfoot>
        <tr><td colspan="5">Total revenue &middot; <%= count %> <%= count == 1 ? "ticket" : "tickets" %></td><td class="right num" style="font-size:1.05rem"><%= money(total) %></td></tr>
      </tfoot>
    </table>
  </div>
<%
  } else {
%>
  <div class="empty reveal reveal-3">
    <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
      <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
      <g transform="translate(56 24)" fill="#A7C8E3"><use href="#i-receipt" width="48" height="48"/></g>
    </svg>
    <h3>Choose what to total up</h3>
    <p>Pick a category, then a flight, airline or customer.</p>
  </div>
<%
  }

  conn.close();
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
