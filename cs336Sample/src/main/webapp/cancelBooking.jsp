<%@ page import="java.sql.*,javax.servlet.http.*,com.cs336.pkg.ApplicationDB" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  String userEmail = (String) session.getAttribute("userEmail");
  String ticketID  = request.getParameter("ticketID");
  if (ticketID == null) {
    response.sendRedirect("viewReservations.jsp");
    return;
  }

  String outcome;
  ApplicationDB db = new ApplicationDB();
  try (Connection conn = db.getConnection()) {
    // verify ticket belongs to user and is cancellable
    PreparedStatement ps = conn.prepareStatement(
      "SELECT t.cancellable " +
      "  FROM TICKET t " +
      "  JOIN CUSTOMER c ON t.cid = c.cid " +
      " WHERE t.ticketID = ? AND c.email = ?"
    );
    ps.setInt(1, Integer.parseInt(ticketID));
    ps.setString(2, userEmail);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next() && rs.getBoolean("cancellable")) {
        PreparedStatement del = conn.prepareStatement(
          "DELETE FROM TICKET WHERE ticketID = ?"
        );
        del.setInt(1, Integer.parseInt(ticketID));
        del.executeUpdate();
        del.close();
        outcome = "cancelled";
      } else {
        outcome = "locked";
      }
    }
    ps.close();
  } catch (Exception e) {
    e.printStackTrace();
    outcome = "error";
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
<% if ("cancelled".equals(outcome)) { %>
    <div class="stamp is-round stamp-in">Cancelled<small>Refund issued</small></div>
    <h1>Your reservation has been <em>cancelled.</em></h1>
<% } else if ("locked".equals(outcome)) { %>
    <div class="stamp is-stamp is-round stamp-in">Locked<small>Non-refundable</small></div>
    <h1>This reservation cannot be <em>cancelled.</em></h1>
<% } else { %>
    <div class="stamp is-stamp is-round stamp-in">Error<small>Try again</small></div>
    <h1>Error cancelling <em>reservation.</em></h1>
<% } %>
    <div class="btn-row">
      <a class="btn" href="viewReservations.jsp"><svg class="ico"><use href="#i-back"/></svg> Back to my trips</a>
    </div>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
