<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeParseException" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%!
  private static String resultTicket(ResultSet rs) throws SQLException {
    Timestamp dep = rs.getTimestamp("departureTime");
    Timestamp arr = rs.getTimestamp("arrivalTime");
    int seatsLeft = rs.getInt("seatCapacity") - rs.getInt("sold");
    boolean full = seatsLeft <= 0;
    String seatPill = full
      ? "<span class=\"pill pill-stamp\">Full &middot; waitlist</span>"
      : seatsLeft <= 3 ? "<span class=\"pill pill-sand\">" + seatsLeft + " seats left</span>"
      : "<span class=\"pill pill-go\">" + seatsLeft + " seats open</span>";
    return "<article class=\"ticket is-hoverable\">"
      + "<div class=\"ticket-main\"><div class=\"ticket-top\">"
      + carrierHtml(rs.getString("airlineID"), rs.getString("airline"),
                    "Flight " + esc(rs.getString("airlineID")) + " " + rs.getInt("flightNum"))
      + seatPill + "</div>"
      + routeHtml(rs.getString("depCode"), rs.getString("depCity"), dep, rs.getString("arrCode"), rs.getString("arrCity"), arr)
      + "</div>"
      + "<div class=\"ticket-stub\"><div><span class=\"label\">Economy from</span>"
      + "<div class=\"price\">$110<small>Fare + booking fee</small></div></div>"
      + "<a class=\"btn " + (full ? "btn-ghost" : "") + "\" href=\"bookFlight.jsp?flightID=" + rs.getInt("flightID") + "\">"
      + (full ? "Join waitlist" : "Book seat") + " <svg class=\"ico ico-go\"><use href=\"#i-arrow\"/></svg></a>"
      + "</div></article>";
  }
%>
<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email     = (String) session.getAttribute("userEmail");
  String trip      = request.getParameter("trip");
  String dep       = request.getParameter("dep");
  String arr       = request.getParameter("arr");
  String date1     = request.getParameter("date1");
  String date2     = request.getParameter("date2");
  boolean flexible = "yes".equals(request.getParameter("flexible"));
  String filtAir   = request.getParameter("airline");
  String sortParam = request.getParameter("sort");
  String depStart  = request.getParameter("depStart");
  String depEnd    = request.getParameter("depEnd");
  String arrStart  = request.getParameter("arrStart");
  String arrEnd    = request.getParameter("arrEnd");

  LocalDate d1 = null, d2 = null;
  LocalDate start1 = null, end1 = null, start2 = null, end2 = null;
  boolean badDate = false;

  try {
    if (date1 != null && !date1.isEmpty()) {
      d1 = LocalDate.parse(date1);
      start1 = flexible ? d1.minusDays(3) : d1;
      end1   = flexible ? d1.plusDays(3)  : d1;
    }
    if ("roundtrip".equals(trip) && date2 != null && !date2.isEmpty()) {
      d2 = LocalDate.parse(date2);
      start2 = flexible ? d2.minusDays(3) : d2;
      end2   = flexible ? d2.plusDays(3)  : d2;
    }
  } catch (DateTimeParseException e) {
    badDate = true;
  }

  String baseSQL =
    "SELECT f.flightID, f.flightNum, f.departureTime, f.arrivalTime, f.airlineID, " +
    "TIMESTAMPDIFF(MINUTE, f.departureTime, f.arrivalTime) AS duration, " +
    "a.name AS airline, ap1.city AS depCity, ap2.city AS arrCity, " +
    "ap1.airportID AS depCode, ap2.airportID AS arrCode, ac.seatCapacity, " +
    "(SELECT COUNT(*) FROM TICKET tk WHERE tk.flightID = f.flightID) AS sold " +
    "FROM FLIGHT f " +
    "JOIN AIRLINE a ON f.airlineID = a.airlineID " +
    "JOIN AIRCRAFT ac ON f.aircraftID = ac.aircraftID " +
    "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
    "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID ";

  String orderBy = "";
  switch (sortParam == null ? "" : sortParam) {
    case "depAsc":  orderBy = " ORDER BY f.departureTime ASC"; break;
    case "depDesc": orderBy = " ORDER BY f.departureTime DESC"; break;
    case "arrAsc":  orderBy = " ORDER BY f.arrivalTime ASC"; break;
    case "arrDesc": orderBy = " ORDER BY f.arrivalTime DESC"; break;
    case "durAsc":  orderBy = " ORDER BY duration ASC"; break;
    case "durDesc": orderBy = " ORDER BY duration DESC"; break;
  }

  boolean hasDep = dep != null && !dep.isEmpty();
  boolean hasArr = arr != null && !arr.isEmpty();
  String fromLabel = hasDep ? dep : "Anywhere";
  String toLabel = hasArr ? arr : "Anywhere";
  java.time.format.DateTimeFormatter df = java.time.format.DateTimeFormatter.ofPattern("EEE, MMM d", java.util.Locale.US);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Flight results"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="search"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A3</span> Concourse A &middot; Departure board</div>
      <h1><%= esc(fromLabel) %> <em>to</em> <%= esc(toLabel) %></h1>
      <p class="lede">
        <%= "roundtrip".equals(trip) ? "Round-trip" : "One-way" %>
        <% if (d1 != null) { %> &middot; departing <%= d1.format(df) %><% } %>
        <% if (d2 != null) { %> &middot; returning <%= d2.format(df) %><% } %>
        <% if (flexible) { %> &middot; flexible &plusmn;3 days<% } %>
        <% if (filtAir != null && !filtAir.isEmpty()) { %> &middot; airline <%= esc(filtAir) %><% } %>
      </p>
    </div>
    <div class="head-actions">
      <a class="btn btn-ghost" href="searchFlights.jsp"><svg class="ico"><use href="#i-search"/></svg> New search</a>
    </div>
  </header>

