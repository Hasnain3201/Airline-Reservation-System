<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%@ page import="javax.servlet.http.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  HttpSession s = request.getSession(false);
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String repEmail = (String) session.getAttribute("userEmail");
  String selectedCID = request.getParameter("cid");
  String selectedFlight = request.getParameter("flightID");
  boolean hasCustomer = selectedCID != null && !selectedCID.isEmpty();
  boolean hasFlight = hasCustomer && selectedFlight != null && !selectedFlight.isEmpty();
  ApplicationDB db = new ApplicationDB();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Make reservation"/></jsp:include>
  <script>
    function autoSubmit() {
      document.getElementById("reservationForm").submit();
    }
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="make"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B2</span> Concourse B &middot; Ticketing counter</div>
      <h1>Book on <em>behalf</em> of a passenger.</h1>
      <p class="lede">Choose the customer, pick their flight, then seat one of their saved passengers.</p>
    </div>
  </header>

  <div class="grid grid-aside">
    <div class="grid" style="gap:22px">
      <form id="reservationForm" method="get" action="makeReservation.jsp" class="card reveal reveal-2">
        <div class="card-head"><h3><span class="gate-sign" style="height:26px;min-width:30px;font-size:.75rem">1</span> Customer &amp; flight</h3></div>
        <div class="fields fields-2">
          <div class="field">
            <label for="cid">Customer</label>
            <select name="cid" id="cid" onchange="autoSubmit()">
              <option value="">Select a customer&hellip;</option>
<%
  try (Connection conn = db.getConnection();
       Statement stmt = conn.createStatement();
       ResultSet rs = stmt.executeQuery("SELECT cid, fname, lname FROM CUSTOMER")) {
    while (rs.next()) {
      String cid = rs.getString("cid");
%>
              <option value="<%= cid %>" <%= cid.equals(selectedCID) ? "selected" : "" %>><%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></option>
<%
    }
  }
%>
            </select>
          </div>
          <div class="field">
            <label for="flightID">Flight</label>
<% if (hasCustomer) { %>
            <select name="flightID" id="flightID" onchange="autoSubmit()">
              <option value="">Select a flight&hellip;</option>
<%
  try (Connection conn = db.getConnection();
       Statement stmt = conn.createStatement();
       ResultSet rs = stmt.executeQuery(
         "SELECT flightID, flightNum, airlineID, DepartureAirportID AS dep, ArrivalAirportID AS arr, departureTime FROM FLIGHT ORDER BY departureTime")) {
    while (rs.next()) {
      String fid = rs.getString("flightID");
%>
              <option value="<%= fid %>" <%= fid.equals(selectedFlight) ? "selected" : "" %>><%= esc(rs.getString("airlineID")) %> <%= rs.getString("flightNum") %> &middot; <%= esc(rs.getString("dep")) %>&ndash;<%= esc(rs.getString("arr")) %> &middot; <%= fmtDate(rs.getTimestamp("departureTime")) %></option>
<%
    }
  }
%>
            </select>
<% } else { %>
            <select disabled><option>Choose a customer first</option></select>
<% } %>
          </div>
        </div>
      </form>

