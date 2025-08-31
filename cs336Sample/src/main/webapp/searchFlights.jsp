<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String email = (String) session.getAttribute("userEmail");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Search Flights</title>
  <style>
    body { font-family: sans-serif; margin:2em; }
    .topbar { text-align:right; margin-bottom:1em; }
    .topbar a { margin-left:1em; }
    table { border-spacing: 8px; }
    label { display:inline-block; width:140px; }
  </style>
  <script>
    function toggleRoundtripRequirements() {
      const isRoundtrip = document.getElementById('tripRound').checked;

      const dep = document.getElementById('dep');
      const arr = document.getElementById('arr');
      const date1 = document.getElementById('date1');
      const date2 = document.getElementById('date2');
      const returnRow = document.getElementById('returnRow');

      if (isRoundtrip) {
        dep.setAttribute('required', 'required');
        arr.setAttribute('required', 'required');
        date1.setAttribute('required', 'required');
        date2.setAttribute('required', 'required');
        returnRow.style.display = 'table-row';
      } else {
        dep.removeAttribute('required');
        arr.removeAttribute('required');
        date1.removeAttribute('required');
        date2.removeAttribute('required');
        returnRow.style.display = 'none';
      }
    }
    window.addEventListener('DOMContentLoaded', toggleRoundtripRequirements);
  </script>
</head>
<body>
  <div class="topbar">
    Logged in as <strong><%= email %></strong> |
    <a href="customerHome.jsp">🏠 HomePage</a> |
    <a href="viewReservations.jsp">My Reservations</a> |
    <a href="logout.jsp">Logout</a>
  </div>

  <h2>Search for Flights</h2>
  <form action="flightResults.jsp" method="get">
    <table>
      <tr>
        <td><label for="dep">Departure Airport:</label></td>
        <td>
          <select name="dep" id="dep">
            <option value="">--Select--</option>
            <%
              ApplicationDB db = new ApplicationDB();
              try (Connection c = db.getConnection();
                   Statement s = c.createStatement();
                   ResultSet r = s.executeQuery("SELECT airportID, city FROM AIRPORT")) {
                while (r.next()) {
            %>
              <option value="<%= r.getString("airportID") %>">
                <%= r.getString("airportID") %> (<%= r.getString("city") %>)
              </option>
            <%
                }
              } catch (Exception e) {
                out.println("<option disabled>Load failed</option>");
              }
            %>
          </select>
        </td>
      </tr>

      <tr>
        <td><label for="arr">Arrival Airport:</label></td>
        <td>
          <select name="arr" id="arr">
            <option value="">--Select--</option>
            <%
              try (Connection c = db.getConnection();
                   Statement s = c.createStatement();
                   ResultSet r = s.executeQuery("SELECT airportID, city FROM AIRPORT")) {
                while (r.next()) {
            %>
              <option value="<%= r.getString("airportID") %>">
                <%= r.getString("airportID") %> (<%= r.getString("city") %>)
              </option>
            <%
                }
              } catch (Exception e) {
                out.println("<option disabled>Load failed</option>");
              }
            %>
          </select>
        </td>
      </tr>

      <tr>
        <td><label>Trip Type:</label></td>
        <td>
          <input type="radio" name="trip" id="tripOne" value="oneway" checked onchange="toggleRoundtripRequirements()" />
          <label for="tripOne">One-Way</label>
          <input type="radio" name="trip" id="tripRound" value="roundtrip" onchange="toggleRoundtripRequirements()" />
          <label for="tripRound">Round-Trip</label>
        </td>
      </tr>

      <tr>
        <td><label for="date1">Depart Date:</label></td>
        <td><input type="date" name="date1" id="date1" /></td>
      </tr>

      <tr id="returnRow" style="display:none;">
        <td><label for="date2">Return Date:</label></td>
        <td><input type="date" name="date2" id="date2" /></td>
      </tr>

      <tr>
        <td><label for="flexible">Flexible ±3 days:</label></td>
        <td><input type="checkbox" name="flexible" id="flexible" value="yes" /></td>
      </tr>

      <tr>
        <td><label for="airline">Airline Filter:</label></td>
        <td>
          <select name="airline" id="airline">
            <option value="">--All--</option>
            <%
              try (Connection c = db.getConnection();
                   Statement s = c.createStatement();
                   ResultSet r = s.executeQuery("SELECT airlineID, name FROM AIRLINE")) {
                while (r.next()) {
            %>
              <option value="<%= r.getString("airlineID") %>">
                <%= r.getString("airlineID") %> – <%= r.getString("name") %>
              </option>
            <%
                }
              } catch (Exception e) {
                out.println("<option disabled>Load failed</option>");
              }
            %>
          </select>
        </td>
      </tr>

      <tr>
        <td><label>Take-off Between:</label></td>
        <td>
          <input type="time" name="depStart" /> to <input type="time" name="depEnd" />
        </td>
      </tr>

      <tr>
        <td><label>Landing Between:</label></td>
        <td>
          <input type="time" name="arrStart" /> to <input type="time" name="arrEnd" />
        </td>
      </tr>

      <tr>
        <td><label for="sort">Sort by:</label></td>
        <td>
          <select name="sort" id="sort">
            <option value="">None</option>
            <option value="depAsc">Depart ↑</option>
            <option value="depDesc">Depart ↓</option>
            <option value="arrAsc">Arrive ↑</option>
            <option value="arrDesc">Arrive ↓</option>
            <option value="durAsc">Duration ↑</option>
            <option value="durDesc">Duration ↓</option>
          </select>
        </td>
      </tr>
    </table>

    <p><button type="submit">Search Flights</button></p>
  </form>
</body>
</html>
