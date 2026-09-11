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
  String selectedFlight = request.getParameter("flightID");
  String selectedCustomer = request.getParameter("cid");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Reservation lookup"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="lookup"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C4</span> Concourse C &middot; Records office</div>
      <h1>Find a <em>reservation.</em></h1>
      <p class="lede">Search the manifest by flight, by customer, or both at once.</p>
    </div>
  </header>

  <form method="get" action="reservationLookup.jsp" class="card reveal reveal-2" style="margin-bottom:28px">
    <div class="fields" style="grid-template-columns: minmax(0,1fr) minmax(0,1fr) auto; align-items:end">
      <div class="field">
        <label for="flightID">Flight</label>
        <select name="flightID" id="flightID">
          <option value="">Any flight</option>
<%
      try (PreparedStatement ps = conn.prepareStatement("SELECT flightID, flightNum, airlineID, DepartureAirportID AS dep, ArrivalAirportID AS arr FROM FLIGHT ORDER BY departureTime")) {
        ResultSet r = ps.executeQuery();
        while (r.next()) {
          String fid = r.getString("flightID");
%>
          <option value="<%= fid %>" <%= fid.equals(selectedFlight) ? "selected" : "" %>><%= esc(r.getString("airlineID")) %> <%= r.getString("flightNum") %> &middot; <%= esc(r.getString("dep")) %>&ndash;<%= esc(r.getString("arr")) %></option>
<%
        }
      }
%>
        </select>
      </div>
      <div class="field">
        <label for="cid">Customer</label>
        <select name="cid" id="cid">
          <option value="">Any customer</option>
<%
      try (PreparedStatement ps = conn.prepareStatement("SELECT cid, fname, lname FROM CUSTOMER")) {
        ResultSet r = ps.executeQuery();
        while (r.next()) {
          String cid = r.getString("cid");
%>
          <option value="<%= cid %>" <%= cid.equals(selectedCustomer) ? "selected" : "" %>><%= esc(r.getString("fname")) %> <%= esc(r.getString("lname")) %></option>
<%
        }
      }
%>
        </select>
      </div>
      <button type="submit" class="btn"><svg class="ico"><use href="#i-search"/></svg> Search</button>
    </div>
  </form>

<%
  if ((selectedFlight != null && !selectedFlight.isEmpty()) || (selectedCustomer != null && !selectedCustomer.isEmpty())) {
    StringBuilder query = new StringBuilder(
      "SELECT T.ticketID, T.totalFare, T.purchaseDateTime, T.class, T.seatNumber, " +
      "F.flightNum, F.airlineID, F.DepartureAirportID AS dep, F.ArrivalAirportID AS arr, " +
      "C.fname AS custF, C.lname AS custL, " +
      "P.fname AS passF, P.lname AS passL " +
      "FROM TICKET T " +
      "JOIN CUSTOMER C ON T.cid = C.cid " +
      "JOIN FLIGHT F ON T.flightID = F.flightID " +
      "JOIN PASSENGER P ON T.passengerID = P.passengerID " +
      "WHERE 1=1 "
    );

    if (selectedFlight != null && !selectedFlight.isEmpty()) {
      query.append("AND T.flightID = ? ");
    }
    if (selectedCustomer != null && !selectedCustomer.isEmpty()) {
      query.append("AND T.cid = ? ");
    }
    query.append("ORDER BY T.purchaseDateTime DESC");

    PreparedStatement ps = conn.prepareStatement(query.toString());

    try {
      int paramIdx = 1;
      if (selectedFlight != null && !selectedFlight.isEmpty()) {
        ps.setInt(paramIdx++, Integer.parseInt(selectedFlight));
      }
      if (selectedCustomer != null && !selectedCustomer.isEmpty()) {
        ps.setInt(paramIdx++, Integer.parseInt(selectedCustomer));
      }

      ResultSet rs = ps.executeQuery();
%>
  <div class="section-title reveal reveal-3"><h2>Matching <em>reservations</em></h2><span class="caps">Newest first</span></div>
  <div class="table-wrap reveal reveal-3">
    <table class="manifest" style="min-width:900px">
      <thead>
        <tr><th>Ticket</th><th>Customer</th><th>Passenger</th><th>Flight</th><th>Class</th><th>Seat</th><th class="right">Fare</th><th>Purchased</th></tr>
      </thead>
      <tbody>
<%
      boolean hasResults = false;
      while (rs.next()) {
        hasResults = true;
        String cls = rs.getString("class");
%>
        <tr>
          <td><span class="code-chip">#<%= rs.getInt("ticketID") %></span></td>
          <td><b><%= esc(rs.getString("custF")) %> <%= esc(rs.getString("custL")) %></b></td>
          <td><%= esc(rs.getString("passF")) %> <%= esc(rs.getString("passL")) %></td>
          <td class="num"><%= esc(rs.getString("airlineID")) %> <%= rs.getInt("flightNum") %> <span class="muted">&middot; <%= esc(rs.getString("dep")) %>&ndash;<%= esc(rs.getString("arr")) %></span></td>
          <td><span class="pill <%= "First".equals(cls) ? "pill-ink" : "Business".equals(cls) ? "" : "pill-sand" %> no-dot"><%= esc(cls) %></span></td>
          <td class="num"><%= esc(rs.getString("seatNumber")) %></td>
          <td class="right num"><%= money(rs.getDouble("totalFare")) %></td>
          <td class="num"><%= fmtDateTime(rs.getTimestamp("purchaseDateTime")) %></td>
        </tr>
<%
      }
      if (!hasResults) {
%>
        <tr><td colspan="8" class="empty-cell">No reservations found.</td></tr>
<%
      }
      rs.close();
%>
      </tbody>
    </table>
  </div>
<%
    } catch (NumberFormatException ex) {
%>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Invalid input</strong><p>Customer or Flight ID is not a number.</p></div></div>
<%
    }

    ps.close();
  } else {
%>
  <div class="empty reveal reveal-3">
    <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
      <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
      <g transform="translate(56 24)" fill="#A7C8E3"><use href="#i-search" width="48" height="48"/></g>
    </svg>
    <h3>Pick a flight or customer</h3>
    <p>Matching tickets will be listed here.</p>
  </div>
<%
  }

  conn.close();
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