<%
  int maxSeats = 100;
  Set<String> takenSeats = new HashSet<>();
  List<Map<String, String>> passengers = new ArrayList<>();
  String seatModel = null;
  String[] fl = null;
  Timestamp flDep = null, flArr = null;

  if (hasFlight) {
    try (Connection conn = db.getConnection()) {
      PreparedStatement ps = conn.prepareStatement(
        "SELECT f.flightNum, f.airlineID, al.name AS airline, ap1.airportID AS fromCode, ap1.city AS fromCity, " +
        "ap2.airportID AS toCode, ap2.city AS toCity, f.departureTime, f.arrivalTime, ac.seatCapacity, ac.model " +
        "FROM FLIGHT f JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
        "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
        "JOIN AIRLINE al ON f.airlineID = al.airlineID " +
        "JOIN AIRCRAFT ac ON f.aircraftID = ac.aircraftID " +
        "WHERE f.flightID = ?");
      ps.setInt(1, Integer.parseInt(selectedFlight));
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        maxSeats = rs.getInt("seatCapacity");
        seatModel = rs.getString("model");
        fl = new String[] { rs.getString("airlineID"), rs.getString("airline"), rs.getString("flightNum"),
                            rs.getString("fromCode"), rs.getString("fromCity"), rs.getString("toCode"), rs.getString("toCity") };
        flDep = rs.getTimestamp("departureTime");
        flArr = rs.getTimestamp("arrivalTime");
      }

      PreparedStatement psT = conn.prepareStatement("SELECT seatNumber FROM TICKET WHERE flightID = ?");
      psT.setInt(1, Integer.parseInt(selectedFlight));
      ResultSet rsT = psT.executeQuery();
      while (rsT.next()) takenSeats.add(rsT.getString("seatNumber"));

      PreparedStatement psPass = conn.prepareStatement(
        "SELECT passengerID, fname, lname FROM PASSENGER WHERE createdByCID = ?");
      psPass.setInt(1, Integer.parseInt(selectedCID));
      ResultSet rsP = psPass.executeQuery();
      while (rsP.next()) {
        Map<String, String> p = new HashMap<>();
        p.put("passengerID", rsP.getString("passengerID"));
        p.put("name", rsP.getString("fname") + " " + rsP.getString("lname"));
        passengers.add(p);
      }
    }
  }

  if (hasFlight) {
%>
      <form id="bookingForm" method="post" action="confirmBookingRep.jsp" class="grid" style="gap:22px">
        <input type="hidden" name="cid" value="<%= esc(selectedCID) %>"/>
        <input type="hidden" name="flightID" value="<%= esc(selectedFlight) %>"/>

<% if (fl != null) { %>
        <article class="ticket reveal reveal-3" style="--stub:170px">
          <div class="ticket-main">
            <div class="ticket-top">
              <%= carrierHtml(fl[0], fl[1], "Flight " + esc(fl[0]) + " " + esc(fl[2])) %>
              <span class="pill"><%= maxSeats - takenSeats.size() %> of <%= maxSeats %> open</span>
            </div>
            <%= routeHtml(fl[3], fl[4], flDep, fl[5], fl[6], flArr) %>
          </div>
          <div class="ticket-stub">
            <div><span class="label">Seat</span><div style="margin-top:6px"><span class="flap flap-light flap-lg" data-seat-out data-flap>--</span></div></div>
          </div>
        </article>
<% } %>

        <section class="card reveal reveal-4">
          <div class="card-head"><h3><span class="gate-sign" style="height:26px;min-width:30px;font-size:.75rem">2</span> Passenger &amp; cabin</h3></div>
          <div class="field" style="margin-bottom:18px">
            <label for="passengerID">Passenger</label>
            <select name="passengerID" id="passengerID" required>
              <option value="" disabled selected><%= passengers.isEmpty() ? "This customer has no saved passengers" : "Select a passenger&hellip;" %></option>
<% for (Map<String, String> p : passengers) { %>
              <option value="<%= esc(p.get("passengerID")) %>"><%= esc(p.get("name")) %></option>
<% } %>
            </select>
          </div>
          <div class="class-picker">
            <input type="radio" name="ticketClass" id="clsEco" value="Economy" checked>
            <label for="clsEco"><b>Economy</b><span>$110 &middot; Final</span></label>
            <input type="radio" name="ticketClass" id="clsBiz" value="Business">
            <label for="clsBiz"><b>Business</b><span>$410 &middot; Cancellable</span></label>
            <input type="radio" name="ticketClass" id="clsFirst" value="First">
            <label for="clsFirst"><b>First</b><span>$710 &middot; Cancellable</span></label>
          </div>
          <div class="btn-row" style="margin-top:22px; justify-content:space-between">
            <span class="muted tiny">Fares include the $10 booking fee.</span>
            <button type="submit" class="btn btn-lg">Confirm reservation <svg class="ico ico-go"><use href="#i-arrow"/></svg></button>
          </div>
        </section>
      </form>
<% } else { %>
      <div class="empty reveal reveal-3">
        <svg class="art" viewBox="0 0 160 90" aria-hidden="true">
          <path d="M10 78 H150" stroke="#D8C4A2" stroke-width="2" stroke-dasharray="10 8"/>
          <g transform="translate(58 26)" fill="#A7C8E3"><use href="#i-seat" width="44" height="44"/></g>
        </svg>
        <h3>Awaiting a manifest</h3>
        <p><%= hasCustomer ? "Now pick the flight they'd like to take." : "Start by choosing which customer you're booking for." %></p>
      </div>
<% } %>
    </div>

    <aside class="reveal reveal-3" style="position:sticky; top:100px">
<% if (hasFlight) {
     String seatFormId = "bookingForm"; %>
<%@ include file="/WEB-INF/jspf/seatmap.jspf" %>
<% } %>
<% if (!hasFlight) { %>
      <div class="card card-sky">
        <div class="card-head"><h3><svg class="ico"><use href="#i-seat"/></svg> Cabin map</h3></div>
        <p class="muted" style="margin:0">The seat map appears once a flight is selected.</p>
      </div>
<% } %>
    </aside>
  </div>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
