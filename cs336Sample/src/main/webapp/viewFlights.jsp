<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page import="java.time.*, java.time.format.DateTimeParseException" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

  String actionError = null;

  // ACTIONS FIRST
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
      if (request.getParameter("addAirport") != null) {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO AIRPORT VALUES (?, ?, ?, ?)");
        ps.setString(1, request.getParameter("airportID"));
        ps.setString(2, request.getParameter("name"));
        ps.setString(3, request.getParameter("city"));
        ps.setString(4, request.getParameter("country"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("editAirport") != null) {
        PreparedStatement ps = conn.prepareStatement("UPDATE AIRPORT SET name=?, city=?, country=? WHERE airportID=?");
        ps.setString(1, request.getParameter("name"));
        ps.setString(2, request.getParameter("city"));
        ps.setString(3, request.getParameter("country"));
        ps.setString(4, request.getParameter("airportID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("deleteAirport") != null) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM AIRPORT WHERE airportID=?");
        ps.setString(1, request.getParameter("airportID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("addAircraft") != null) {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO AIRCRAFT VALUES (?, ?, ?, ?)");
        ps.setInt(1, Integer.parseInt(request.getParameter("aircraftID")));
        ps.setString(2, request.getParameter("model"));
        ps.setInt(3, Integer.parseInt(request.getParameter("seatCapacity")));
        ps.setString(4, request.getParameter("airlineID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("editAircraft") != null) {
        PreparedStatement ps = conn.prepareStatement("UPDATE AIRCRAFT SET model=?, seatCapacity=?, airlineID=? WHERE aircraftID=?");
        ps.setString(1, request.getParameter("model"));
        ps.setInt(2, Integer.parseInt(request.getParameter("seatCapacity")));
        ps.setString(3, request.getParameter("airlineID"));
        ps.setInt(4, Integer.parseInt(request.getParameter("aircraftID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("deleteAircraft") != null) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM AIRCRAFT WHERE aircraftID=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("aircraftID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("addFlight") != null) {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO FLIGHT VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        ps.setInt(1, Integer.parseInt(request.getParameter("flightID")));
        ps.setInt(2, Integer.parseInt(request.getParameter("flightNum")));
        ps.setString(3, request.getParameter("departureTime").replace("T", " ") + ":00");
        ps.setString(4, request.getParameter("arrivalTime").replace("T", " ") + ":00");
        ps.setString(5, request.getParameter("daysOfWeek"));
        ps.setString(6, request.getParameter("flightType"));
        ps.setString(7, request.getParameter("airlineID"));
        ps.setInt(8, Integer.parseInt(request.getParameter("aircraftID")));
        ps.setString(9, request.getParameter("DepartureAirportID"));
        ps.setString(10, request.getParameter("ArrivalAirportID"));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("editFlight") != null) {
        PreparedStatement ps = conn.prepareStatement("UPDATE FLIGHT SET flightNum=?, departureTime=?, arrivalTime=?, daysOfWeek=?, flightType=?, airlineID=?, aircraftID=?, DepartureAirportID=?, ArrivalAirportID=? WHERE flightID=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("flightNum")));
        ps.setString(2, request.getParameter("departureTime").replace("T", " ") + ":00");
        ps.setString(3, request.getParameter("arrivalTime").replace("T", " ") + ":00");
        ps.setString(4, request.getParameter("daysOfWeek"));
        ps.setString(5, request.getParameter("flightType"));
        ps.setString(6, request.getParameter("airlineID"));
        ps.setInt(7, Integer.parseInt(request.getParameter("aircraftID")));
        ps.setString(8, request.getParameter("DepartureAirportID"));
        ps.setString(9, request.getParameter("ArrivalAirportID"));
        ps.setInt(10, Integer.parseInt(request.getParameter("flightID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      } else if (request.getParameter("deleteFlight") != null) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM FLIGHT WHERE flightID=?");
        ps.setInt(1, Integer.parseInt(request.getParameter("flightID")));
        ps.executeUpdate(); ps.close();
        conn.close(); response.sendRedirect("viewFlights.jsp"); return;
      }
    } catch (Exception e) {
      actionError = e.getMessage();
    }
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Fleet and routes"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="rep"/><jsp:param name="active" value="fleet"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">B5</span> Concourse B &middot; Hangar &amp; scheduling</div>
      <h1>Fleet <em>&amp;</em> routes.</h1>
      <p class="lede">The airports we serve, the aircraft in the hangar, and every scheduled flight. Edit a row in place and hit update.</p>
    </div>
    <div class="head-actions">
      <a class="btn btn-ghost btn-sm" href="#airports"><svg class="ico"><use href="#i-pin"/></svg> Airports</a>
      <a class="btn btn-ghost btn-sm" href="#aircraft"><svg class="ico"><use href="#i-plane"/></svg> Aircraft</a>
      <a class="btn btn-ghost btn-sm" href="#flights"><svg class="ico"><use href="#i-clock"/></svg> Schedule</a>
    </div>
  </header>

<% if (actionError != null) { %>
  <div class="announce is-stamp"><svg class="ico"><use href="#i-megaphone"/></svg><div><strong>Change not saved</strong><p><%= esc(actionError) %></p></div></div>
<% } %>

  <section id="airports" class="reveal reveal-2">
    <div class="section-title"><h2>Airports</h2><span class="caps">Where we land</span></div>
    <div class="table-wrap">
      <table class="manifest">
        <thead><tr><th style="width:110px">Code</th><th>Name</th><th>City</th><th>Country</th><th class="right" style="width:190px">Action</th></tr></thead>
        <tbody>
<%
  ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM AIRPORT");
  int rowNo = 0;
  while (rs.next()) {
    String f = "ap" + (rowNo++);
%>
          <tr>
            <td><form id="<%= f %>" method="post"></form><input form="<%= f %>" name="airportID" value="<%= esc(rs.getString("airportID")) %>" readonly></td>
            <td><input form="<%= f %>" name="name" value="<%= esc(rs.getString("name")) %>"></td>
            <td><input form="<%= f %>" name="city" value="<%= esc(rs.getString("city")) %>"></td>
            <td><input form="<%= f %>" name="country" value="<%= esc(rs.getString("country")) %>"></td>
            <td class="right"><div class="btn-row" style="justify-content:flex-end">
              <button form="<%= f %>" name="editAirport" class="btn btn-sm">Update</button>
              <button form="<%= f %>" name="deleteAirport" class="btn btn-danger btn-sm" data-confirm="Delete this airport?" aria-label="Delete"><svg class="ico"><use href="#i-trash"/></svg></button>
            </div></td>
          </tr>
<% } %>
          <tr class="add-row">
            <td><form id="apNew" method="post"></form><input form="apNew" name="airportID" required placeholder="JFK"></td>
            <td><input form="apNew" name="name" required placeholder="Airport name"></td>
            <td><input form="apNew" name="city" required placeholder="City"></td>
            <td><input form="apNew" name="country" required placeholder="Country"></td>
            <td class="right"><button form="apNew" name="addAirport" class="btn btn-sky btn-sm"><svg class="ico"><use href="#i-plus"/></svg> Add</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <section id="aircraft" class="section reveal reveal-3">
    <div class="section-title"><h2>Aircraft</h2><span class="caps">In the hangar</span></div>
    <div class="table-wrap">
      <table class="manifest">
        <thead><tr><th style="width:110px">ID</th><th>Model</th><th style="width:150px">Seats</th><th style="width:150px">Airline</th><th class="right" style="width:190px">Action</th></tr></thead>
        <tbody>
<%
  rs = conn.createStatement().executeQuery("SELECT * FROM AIRCRAFT");
  rowNo = 0;
  while (rs.next()) {
    String f = "ac" + (rowNo++);
%>
          <tr>
            <td><form id="<%= f %>" method="post"></form><input form="<%= f %>" name="aircraftID" value="<%= rs.getInt("aircraftID") %>" readonly></td>
            <td><input form="<%= f %>" name="model" value="<%= esc(rs.getString("model")) %>"></td>
            <td><input form="<%= f %>" name="seatCapacity" value="<%= rs.getInt("seatCapacity") %>"></td>
            <td><input form="<%= f %>" name="airlineID" value="<%= esc(rs.getString("airlineID")) %>"></td>
            <td class="right"><div class="btn-row" style="justify-content:flex-end">
              <button form="<%= f %>" name="editAircraft" class="btn btn-sm">Update</button>
              <button form="<%= f %>" name="deleteAircraft" class="btn btn-danger btn-sm" data-confirm="Delete this aircraft?" aria-label="Delete"><svg class="ico"><use href="#i-trash"/></svg></button>
            </div></td>
          </tr>
<% } %>
          <tr class="add-row">
            <td><form id="acNew" method="post"></form><input form="acNew" name="aircraftID" required placeholder="5001"></td>
            <td><input form="acNew" name="model" required placeholder="Model"></td>
            <td><input form="acNew" name="seatCapacity" required placeholder="Seats"></td>
            <td><input form="acNew" name="airlineID" required placeholder="Airline"></td>
            <td class="right"><button form="acNew" name="addAircraft" class="btn btn-sky btn-sm"><svg class="ico"><use href="#i-plus"/></svg> Add</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

<%
  ResultSet airlines = conn.createStatement().executeQuery("SELECT airlineID FROM AIRLINE");
  List<String> airlineList = new ArrayList<>();
  while (airlines.next()) airlineList.add(airlines.getString(1));
  airlines.close();

  ResultSet airports = conn.createStatement().executeQuery("SELECT airportID FROM AIRPORT");
  List<String> airportList = new ArrayList<>();
  while (airports.next()) airportList.add(airports.getString(1));
  airports.close();

  ResultSet aircrafts = conn.createStatement().executeQuery("SELECT aircraftID FROM AIRCRAFT");
  List<Integer> aircraftList = new ArrayList<>();
  while (aircrafts.next()) aircraftList.add(aircrafts.getInt(1));
  aircrafts.close();
%>
  <section id="flights" class="section reveal reveal-4">
    <div class="section-title"><h2>Flight <em>schedule</em></h2><span class="caps">Every departure</span></div>
    <div class="table-wrap">
      <table class="manifest" style="min-width:1560px">
        <thead><tr><th style="width:80px">ID</th><th style="width:90px">No.</th><th>Departs</th><th>Arrives</th><th>Days</th><th>Type</th><th>Airline</th><th>Aircraft</th><th>From</th><th>To</th><th class="right" style="width:170px">Action</th></tr></thead>
        <tbody>
<%
  rs = conn.createStatement().executeQuery("SELECT * FROM FLIGHT ORDER BY departureTime");
  rowNo = 0;
  while (rs.next()) {
    String f = "fl" + (rowNo++);
%>
          <tr>
            <td><form id="<%= f %>" method="post"></form><input form="<%= f %>" name="flightID" value="<%= rs.getInt("flightID") %>" readonly></td>
            <td><input form="<%= f %>" name="flightNum" value="<%= rs.getInt("flightNum") %>"></td>
            <td><input form="<%= f %>" type="datetime-local" name="departureTime" value="<%= rs.getTimestamp("departureTime").toLocalDateTime().toString().replace(" ", "T") %>"></td>
            <td><input form="<%= f %>" type="datetime-local" name="arrivalTime" value="<%= rs.getTimestamp("arrivalTime").toLocalDateTime().toString().replace(" ", "T") %>"></td>
            <td><input form="<%= f %>" name="daysOfWeek" value="<%= esc(rs.getString("daysOfWeek")) %>"></td>
            <td><input form="<%= f %>" name="flightType" value="<%= esc(rs.getString("flightType")) %>"></td>
            <td><select form="<%= f %>" name="airlineID"><% for (String a : airlineList) { %><option value="<%= a %>" <%= a.equals(rs.getString("airlineID")) ? "selected" : "" %>><%= a %></option><% } %></select></td>
            <td><select form="<%= f %>" name="aircraftID"><% for (int ac : aircraftList) { %><option value="<%= ac %>" <%= ac == rs.getInt("aircraftID") ? "selected" : "" %>><%= ac %></option><% } %></select></td>
            <td><select form="<%= f %>" name="DepartureAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>" <%= ap.equals(rs.getString("DepartureAirportID")) ? "selected" : "" %>><%= ap %></option><% } %></select></td>
            <td><select form="<%= f %>" name="ArrivalAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>" <%= ap.equals(rs.getString("ArrivalAirportID")) ? "selected" : "" %>><%= ap %></option><% } %></select></td>
            <td class="right"><div class="btn-row" style="justify-content:flex-end">
              <button form="<%= f %>" name="editFlight" class="btn btn-sm">Update</button>
              <button form="<%= f %>" name="deleteFlight" class="btn btn-danger btn-sm" data-confirm="Delete this flight?" aria-label="Delete"><svg class="ico"><use href="#i-trash"/></svg></button>
            </div></td>
          </tr>
<% } %>
          <tr class="add-row">
            <td><form id="flNew" method="post"></form><input form="flNew" name="flightID" required placeholder="700"></td>
            <td><input form="flNew" name="flightNum" required placeholder="1234"></td>
            <td><input form="flNew" type="datetime-local" name="departureTime" required></td>
            <td><input form="flNew" type="datetime-local" name="arrivalTime" required></td>
            <td><input form="flNew" name="daysOfWeek" required placeholder="Mon Wed"></td>
            <td><input form="flNew" name="flightType" required placeholder="Domestic"></td>
            <td><select form="flNew" name="airlineID"><% for (String a : airlineList) { %><option value="<%= a %>"><%= a %></option><% } %></select></td>
            <td><select form="flNew" name="aircraftID"><% for (int ac : aircraftList) { %><option value="<%= ac %>"><%= ac %></option><% } %></select></td>
            <td><select form="flNew" name="DepartureAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>"><%= ap %></option><% } %></select></td>
            <td><select form="flNew" name="ArrivalAirportID"><% for (String ap : airportList) { %><option value="<%= ap %>"><%= ap %></option><% } %></select></td>
            <td class="right"><button form="flNew" name="addFlight" class="btn btn-sky btn-sm"><svg class="ico"><use href="#i-plus"/></svg> Add</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
<%
  conn.close();
%>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