<% if (badDate) { %>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Check your dates</strong><p>One of the dates wasn't in a format we recognise.</p></div></div>
<% } %>

  <section class="reveal reveal-2">
    <div class="section-title">
      <h2><svg class="ico" style="display:inline;width:.8em;height:.8em;color:var(--sky-500)"><use href="#i-takeoff"/></svg> Outbound</h2>
      <span class="caps"><%= esc(fromLabel) %> &rarr; <%= esc(toLabel) %></span>
    </div>
    <div class="ticket-list">
<%
  List<String> conds1 = new ArrayList<>();
  if (dep != null && !dep.isEmpty()) conds1.add("f.DepartureAirportID = ?");
  if (arr != null && !arr.isEmpty()) conds1.add("f.ArrivalAirportID = ?");
  if (start1 != null && end1 != null) conds1.add("DATE(f.departureTime) BETWEEN ? AND ?");
  if (filtAir != null && !filtAir.isEmpty()) conds1.add("f.airlineID = ?");
  if (depStart != null && !depStart.isEmpty()) conds1.add("TIME(f.departureTime) >= ?");
  if (depEnd != null && !depEnd.isEmpty()) conds1.add("TIME(f.departureTime) <= ?");
  if (arrStart != null && !arrStart.isEmpty()) conds1.add("TIME(f.arrivalTime) >= ?");
  if (arrEnd != null && !arrEnd.isEmpty()) conds1.add("TIME(f.arrivalTime) <= ?");

  String sql1 = baseSQL + (conds1.isEmpty() ? "" : " WHERE " + String.join(" AND ", conds1)) + orderBy;

  ApplicationDB db = new ApplicationDB();
  try (Connection c = db.getConnection();
       PreparedStatement ps = c.prepareStatement(sql1)) {
    int i = 1;
    if (dep != null && !dep.isEmpty()) ps.setString(i++, dep);
    if (arr != null && !arr.isEmpty()) ps.setString(i++, arr);
    if (start1 != null && end1 != null) {
      ps.setDate(i++, java.sql.Date.valueOf(start1));
      ps.setDate(i++, java.sql.Date.valueOf(end1));
    }
    if (filtAir != null && !filtAir.isEmpty()) ps.setString(i++, filtAir);
    if (depStart != null && !depStart.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(depStart + ":00"));
    if (depEnd != null && !depEnd.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(depEnd + ":00"));
    if (arrStart != null && !arrStart.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(arrStart + ":00"));
    if (arrEnd != null && !arrEnd.isEmpty()) ps.setTime(i++, java.sql.Time.valueOf(arrEnd + ":00"));

    ResultSet rs = ps.executeQuery();
    boolean any = false;
    while (rs.next()) {
      any = true;
%>
      <%= resultTicket(rs) %>
<%
    }
    if (!any) {
%>
      <div class="empty">
        <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
          <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
          <g transform="translate(40 20)"><use href="#i-cloud" width="56" height="36" style="color:#E1EDF7"/></g>
          <g transform="translate(96 40)"><use href="#i-cloud" width="36" height="24" style="color:#EEF5FB"/></g>
        </svg>
        <h3>Nothing on the board</h3>
        <p>No outbound flights match those filters. Try flexible dates or clearing the airline and time windows.</p>
        <a class="btn btn-ghost" href="searchFlights.jsp" style="margin-top:10px"><svg class="ico"><use href="#i-back"/></svg> Adjust search</a>
      </div>
<%
    }
  } catch (Exception err) {
%>
      <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Board unavailable</strong><p>Error loading outbound flights.</p></div></div>
<%
  }
