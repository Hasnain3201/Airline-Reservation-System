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
  Integer repID = null;
  String repName = null;
  int openQuestions = 0, waitlisted = 0, upcomingFlights = 0, ticketsSold = 0;
  List<String[]> board = new ArrayList<>();

  try (Connection conn = new ApplicationDB().getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT repID, fname FROM CUSTOMERREP WHERE email = ?")) {
    ps.setString(1, email);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      repID = rs.getInt("repID");
      repName = rs.getString("fname");
      s.setAttribute("repID", repID); // Stored as Integer
    }
    try (Statement st = conn.createStatement()) {
      ResultSet r = st.executeQuery("SELECT COUNT(*) FROM QUESTION WHERE atext IS NULL");
      if (r.next()) openQuestions = r.getInt(1);
      r = st.executeQuery("SELECT COUNT(*) FROM WAITLIST");
      if (r.next()) waitlisted = r.getInt(1);
      r = st.executeQuery("SELECT COUNT(*) FROM FLIGHT WHERE departureTime >= NOW()");
      if (r.next()) upcomingFlights = r.getInt(1);
      r = st.executeQuery("SELECT COUNT(*) FROM TICKET");
      if (r.next()) ticketsSold = r.getInt(1);
      r = st.executeQuery(
        "SELECT f.flightID, f.airlineID, f.flightNum, f.departureTime, f.DepartureAirportID AS dep, f.ArrivalAirportID AS arr, " +
        "ac.seatCapacity, (SELECT COUNT(*) FROM TICKET t WHERE t.flightID = f.flightID) AS sold " +
        "FROM FLIGHT f JOIN AIRCRAFT ac ON f.aircraftID = ac.aircraftID " +
        "WHERE f.departureTime >= NOW() ORDER BY f.departureTime LIMIT 6");
      while (r.next()) {
        int left = r.getInt("seatCapacity") - r.getInt("sold");
        board.add(new String[] {
          r.getString("flightID"), r.getString("airlineID") + r.getInt("flightNum"),
          r.getString("dep"), r.getString("arr"), fmtTime(r.getTimestamp("departureTime")),
          left <= 0 ? "FULL" : String.format("%02d", left)
        });
      }
    }
  } catch (Exception err) {
    // fail silently
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Ops desk"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="home"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B1</span> Concourse B &middot; Operations desk<% if (repID != null) { %> &middot; Agent #<%= repID %><% } %></div>
      <h1><span data-greeting>Hello</span>, <em><%= esc(repName != null ? repName : email) %>.</em></h1>
      <p class="lede">What would you like to do today? Here's how the terminal is looking right now.</p>
    </div>
    <div class="head-actions">
      <span class="caps" style="align-self:center">Local time</span>
      <span class="flap flap-light flap-lg" data-clock>00:00</span>
    </div>
  </header>

  <section class="stats reveal reveal-2">
    <div class="stat is-ink">
      <span class="label caps"><svg class="ico"><use href="#i-chat"/></svg> Open questions</span>
      <div class="value"><%= openQuestions %></div>
      <div class="foot">Passengers awaiting a reply</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-hourglass"/></svg> On waitlists</span>
      <div class="value"><%= waitlisted %></div>
      <div class="foot">Standby requests across flights</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-takeoff"/></svg> Upcoming flights</span>
      <div class="value"><%= upcomingFlights %></div>
      <div class="foot">Scheduled departures</div>
    </div>
    <div class="stat">
      <span class="label caps"><svg class="ico"><use href="#i-receipt"/></svg> Tickets issued</span>
      <div class="value"><%= ticketsSold %></div>
      <div class="foot">All time, all carriers</div>
    </div>
  </section>

  <section class="section grid grid-aside">
    <nav class="gates reveal reveal-3" aria-label="Desk tasks">
      <a class="gate-row" href="makeReservation.jsp">
        <span class="gate-sign">B2</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-plus"/></svg>Make a reservation</span><span class="gr-sub">Book a seat on behalf of a customer</span></span>
        <span class="gr-status pill pill-go">Open</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="editReservation.jsp">
        <span class="gate-sign">B4</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-edit"/></svg>Amend a reservation</span><span class="gr-sub">Change class, seat, or remove a ticket</span></span>
        <span class="gr-status pill pill-sand">Desk</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="viewFlights.jsp">
        <span class="gate-sign">B5</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-plane"/></svg>Fleet &amp; routes</span><span class="gr-sub">Airports, aircraft and the flight schedule</span></span>
        <span class="gr-status pill pill-sand">Manage</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="viewWaitingList.jsp">
        <span class="gate-sign">B6</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-hourglass"/></svg>Waiting lists</span><span class="gr-sub">Who's on standby for each flight</span></span>
        <span class="gr-status pill"><%= waitlisted %> waiting</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="viewAirportFlights.jsp">
        <span class="gate-sign">B7</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-tower"/></svg>Airport board</span><span class="gr-sub">Departures &amp; arrivals by airport</span></span>
        <span class="gr-status pill pill-sand">Live</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
      <a class="gate-row" href="answerQuestions.jsp">
        <span class="gate-sign">B8</span>
        <span><span class="gr-title"><svg class="ico"><use href="#i-chat"/></svg>Answer questions</span><span class="gr-sub">Reply to passengers at the info desk</span></span>
        <span class="gr-status pill <%= openQuestions > 0 ? "pill-stamp" : "pill-go" %>"><%= openQuestions %> open</span>
        <span class="gr-go"><svg class="ico"><use href="#i-arrow"/></svg></span>
      </a>
    </nav>

    <section class="board reveal reveal-4" aria-label="Next departures">
      <div class="board-head">
        <div class="board-title"><svg class="ico"><use href="#i-takeoff"/></svg> Next out</div>
        <span class="caps" style="color:rgba(200,221,238,.6)"><span class="blink">&#9679;</span> Live</span>
      </div>
      <div class="board-scroll">
      <table>
        <thead><tr><th>Flight</th><th>Route</th><th>Time</th><th>Open</th></tr></thead>
        <tbody>
<% if (board.isEmpty()) { %>
          <tr class="board-row"><td colspan="4"><span data-flap class="is-amber">NO DEPARTURES</span></td></tr>
<% } %>
<% for (String[] b : board) { %>
          <tr class="board-row" data-href="viewWaitingList.jsp?flightID=<%= b[0] %>">
            <td><span data-flap><%= b[1] %></span></td>
            <td><span data-flap class="is-sky"><%= b[2] %>-<%= b[3] %></span></td>
            <td><span data-flap><%= b[4] %></span></td>
            <td><span data-flap class="<%= "FULL".equals(b[5]) ? "is-stamp" : "is-go" %>"><%= String.format("%-4s", b[5]) %></span></td>
          </tr>
<% } %>
        </tbody>
      </table>
      </div>
      <div class="board-foot"><span>Tap a row for its waitlist</span><span>Concourse B</span></div>
    </section>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
