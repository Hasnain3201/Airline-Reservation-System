<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

  String selectedAirport = request.getParameter("airportID");
  String selectedName = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Airport board"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="airport"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B7</span> Concourse B &middot; Airport boards</div>
      <h1>Every flight at <em><%= selectedAirport != null && !selectedAirport.isEmpty() ? esc(selectedAirport) : "one airport." %></em></h1>
      <p class="lede">Departures and arrivals for any airport in the network, straight off the split-flap board.</p>
    </div>
    <form method="get" class="head-actions" style="min-width:280px">
      <div class="field" style="width:100%">
        <label for="airportID">Airport</label>
        <select name="airportID" id="airportID" onchange="this.form.submit()" required>
          <option value="">Select an airport&hellip;</option>
<%
  ResultSet rsAirports = conn.createStatement().executeQuery("SELECT airportID, name FROM AIRPORT ORDER BY airportID");
  while (rsAirports.next()) {
    String aid = rsAirports.getString("airportID");
    if (aid.equals(selectedAirport)) selectedName = rsAirports.getString("name");
%>
          <option value="<%= esc(aid) %>" <%= aid.equals(selectedAirport) ? "selected" : "" %>><%= esc(aid) %> &middot; <%= esc(rsAirports.getString("name")) %></option>
<% } rsAirports.close(); %>
        </select>
      </div>
    </form>
  </header>

<%
  if (selectedAirport != null && !selectedAirport.isEmpty()) {
%>
  <div class="grid grid-2">
    <section class="board reveal reveal-2">
      <div class="board-head">
        <div class="board-title"><svg class="ico"><use href="#i-takeoff"/></svg> Departures &middot; <%= esc(selectedAirport) %></div>
        <span class="caps" style="color:rgba(200,221,238,.6)"><%= esc(selectedName) %></span>
      </div>
      <div class="board-scroll">
      <table>
        <thead><tr><th>Flight</th><th>To</th><th>Time</th><th>Date</th><th class="hide-sm">ID</th></tr></thead>
        <tbody>
<%
    PreparedStatement psDep = conn.prepareStatement("SELECT flightID, flightNum, airlineID, ArrivalAirportID, departureTime, arrivalTime FROM FLIGHT WHERE DepartureAirportID = ? ORDER BY departureTime");
    psDep.setString(1, selectedAirport);
    ResultSet rsDep = psDep.executeQuery();
    boolean anyDep = false;
    while (rsDep.next()) {
      anyDep = true;
      Timestamp t = rsDep.getTimestamp("departureTime");
%>
          <tr class="board-row">
            <td><span data-flap><%= esc(rsDep.getString("airlineID")) %><%= rsDep.getInt("flightNum") %></span></td>
            <td><span data-flap class="is-sky"><%= esc(rsDep.getString("ArrivalAirportID")) %></span></td>
            <td><span data-flap><%= fmtTime(t) %></span></td>
            <td><span data-flap class="is-amber"><%= new java.text.SimpleDateFormat("MMM dd", Locale.US).format(t) %></span></td>
            <td class="hide-sm"><span data-flap class="is-sky"><%= rsDep.getInt("flightID") %></span></td>
          </tr>
<%
    }
    if (!anyDep) {
%>
          <tr class="board-row"><td colspan="5"><span data-flap class="is-amber">NO DEPARTURES</span></td></tr>
<%
    }
    rsDep.close();
    psDep.close();
%>
        </tbody>
      </table>
      </div>
    </section>

    <section class="board reveal reveal-3">
      <div class="board-head">
        <div class="board-title"><svg class="ico"><use href="#i-land"/></svg> Arrivals &middot; <%= esc(selectedAirport) %></div>
        <span class="caps" style="color:rgba(200,221,238,.6)"><%= esc(selectedName) %></span>
      </div>
      <div class="board-scroll">
      <table>
        <thead><tr><th>Flight</th><th>From</th><th>Time</th><th>Date</th><th class="hide-sm">ID</th></tr></thead>
        <tbody>
<%
    PreparedStatement psArr = conn.prepareStatement("SELECT flightID, flightNum, airlineID, DepartureAirportID, departureTime, arrivalTime FROM FLIGHT WHERE ArrivalAirportID = ? ORDER BY arrivalTime");
    psArr.setString(1, selectedAirport);
    ResultSet rsArr = psArr.executeQuery();
    boolean anyArr = false;
    while (rsArr.next()) {
      anyArr = true;
      Timestamp t = rsArr.getTimestamp("arrivalTime");
%>
          <tr class="board-row">
            <td><span data-flap><%= esc(rsArr.getString("airlineID")) %><%= rsArr.getInt("flightNum") %></span></td>
            <td><span data-flap class="is-sky"><%= esc(rsArr.getString("DepartureAirportID")) %></span></td>
            <td><span data-flap><%= fmtTime(t) %></span></td>
            <td><span data-flap class="is-amber"><%= new java.text.SimpleDateFormat("MMM dd", Locale.US).format(t) %></span></td>
            <td class="hide-sm"><span data-flap class="is-sky"><%= rsArr.getInt("flightID") %></span></td>
          </tr>
<%
    }
    if (!anyArr) {
%>
          <tr class="board-row"><td colspan="5"><span data-flap class="is-amber">NO ARRIVALS</span></td></tr>
<%
    }
    rsArr.close();
    psArr.close();
%>
        </tbody>
      </table>
      </div>
    </section>
  </div>
<%
  } else {
%>
  <div class="empty reveal reveal-2">
    <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
      <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
      <g transform="translate(56 24)" fill="#A7C8E3"><use href="#i-tower" width="48" height="48"/></g>
    </svg>
    <h3>Choose an airport</h3>
    <p>Its departure and arrival boards will light up here.</p>
  </div>
<%
  }
  conn.close();
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
