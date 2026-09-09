<%@ page import="java.sql.*, java.util.*, javax.servlet.http.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>
<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String flightID = request.getParameter("flightID");
  if (flightID == null) {
    response.sendRedirect("searchFlights.jsp");
    return;
  }

  ApplicationDB db = new ApplicationDB();

  String sql = "SELECT f.flightNum, f.airlineID, a.name AS airline, " +
               "ap1.airportID AS depCode, ap1.city AS depCity, f.departureTime, " +
               "ap2.airportID AS arrCode, ap2.city AS arrCity, f.arrivalTime, " +
               "f.aircraftID, ac.seatCapacity, ac.model " +
               "FROM FLIGHT f " +
               "JOIN AIRLINE a ON f.airlineID = a.airlineID " +
               "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
               "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
               "JOIN AIRCRAFT ac ON f.aircraftID = ac.aircraftID " +
               "WHERE f.flightID = ?";

  int maxSeats = 100;
  Set<String> takenSeats = new HashSet<>();
  List<Map<String, String>> passengers = new ArrayList<>();

  try (
    Connection conn = db.getConnection();
    PreparedStatement ps = conn.prepareStatement(sql)
  ) {
    ps.setInt(1, Integer.parseInt(flightID));
    ResultSet rs = ps.executeQuery();

    if (!rs.next()) {
      response.sendRedirect("searchFlights.jsp");
      return;
    }

    int flightNum = rs.getInt("flightNum");
    String airlineID = rs.getString("airlineID");
    String airline = rs.getString("airline");
    String depCode = rs.getString("depCode");
    String depCity = rs.getString("depCity");
    Timestamp departTime = rs.getTimestamp("departureTime");
    String arrCode = rs.getString("arrCode");
    String arrCity = rs.getString("arrCity");
    Timestamp arriveTime = rs.getTimestamp("arrivalTime");
    String model = rs.getString("model");
    maxSeats = rs.getInt("seatCapacity");

    rs.close();

    try (PreparedStatement psTaken = conn.prepareStatement(
         "SELECT seatNumber FROM TICKET WHERE flightID = ?")) {
      psTaken.setInt(1, Integer.parseInt(flightID));
      ResultSet taken = psTaken.executeQuery();
      while (taken.next()) {
        takenSeats.add(taken.getString("seatNumber"));
      }
    }

    try (PreparedStatement psPass = conn.prepareStatement(
         "SELECT idNumber, fname, lname, dob FROM PASSENGER WHERE createdByCID = (SELECT cid FROM CUSTOMER WHERE email = ?)")) {
      psPass.setString(1, email);
      ResultSet rsPass = psPass.executeQuery();
      while (rsPass.next()) {
        Map<String, String> p = new HashMap<>();
        p.put("id", rsPass.getString("idNumber"));
        p.put("fname", rsPass.getString("fname"));
        p.put("lname", rsPass.getString("lname"));
        p.put("dob", rsPass.getString("dob"));
        passengers.add(p);
      }
    }

    boolean seatsAvailable = takenSeats.size() < maxSeats;
    int perSide = maxSeats <= 16 ? 2 : 3;
    int perRow = perSide * 2;
    int openSeats = 0;
    for (int i = 1; i <= maxSeats; i++) if (!takenSeats.contains(Integer.toString(i))) openSeats++;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Choose your seat"/></jsp:include>
  <script>
    function fillPassenger(select) {
      const data = JSON.parse(select.value);
      document.getElementById("p_fname").value = data.fname;
      document.getElementById("p_lname").value = data.lname;
      document.getElementById("idNumber").value = data.id;
      document.getElementById("p_dob").value = data.dob;
    }
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="search"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A4</span> Concourse A &middot; Check-in counter</div>
      <h1><%= seatsAvailable ? "Choose your <em>seat.</em>" : "This one's <em>full.</em>" %></h1>
      <p class="lede"><%= esc(airline) %> flight <%= esc(airlineID) %> <%= flightNum %> &middot; <%= esc(model) %> &middot; <%= openSeats %> of <%= maxSeats %> seats open</p>
    </div>
    <div class="head-actions">
      <a class="btn btn-ghost" href="javascript:history.back()"><svg class="ico"><use href="#i-back"/></svg> Back to results</a>
    </div>
  </header>

  <form action="confirmBooking.jsp" method="post">
    <input type="hidden" name="flightID"  value="<%= esc(flightID) %>"/>
    <input type="hidden" name="legNumber" value="1"/>

    <div class="grid grid-aside">
      <div class="grid" style="gap:22px">
        <article class="ticket reveal reveal-2" style="--stub:200px">
          <div class="ticket-main">
            <div class="ticket-top">
              <%= carrierHtml(airlineID, airline, "Flight " + esc(airlineID) + " " + flightNum) %>
              <span class="pill"><%= esc(model) %></span>
            </div>
            <%= routeHtml(depCode, depCity, departTime, arrCode, arrCity, arriveTime) %>
          </div>
          <div class="ticket-stub">
            <div>
              <span class="label">Your seat</span>
              <div style="margin-top:6px"><span class="flap flap-light flap-lg" data-seat-out data-flap>--</span></div>
            </div>
            <div>
              <span class="label">Fare</span>
              <div class="price" style="font-size:1.6rem">$110</div>
            </div>
          </div>
        </article>

        <section class="card reveal reveal-3">
          <div class="card-head">
            <h3><svg class="ico"><use href="#i-passport"/></svg> Who's flying?</h3>
            <a class="caps" href="managePassengers.jsp">Manage passengers</a>
          </div>
<% if (!passengers.isEmpty()) { %>
          <div class="field" style="margin-bottom:18px">
            <label for="savedPassenger">Saved passenger</label>
            <select id="savedPassenger" onchange="fillPassenger(this)">
              <option disabled selected>Choose someone on file&hellip;</option>
<% for (Map<String,String> p : passengers) {
     String data = String.format("{\"id\":\"%s\",\"fname\":\"%s\",\"lname\":\"%s\",\"dob\":\"%s\"}",
                                 p.get("id"), p.get("fname"), p.get("lname"), p.get("dob")); %>
              <option value="<%= esc(data) %>"><%= esc(p.get("fname")) %> <%= esc(p.get("lname")) %> &middot; ID <%= esc(p.get("id")) %></option>
<% } %>
            </select>
          </div>
          <p class="caps" style="margin:0 0 14px">Or enter a new passenger</p>
<% } %>
          <div class="fields fields-2">
            <div class="field"><label for="p_fname">First name</label><input name="p_fname" id="p_fname" required/></div>
            <div class="field"><label for="p_lname">Last name</label><input name="p_lname" id="p_lname" required/></div>
            <div class="field"><label for="idNumber">ID / passport number</label><input name="idNumber" id="idNumber" required/></div>
            <div class="field"><label for="p_dob">Date of birth</label><input type="date" name="p_dob" id="p_dob" required/></div>
          </div>
        </section>

        <section class="card reveal reveal-4">
          <div class="card-head">
            <h3><svg class="ico"><use href="#i-seat"/></svg> Cabin</h3>
          </div>
          <div class="class-picker">
            <input type="radio" name="ticketClass" id="clsEco" value="Economy" checked>
            <label for="clsEco"><b>Economy</b><span>Non-refundable</span></label>
            <input type="radio" name="ticketClass" id="clsBiz" value="Business">
            <label for="clsBiz"><b>Business</b><span>Cancellable</span></label>
            <input type="radio" name="ticketClass" id="clsFirst" value="First">
            <label for="clsFirst"><b>First</b><span>Cancellable</span></label>
          </div>

<% if (seatsAvailable) { %>
          <div class="btn-row" style="margin-top:22px; justify-content:space-between">
            <span class="muted tiny">Pick a seat on the cabin map, then confirm.</span>
            <button type="submit" class="btn btn-lg">Confirm booking <svg class="ico ico-go"><use href="#i-arrow"/></svg></button>
          </div>
<% } else { %>
          <div class="announce is-amber" style="margin-top:22px">
            <svg class="ico"><use href="#i-hourglass"/></svg>
            <div><strong>No seats available</strong><p>Every seat on this flight is taken. Join the waitlist and we'll let you know if one opens up.</p></div>
          </div>
          <div class="btn-row" style="justify-content:space-between">
            <label class="check"><input type="radio" name="waitlist" value="yes" required /> Yes, add me to the waitlist</label>
            <button type="submit" class="btn btn-lg">Join waitlist <svg class="ico ico-go"><use href="#i-arrow"/></svg></button>
          </div>
<% } %>
        </section>
      </div>

      <aside class="reveal reveal-3" style="position:sticky; top:100px">
        <div class="fuselage">
          <div class="cabin-label"><span class="caps">Cabin map &middot; <%= esc(model) %></span></div>
<% if (seatsAvailable) { %>
          <div class="seat-grid" style="--l:<%= perSide %>; --r:<%= perSide %>">
<%   for (int start = 1, row = 1; start <= maxSeats; start += perRow, row++) { %>
            <div class="row">
<%     for (int k = 0; k < perRow; k++) {
         int n = start + k;
         if (k == perSide) { %>
              <span class="aisle-no"><%= row %></span>
<%       }
         if (n > maxSeats) { %>
              <span></span>
<%         continue;
         }
         String sn = Integer.toString(n);
         boolean taken = takenSeats.contains(sn); %>
              <span class="seat">
                <input type="radio" name="seatNumber" id="seat<%= sn %>" value="<%= sn %>" required <%= taken ? "disabled" : "" %>>
                <label for="seat<%= sn %>" title="Seat <%= sn %><%= taken ? " (taken)" : "" %>"><%= sn %></label>
              </span>
<%     } %>
            </div>
<%   } %>
          </div>
          <div class="seat-legend">
            <span><i></i>Open</span><span><i class="taken"></i>Taken</span><span><i class="mine"></i>Yours</span>
          </div>
<% } else { %>
          <div class="empty" style="border:0; background:transparent; padding:20px 0">
            <div class="stamp is-stamp is-round">Sold<small>out</small></div>
            <p style="margin-top:16px">All <%= maxSeats %> seats are booked.</p>
          </div>
<% } %>
        </div>
      </aside>
    </div>
  </form>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
<%
  } catch (Exception err) {
    out.println("<p><strong>Failed to load flight details.</strong></p>");
  }
%>