%>
    </div>
  </section>

<% if ("roundtrip".equals(trip)) { %>
  <section class="section reveal reveal-3">
    <div class="section-title">
      <h2><svg class="ico" style="display:inline;width:.8em;height:.8em;color:var(--sky-500)"><use href="#i-land"/></svg> Return</h2>
      <span class="caps"><%= esc(toLabel) %> &rarr; <%= esc(fromLabel) %></span>
    </div>
    <div class="ticket-list">
<%
  List<String> conds2 = new ArrayList<>();
  if (arr != null && !arr.isEmpty()) conds2.add("f.DepartureAirportID = ?");
  if (dep != null && !dep.isEmpty()) conds2.add("f.ArrivalAirportID = ?");
  if (start2 != null && end2 != null) conds2.add("DATE(f.departureTime) BETWEEN ? AND ?");
  if (filtAir != null && !filtAir.isEmpty()) conds2.add("f.airlineID = ?");
  if (depStart != null && !depStart.isEmpty()) conds2.add("TIME(f.departureTime) >= ?");
  if (depEnd != null && !depEnd.isEmpty()) conds2.add("TIME(f.departureTime) <= ?");
  if (arrStart != null && !arrStart.isEmpty()) conds2.add("TIME(f.arrivalTime) >= ?");
  if (arrEnd != null && !arrEnd.isEmpty()) conds2.add("TIME(f.arrivalTime) <= ?");

  String sql2 = baseSQL + (conds2.isEmpty() ? "" : " WHERE " + String.join(" AND ", conds2)) + orderBy;

  try (Connection c2 = db.getConnection();
       PreparedStatement ps2 = c2.prepareStatement(sql2)) {
    int j = 1;
    if (arr != null && !arr.isEmpty()) ps2.setString(j++, arr);
    if (dep != null && !dep.isEmpty()) ps2.setString(j++, dep);
    if (start2 != null && end2 != null) {
      ps2.setDate(j++, java.sql.Date.valueOf(start2));
      ps2.setDate(j++, java.sql.Date.valueOf(end2));
    }
    if (filtAir != null && !filtAir.isEmpty()) ps2.setString(j++, filtAir);
    if (depStart != null && !depStart.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(depStart + ":00"));
    if (depEnd != null && !depEnd.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(depEnd + ":00"));
    if (arrStart != null && !arrStart.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(arrStart + ":00"));
    if (arrEnd != null && !arrEnd.isEmpty()) ps2.setTime(j++, java.sql.Time.valueOf(arrEnd + ":00"));

    ResultSet rs2 = ps2.executeQuery();
    boolean any = false;
    while (rs2.next()) {
      any = true;
%>
      <%= resultTicket(rs2) %>
<%
    }
    if (!any) {
%>
      <div class="empty">
        <h3>No way back (yet)</h3>
        <p>No return flights match those filters. Try widening the return date with flexible days.</p>
      </div>
<%
    }
  } catch (Exception err2) {
%>
      <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Board unavailable</strong><p>Error loading return flights.</p></div></div>
<%
  }
%>
    </div>
  </section>
<% } %>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
