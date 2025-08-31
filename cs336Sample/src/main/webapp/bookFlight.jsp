<%@ page import="java.sql.*, java.util.*, javax.servlet.http.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String flightID = request.getParameter("flightID");
  if (flightID == null) {
    out.println("<p><strong>No flight selected.</strong></p>");
    return;
  }

  ApplicationDB db = new ApplicationDB();

  String sql = "SELECT f.flightNum, a.name AS airline, " +
               "ap1.city AS depCity, f.departureTime, " +
               "ap2.city AS arrCity, f.arrivalTime, " +
               "f.aircraftID, ac.seatCapacity " +
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
      out.println("<p><strong>Flight not found.</strong></p>");
      return;
    }

    int flightNum = rs.getInt("flightNum");
    String airline = rs.getString("airline");
    String depCity = rs.getString("depCity");
    Timestamp departTime = rs.getTimestamp("departureTime");
    String arrCity = rs.getString("arrCity");
    Timestamp arriveTime = rs.getTimestamp("arrivalTime");
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

    // Load passenger list
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
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Book Flight</title>
  <script>
    function fillPassenger(select) {
      const data = JSON.parse(select.value);
      document.getElementById("p_fname").value = data.fname;
      document.getElementById("p_lname").value = data.lname;
      document.getElementById("idNumber").value = data.id;
      document.getElementById("p_dob").value = data.dob;
    }
  </script>
  <style>
    .note { color: red; font-weight: bold; margin-top: 1em; }
  </style>
</head>
<body>

<div style="text-align:right;">
  Logged in as <strong><%= email %></strong> |
  <a href="logout.jsp">Logout</a>
</div>

<p>
  <a href="javascript:history.back()">← Back to Results</a>
</p>

<h2>Book Flight</h2>
<p>
  <strong><%= airline %> #<%= flightNum %></strong><br/>
  Departs <%= depCity %> at <%= departTime %><br/>
  Arrives <%= arrCity %> at <%= arriveTime %>
</p>

<form action="confirmBooking.jsp" method="post">
  <input type="hidden" name="flightID"  value="<%= flightID %>"/>
  <input type="hidden" name="legNumber" value="1"/>

  <fieldset>
    <legend>Passenger</legend>

<% if (!passengers.isEmpty()) { %>
    <label>Choose a saved passenger:</label>
    <select onchange="fillPassenger(this)">
      <option disabled selected>-- Select --</option>
<% for (Map<String,String> p : passengers) {
     String data = String.format("{\"id\":\"%s\",\"fname\":\"%s\",\"lname\":\"%s\",\"dob\":\"%s\"}",
                                 p.get("id"), p.get("fname"), p.get("lname"), p.get("dob")); %>
      <option value='<%= data %>'><%= p.get("fname") %> <%= p.get("lname") %> (ID: <%= p.get("id") %>)</option>
<% } %>
    </select>
    <p>Or enter a new passenger manually:</p>
<% } %>

    First Name: <input name="p_fname" id="p_fname" required/><br/>
    Last Name:  <input name="p_lname" id="p_lname" required/><br/>
    ID Number:  <input name="idNumber" id="idNumber" required/><br/>
    DOB:        <input type="date" name="p_dob" id="p_dob" required/>
  </fieldset>

  <fieldset>
    <legend>Ticket Options</legend>
    Class:
    <select name="ticketClass">
      <option>Economy</option>
      <option>Business</option>
      <option>First</option>
    </select><br/>

<% if (seatsAvailable) { %>
    Seat:
    <select name="seatNumber" required>
      <% for (int i = 1; i <= maxSeats; i++) {
           String sn = Integer.toString(i);
           boolean taken = takenSeats.contains(sn);
      %>
        <option value="<%= sn %>" <%= taken ? "disabled" : "" %>>
          <%= sn %> <%= taken ? "(Taken)" : "" %>
        </option>
      <% } %>
    </select>
    <p><button type="submit">Confirm Booking</button></p>
<% } else { %>
    <div class="note">⚠️ No seats available on this flight.</div>
    <label><input type="radio" name="waitlist" value="yes" required /> Join Waitlist</label><br/>
    <p><button type="submit">Join Waitlist</button></p>
<% } %>
  </fieldset>
</form>

</body>
</html>

<%
  } catch (Exception err) {
    out.println("<p><strong>Failed to load flight details.</strong></p>");
  }
%>
