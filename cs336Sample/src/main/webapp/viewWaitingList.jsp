<%@ page import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) s.getAttribute("userEmail");
  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
  String selectedFlightID = request.getParameter("flightID");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Waitlist"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="waitlist"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B6</span> Concourse B &middot; Standby desk</div>
      <h1>Who's on <em>standby?</em></h1>
      <p class="lede">Pick a flight to see every passenger waiting for a seat to open, in the order they asked.</p>
    </div>
  </header>

  <form method="get" class="card reveal reveal-2" style="margin-bottom:28px">
    <div class="fields" style="grid-template-columns: minmax(0, 1fr) auto; align-items:end">
      <div class="field">
        <label for="flightID">Flight</label>
        <select name="flightID" id="flightID" required>
          <option value="">Select a flight&hellip;</option>
<%
  ResultSet allFlights = conn.createStatement().executeQuery(
    "SELECT f.flightID, f.flightNum, f.airlineID, f.DepartureAirportID AS dep, f.ArrivalAirportID AS arr, f.departureTime, " +
    "(SELECT COUNT(*) FROM WAITLIST w WHERE w.flightID = f.flightID) AS waiting " +
    "FROM FLIGHT f ORDER BY f.departureTime");
  while (allFlights.next()) {
    String fid = allFlights.getString("flightID");
    String fnum = allFlights.getString("flightNum");
    int waiting = allFlights.getInt("waiting");
%>
          <option value="<%= fid %>" <%= fid.equals(selectedFlightID) ? "selected" : "" %>><%= esc(allFlights.getString("airlineID")) %> <%= fnum %> &middot; <%= esc(allFlights.getString("dep")) %>&ndash;<%= esc(allFlights.getString("arr")) %> &middot; <%= fmtDate(allFlights.getTimestamp("departureTime")) %> (ID <%= fid %>)<%= waiting > 0 ? " \u2014 " + waiting + " waiting" : "" %></option>
<% } allFlights.close(); %>
        </select>
      </div>
      <button type="submit" class="btn"><svg class="ico"><use href="#i-hourglass"/></svg> Check waiting list</button>
    </div>
  </form>

<%
  if (selectedFlightID != null && !selectedFlightID.isEmpty()) {
    try {
      PreparedStatement ps = conn.prepareStatement(
        "SELECT w.cid, c.fname, c.lname, c.email, w.dateOfRequest " +
        "FROM WAITLIST w JOIN CUSTOMER c ON w.cid = c.cid " +
        "WHERE w.flightID = ? ORDER BY w.dateOfRequest"
      );
      ps.setInt(1, Integer.parseInt(selectedFlightID));
      ResultSet rs = ps.executeQuery();
%>
  <div class="section-title reveal reveal-3">
    <h2>Standby for flight <em>#<%= esc(selectedFlightID) %></em></h2>
    <span class="caps">First come, first seated</span>
  </div>
  <div class="strips reveal reveal-3">
<%
      boolean found = false;
      int pos = 0;
      while (rs.next()) {
        found = true;
        pos++;
%>
    <div class="strip <%= pos == 1 ? "is-ink" : "" %>" style="--cols:3">
      <div class="strip-tab">SBY <%= pos %></div>
      <div><span class="k">Customer #<%= rs.getInt("cid") %></span><span class="v big"><%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></span></div>
      <div><span class="k">Email</span><span class="v"><%= esc(rs.getString("email")) %></span></div>
      <div><span class="k">Requested</span><span class="v"><%= fmtDateTime(rs.getTimestamp("dateOfRequest")) %></span></div>
      <div class="strip-act"><span class="pill <%= pos == 1 ? "pill-go" : "pill-sand" %>"><%= pos == 1 ? "Next up" : "Waiting" %></span></div>
    </div>
<%
      }
      if (!found) {
%>
    <div class="empty">
      <h3>Nobody on standby</h3>
      <p>No customers are currently on the waitlist for this flight.</p>
    </div>
<%
      }
      rs.close(); ps.close();
    } catch (Exception e) {
%>
    <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Error</strong><p><%= esc(e.getMessage()) %></p></div></div>
<%
    }
%>
  </div>
<%
  }

  conn.close();
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
