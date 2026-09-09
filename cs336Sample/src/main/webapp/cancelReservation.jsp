<%@ page session="true" import="java.sql.*" %>
<%@ page import="java.util.Set, java.util.HashSet" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
  String email = (String) session.getAttribute("userEmail");
  if (email == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String ticketID = request.getParameter("ticketID");
  if (ticketID == null) {
    response.sendRedirect("viewReservations.jsp");
    return;
  }

  boolean deleted = false;
  boolean valid = false;

  ApplicationDB db = new ApplicationDB();

  try (Connection conn = db.getConnection()) {
    conn.setAutoCommit(false);

    // 1. Get CID from session email
    int cid = -1;
    try (PreparedStatement getCid = conn.prepareStatement(
         "SELECT cid FROM CUSTOMER WHERE email = ?")) {
      getCid.setString(1, email);
      ResultSet rs = getCid.executeQuery();
      if (rs.next()) {
        cid = rs.getInt("cid");
      } else {
        out.println("<p>Could not verify your customer ID.</p>");
        return;
      }
    }

    // 2. Check ownership and get flightID
    int flightID = -1;
    try (PreparedStatement verify = conn.prepareStatement(
         "SELECT flightID FROM TICKET WHERE ticketID = ? AND cid = ?")) {
      verify.setInt(1, Integer.parseInt(ticketID));
      verify.setInt(2, cid);
      ResultSet rs = verify.executeQuery();
      if (rs.next()) {
        flightID = rs.getInt("flightID");
        valid = true;
      }
    }

    // 3. Delete the ticket if valid
    if (valid) {
      try (PreparedStatement del = conn.prepareStatement(
           "DELETE FROM TICKET WHERE ticketID = ? AND cid = ?")) {
        del.setInt(1, Integer.parseInt(ticketID));
        del.setInt(2, cid);
        deleted = (del.executeUpdate() > 0);
      }
    }

    // 4. Notify waitlist in current sessions (via session attributes)
    if (deleted && flightID > 0) {
      try (PreparedStatement getWL = conn.prepareStatement(
           "SELECT cid FROM WAITLIST WHERE flightID = ?")) {
        getWL.setInt(1, flightID);
        ResultSet rs = getWL.executeQuery();
        while (rs.next()) {
          int wlCid = rs.getInt("cid");
          session.setAttribute("waitlistAlertFor_" + wlCid, true);
        }
      }
    }

    conn.commit();
  } catch (Exception err) {
    // Silent fail
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Cancel reservation"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="trips"/></jsp:include>

<main class="shell">
  <section class="result-hero">
<%
  if (!valid) {
%>
    <div class="stamp is-stamp is-round stamp-in">Void<small>Not found</small></div>
    <h1>We couldn't find that <em>ticket.</em></h1>
    <p class="lede">Reservation not found or not authorized for this account.</p>
<%
  } else if (deleted) {
%>
    <div class="stamp is-round stamp-in">Cancelled<small>Ticket #<%= ticketID.replaceAll("[^0-9]", "") %></small></div>
    <h1>Your reservation has been <em>cancelled.</em></h1>
    <p class="lede">The seat is back on the board. Waitlisted passengers in this session will be notified.</p>
<%
  } else {
%>
    <div class="stamp is-stamp is-round stamp-in">Hold<small>Try again</small></div>
    <h1>Could not cancel this <em>reservation.</em></h1>
    <p class="lede">Something went wrong at the gate. Please try again in a moment.</p>
<%
  }
%>
    <div class="btn-row">
      <a class="btn" href="viewReservations.jsp"><svg class="ico"><use href="#i-back"/></svg> Back to my trips</a>
      <a class="btn btn-ghost" href="searchFlights.jsp"><svg class="ico"><use href="#i-search"/></svg> Search flights</a>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
