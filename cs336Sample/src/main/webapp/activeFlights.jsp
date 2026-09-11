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
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Most active flights"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="active"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C7</span> Concourse C &middot; Traffic control</div>
      <h1>The busiest <em>routes.</em></h1>
      <p class="lede">The ten most active flights on the network, ranked by tickets sold.</p>
    </div>
  </header>

<%
  try {
    String sql =
      "SELECT F.flightID, F.flightNum, F.airlineID, F.DepartureAirportID AS dep, F.ArrivalAirportID AS arr, " +
      "A.name AS airline, COUNT(T.ticketID) AS ticketsSold, AC.seatCapacity " +
      "FROM TICKET T " +
      "JOIN FLIGHT F ON T.flightID = F.flightID " +
      "JOIN AIRLINE A ON F.airlineID = A.airlineID " +
      "JOIN AIRCRAFT AC ON F.aircraftID = AC.aircraftID " +
      "GROUP BY F.flightID, F.flightNum, F.airlineID, F.DepartureAirportID, F.ArrivalAirportID, A.name, AC.seatCapacity " +
      "ORDER BY ticketsSold DESC " +
      "LIMIT 10";

    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();
%>
  <section class="board reveal reveal-2">
    <div class="board-head">
      <div class="board-title"><svg class="ico"><use href="#i-chart"/></svg> Traffic &middot; Tickets sold</div>
      <span class="caps" style="color:rgba(200,221,238,.6)">Top 10</span>
    </div>
    <div class="board-scroll">
    <table>
      <thead><tr><th>Rank</th><th>Flight</th><th>Route</th><th class="hide-sm">Airline</th><th>Sold</th><th style="width:30%">Load</th></tr></thead>
      <tbody>
<%
    int rank = 0;
    while (rs.next()) {
      rank++;
      int sold = rs.getInt("ticketsSold");
      int cap = rs.getInt("seatCapacity");
      int load = cap > 0 ? Math.min(100, Math.round(sold * 100f / cap)) : 0;
%>
        <tr class="board-row">
          <td><span data-flap class="is-amber"><%= String.format("%02d", rank) %></span></td>
          <td><span data-flap><%= esc(rs.getString("airlineID")) %><%= rs.getString("flightNum") %></span></td>
          <td><span data-flap class="is-sky"><%= esc(rs.getString("dep")) %>-<%= esc(rs.getString("arr")) %></span></td>
          <td class="hide-sm" style="font-family:var(--f-sans); color:var(--sky-200)"><%= esc(rs.getString("airline")) %></td>
          <td><span data-flap class="is-go"><%= String.format("%02d", sold) %></span></td>
          <td>
            <div style="display:flex; align-items:center; gap:10px">
              <div class="bar-track" style="flex:1; background:rgba(255,255,255,.06); box-shadow:none"><div class="bar-fill" style="--w:<%= load %>%; background: repeating-linear-gradient(-45deg, #A7C8E3 0 8px, #7FAAD0 8px 16px)"></div></div>
              <span style="font-size:.72rem; color:var(--sky-300); min-width:36px; text-align:right"><%= load %>%</span>
            </div>
          </td>
        </tr>
<%
    }
    if (rank == 0) {
%>
        <tr class="board-row"><td colspan="6"><span data-flap class="is-amber">NO TICKETS SOLD</span></td></tr>
<%
    }
    rs.close();
    ps.close();
    conn.close();
%>
      </tbody>
    </table>
    </div>
    <div class="board-foot"><span>Load = tickets sold / seat capacity</span><span>Concourse C</span></div>
  </section>
<%
  } catch (Exception e) {
%>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Error</strong><p>Error loading active flights: <%= esc(e.getMessage()) %></p></div></div>
<%
  }
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
