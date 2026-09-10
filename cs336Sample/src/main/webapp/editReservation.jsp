<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>

<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String selectedCID = request.getParameter("cid");

  ApplicationDB db = new ApplicationDB();

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    String ticketID = request.getParameter("ticketID");
    try (Connection conn = db.getConnection()) {
      if ("update".equals(action)) {
        String newClass = request.getParameter("ticketClass");
        String newSeat = request.getParameter("seatNumber");

        int fare = "First".equals(newClass) ? 700 : "Business".equals(newClass) ? 400 : 100;

        PreparedStatement update = conn.prepareStatement(
          "UPDATE TICKET SET class = ?, seatNumber = ?, totalFare = ? WHERE ticketID = ?"
        );
        update.setString(1, newClass);
        update.setString(2, newSeat);
        update.setInt(3, fare);
        update.setInt(4, Integer.parseInt(ticketID));
        update.executeUpdate();
      } else if ("delete".equals(action)) {
        PreparedStatement del = conn.prepareStatement(
          "DELETE FROM TICKET WHERE ticketID = ?"
        );
        del.setInt(1, Integer.parseInt(ticketID));
        del.executeUpdate();

        response.sendRedirect("editReservation.jsp?cid=" + selectedCID);
        return;
      }
    }
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Amend reservations"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="edit"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B4</span> Concourse B &middot; Amendments</div>
      <h1>Amend a <em>reservation.</em></h1>
      <p class="lede">Pull up a customer's flight strips, then move them to a new seat, change cabin, or strike a ticket from the manifest.</p>
    </div>
  </header>

  <form method="get" class="card reveal reveal-2" style="margin-bottom:28px">
    <div class="fields" style="grid-template-columns: minmax(0, 420px) 1fr; align-items:end">
      <div class="field">
        <label for="cid">Customer</label>
        <select name="cid" id="cid" onchange="this.form.submit()">
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
      <span class="muted tiny">Fares are re-priced automatically: Economy $100, Business $400, First $700.</span>
    </div>
  </form>

<%
if (selectedCID != null && !selectedCID.isEmpty()) {
  try (Connection conn = db.getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT t.ticketID, t.flightID, t.class, t.seatNumber, f.flightNum, t.passengerID, " +
         "p.fname, p.lname, ap1.city AS depCity, ap2.city AS arrCity, f.departureTime, f.arrivalTime, a.seatCapacity, " +
         "ap1.airportID AS depCode, ap2.airportID AS arrCode, f.airlineID " +
         "FROM TICKET t " +
         "JOIN FLIGHT f ON t.flightID = f.flightID " +
         "JOIN AIRCRAFT a ON f.aircraftID = a.aircraftID " +
         "JOIN PASSENGER p ON t.passengerID = p.passengerID " +
         "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
         "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
         "WHERE t.cid = ? ORDER BY f.departureTime"
       )) {
    ps.setInt(1, Integer.parseInt(selectedCID));
    ResultSet rs = ps.executeQuery();
%>
  <div class="section-title reveal reveal-3">
    <h2>Flight <em>strips</em></h2>
    <span class="caps">Customer #<%= esc(selectedCID) %></span>
  </div>
  <div class="strips reveal reveal-3">
<%
    boolean any = false;
    while (rs.next()) {
      any = true;
      int ticketID = rs.getInt("ticketID");
      int flightID = rs.getInt("flightID");
      int seatCap = rs.getInt("seatCapacity");
      String cls = rs.getString("class");
      String currentSeat = rs.getString("seatNumber");

      Set<String> takenSeats = new HashSet<>();
      try (PreparedStatement ps2 = conn.prepareStatement("SELECT seatNumber FROM TICKET WHERE flightID = ?")) {
        ps2.setInt(1, flightID);
        ResultSet rs2 = ps2.executeQuery();
        while (rs2.next()) takenSeats.add(rs2.getString("seatNumber"));
      }
%>
    <form method="post" class="strip <%= "First".equals(cls) ? "is-ink" : "Business".equals(cls) ? "" : "is-sand" %>" style="--cols:5">
      <input type="hidden" name="cid" value="<%= esc(selectedCID) %>"/>
      <input type="hidden" name="ticketID" value="<%= ticketID %>"/>
      <div class="strip-tab">#<%= ticketID %></div>
      <div><span class="k"><%= esc(rs.getString("airlineID")) %> <%= esc(rs.getString("flightNum")) %></span><span class="v big"><%= esc(rs.getString("depCode")) %> &rarr; <%= esc(rs.getString("arrCode")) %></span></div>
      <div><span class="k">Passenger</span><span class="v"><%= esc(rs.getString("fname")) %> <%= esc(rs.getString("lname")) %></span></div>
      <div><span class="k">Departs</span><span class="v"><%= fmtDate(rs.getTimestamp("departureTime")) %> <%= fmtTime(rs.getTimestamp("departureTime")) %></span></div>
      <div>
        <span class="k">Class</span>
        <select name="ticketClass" aria-label="Class">
          <option<%= "Economy".equals(cls) ? " selected" : "" %>>Economy</option>
          <option<%= "Business".equals(cls) ? " selected" : "" %>>Business</option>
          <option<%= "First".equals(cls) ? " selected" : "" %>>First</option>
        </select>
      </div>
      <div>
        <span class="k">Seat</span>
        <select name="seatNumber" aria-label="Seat">
<%
      for (int i = 1; i <= seatCap; i++) {
        String sn = Integer.toString(i);
        boolean taken = takenSeats.contains(sn) && !sn.equals(currentSeat);
%>
          <option value="<%= sn %>" <%= sn.equals(currentSeat) ? "selected" : "" %> <%= taken ? "disabled" : "" %>><%= sn %><%= taken ? " (taken)" : "" %></option>
<%
      }
%>
        </select>
      </div>
      <div class="strip-act">
        <button type="submit" name="action" value="update" class="btn btn-sm"><svg class="ico"><use href="#i-check"/></svg> Update</button>
        <button type="submit" name="action" value="delete" class="btn btn-danger btn-sm" data-confirm="Delete ticket #<%= ticketID %>?" aria-label="Delete"><svg class="ico"><use href="#i-trash"/></svg></button>
      </div>
    </form>
<%
    }
    if (!any) {
%>
    <div class="empty">
      <h3>No strips on the board</h3>
      <p>This customer doesn't hold any tickets yet.</p>
      <a class="btn" href="makeReservation.jsp?cid=<%= esc(selectedCID) %>" style="margin-top:10px"><svg class="ico"><use href="#i-plus"/></svg> Make a reservation</a>
    </div>
<%
    }
%>
  </div>
<%
  }
} else {
%>
  <div class="empty reveal reveal-3">
    <h3>Select a customer</h3>
    <p>Their tickets will appear here as flight strips you can amend.</p>
  </div>
<%
}
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
