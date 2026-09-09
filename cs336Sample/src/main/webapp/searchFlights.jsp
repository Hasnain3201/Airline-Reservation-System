<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) session.getAttribute("userEmail");

  ApplicationDB db = new ApplicationDB();
  List<String[]> airports = new ArrayList<>();
  List<String[]> airlines = new ArrayList<>();
  List<String[]> popular = new ArrayList<>();
  boolean loadFailed = false;
  try (Connection c = db.getConnection()) {
    try (Statement s = c.createStatement();
         ResultSet r = s.executeQuery("SELECT airportID, city FROM AIRPORT ORDER BY airportID")) {
      while (r.next()) airports.add(new String[] { r.getString("airportID"), r.getString("city") });
    }
    try (Statement s = c.createStatement();
         ResultSet r = s.executeQuery("SELECT airlineID, name FROM AIRLINE ORDER BY name")) {
      while (r.next()) airlines.add(new String[] { r.getString("airlineID"), r.getString("name") });
    }
    try (Statement s = c.createStatement();
         ResultSet r = s.executeQuery(
           "SELECT f.DepartureAirportID AS dep, f.ArrivalAirportID AS arr, ap1.city AS depCity, ap2.city AS arrCity, " +
           "MIN(f.departureTime) AS nextDep, COUNT(*) AS n " +
           "FROM FLIGHT f JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
           "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
           "WHERE f.departureTime >= NOW() GROUP BY f.DepartureAirportID, f.ArrivalAirportID, ap1.city, ap2.city " +
           "ORDER BY nextDep LIMIT 4")) {
      while (r.next()) {
        popular.add(new String[] {
          r.getString("dep"), r.getString("arr"), r.getString("depCity"), r.getString("arrCity"),
          fmtDate(r.getTimestamp("nextDep")), r.getString("n")
        });
      }
    }
  } catch (Exception e) {
    loadFailed = true;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Search flights"/></jsp:include>
  <script>
    function toggleRoundtripRequirements() {
      const isRoundtrip = document.getElementById('tripRound').checked;
      const dep = document.getElementById('dep');
      const arr = document.getElementById('arr');
      const date1 = document.getElementById('date1');
      const date2 = document.getElementById('date2');
      const returnRow = document.getElementById('returnRow');

      [dep, arr, date1, date2].forEach(function (el) {
        if (isRoundtrip) el.setAttribute('required', 'required');
        else el.removeAttribute('required');
      });
      returnRow.classList.toggle('is-hidden', !isRoundtrip);
      date2.disabled = !isRoundtrip;
    }
    window.addEventListener('DOMContentLoaded', toggleRoundtripRequirements);
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="search"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A2</span> Concourse A &middot; Departures hall</div>
      <h1>Where are we <em>flying</em> today?</h1>
      <p class="lede">Pick an origin and a destination, or leave them open to browse every departure on the board.</p>
    </div>
  </header>

<% if (loadFailed) { %>
  <div class="announce is-amber"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Ground delay</strong><p>We couldn't load airports right now. Please refresh in a moment.</p></div></div>
<% } %>

  <form class="search-pass reveal reveal-2" action="flightResults.jsp" method="get">
    <div class="sp-top">
      <div class="segmented" role="radiogroup" aria-label="Trip type">
        <input type="radio" name="trip" id="tripOne" value="oneway" checked onchange="toggleRoundtripRequirements()" />
        <label for="tripOne"><svg class="ico"><use href="#i-arrow"/></svg>One-way</label>
        <input type="radio" name="trip" id="tripRound" value="roundtrip" onchange="toggleRoundtripRequirements()" />
        <label for="tripRound"><svg class="ico"><use href="#i-swap"/></svg>Round-trip</label>
      </div>
      <label class="check" for="flexible"><input type="checkbox" name="flexible" id="flexible" value="yes" /> Flexible &plusmn;3 days</label>
    </div>

    <div class="od">
      <div class="od-end">
        <label class="label" for="dep">From</label>
        <div class="od-code is-empty">???</div>
        <div class="od-city">Any origin</div>
        <select name="dep" id="dep" data-od data-empty="Any origin">
          <option value="">Any departure airport</option>
<% for (String[] a : airports) { %>
          <option value="<%= esc(a[0]) %>" data-city="<%= esc(a[1]) %>"><%= esc(a[0]) %> &middot; <%= esc(a[1]) %></option>
<% } %>
        </select>
      </div>
      <div class="od-swap">
        <button type="button" data-swap aria-label="Swap origin and destination"><svg class="ico"><use href="#i-swap"/></svg></button>
      </div>
      <div class="od-end is-arr">
        <label class="label" for="arr">To</label>
        <div class="od-code is-empty">???</div>
        <div class="od-city">Anywhere</div>
        <select name="arr" id="arr" data-od data-empty="Anywhere">
          <option value="">Any arrival airport</option>
<% for (String[] a : airports) { %>
          <option value="<%= esc(a[0]) %>" data-city="<%= esc(a[1]) %>"><%= esc(a[0]) %> &middot; <%= esc(a[1]) %></option>
<% } %>
        </select>
      </div>
    </div>

    <div class="sp-row">
      <div class="field">
        <label for="date1">Depart</label>
        <input type="date" name="date1" id="date1" />
      </div>
      <div class="field" id="returnRow">
        <label for="date2">Return</label>
        <input type="date" name="date2" id="date2" />
      </div>
      <div class="field">
        <label for="airline">Airline</label>
        <select name="airline" id="airline">
          <option value="">All airlines</option>
<% for (String[] a : airlines) { %>
          <option value="<%= esc(a[0]) %>"><%= esc(a[1]) %> (<%= esc(a[0]) %>)</option>
<% } %>
        </select>
      </div>
      <div class="field">
        <label for="sort">Sort by</label>
        <select name="sort" id="sort">
          <option value="">Board order</option>
          <option value="depAsc">Earliest departure</option>
          <option value="depDesc">Latest departure</option>
          <option value="arrAsc">Earliest arrival</option>
          <option value="arrDesc">Latest arrival</option>
          <option value="durAsc">Shortest flight</option>
          <option value="durDesc">Longest flight</option>
        </select>
      </div>
    </div>

    <details class="prefs">
      <summary><svg class="ico" style="color:var(--sky-500)"><use href="#i-clock"/></svg> Timing preferences <span class="caps" style="margin-left:6px">Optional</span><svg class="ico chev"><use href="#i-chev"/></svg></summary>
      <div class="prefs-body">
        <div class="field">
          <span class="label">Take-off between</span>
          <div class="time-range"><input type="time" name="depStart" aria-label="Take-off from" /><span>to</span><input type="time" name="depEnd" aria-label="Take-off until" /></div>
        </div>
        <div class="field">
          <span class="label">Landing between</span>
          <div class="time-range"><input type="time" name="arrStart" aria-label="Landing from" /><span>to</span><input type="time" name="arrEnd" aria-label="Landing until" /></div>
        </div>
      </div>
    </details>

    <div class="sp-foot">
      <span class="muted tiny">Leave fields blank to see every scheduled departure.</span>
      <button type="submit" class="btn btn-lg">Search flights <svg class="ico ico-go"><use href="#i-arrow"/></svg></button>
    </div>
  </form>

<% if (!popular.isEmpty()) { %>
  <section class="section reveal reveal-3">
    <div class="section-title">
      <h2>Boarding <em>soon</em></h2>
      <span class="caps">Next departures by route</span>
    </div>
    <div class="grid grid-2">
<% for (String[] p : popular) { %>
      <a class="gate-row" href="flightResults.jsp?trip=oneway&amp;dep=<%= esc(p[0]) %>&amp;arr=<%= esc(p[1]) %>&amp;sort=depAsc">
        <span class="gate-sign"><%= esc(p[1]) %></span>
        <span>
          <span class="gr-title"><%= esc(p[2]) %> <svg class="ico"><use href="#i-arrow"/></svg> <%= esc(p[3]) %></span>
          <span class="gr-sub">Next: <%= p[4] %> &middot; <%= p[5] %> <%= "1".equals(p[5]) ? "flight" : "flights" %> scheduled</span>
        </span>
        <span class="gr-status code-chip sand"><%= esc(p[0]) %>&ndash;<%= esc(p[1]) %></span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
<% } %>
    </div>
  </section>
<% } %>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
