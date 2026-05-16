<%@ page import="java.sql.*,javax.servlet.http.*,com.cs336.pkg.ApplicationDB" contentType="text/html; charset=UTF-8" %>
<%
  HttpSession session = request.getSession(false);
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
        out.println("<h3>Your reservation has been cancelled.</h3>");
      } else {
        out.println("<h3>This reservation cannot be cancelled.</h3>");
      }
    }
    ps.close();
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<h3>Error cancelling reservation.</h3>");
  }
%>
<p><a href="viewReservations.jsp">← Back to Reservations</a></p>
