<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();
  PreparedStatement ps;
  ResultSet rs;

  int cid = -1;
  try {
    ps = conn.prepareStatement("SELECT cid FROM CUSTOMER WHERE email = ?");
    ps.setString(1, email);
    rs = ps.executeQuery();
    if (rs.next()) cid = rs.getInt("cid");
    rs.close(); ps.close();
  } catch (Exception err) { out.println("<p>Error: " + err.getMessage() + "</p>"); }

  if (cid == -1) {
    out.println("<p>Could not retrieve customer ID.</p>");
    return;
  }

  String action = request.getParameter("action");
  String msg = null;

  if ("add".equals(action)) {
    String idNum = request.getParameter("idNumber");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String dob = request.getParameter("dob");

    if (idNum != null && fname != null && lname != null && dob != null) {
      try {
        ps = conn.prepareStatement(
          "INSERT INTO PASSENGER (idNumber, fname, lname, dob, createdByCID) VALUES (?, ?, ?, ?, ?)");
        ps.setString(1, idNum);
        ps.setString(2, fname);
        ps.setString(3, lname);
        ps.setDate(4, java.sql.Date.valueOf(dob));
        ps.setInt(5, cid);
        ps.executeUpdate();
        ps.close();
        msg = "Passenger added.";
      } catch (Exception e) {
        msg = "Failed to add: " + e.getMessage();
      }
    }
  }

  if ("delete".equals(action)) {
    String idNum = request.getParameter("idNumber");
    if (idNum != null) {
      try {
        ps = conn.prepareStatement("DELETE FROM PASSENGER WHERE idNumber = ? AND createdByCID = ?");
        ps.setString(1, idNum);
        ps.setInt(2, cid);
        ps.executeUpdate();
        ps.close();
        msg = "Passenger deleted.";
      } catch (Exception e) {
        msg = "Failed to delete: " + e.getMessage();
      }
    }
  }

  if ("update".equals(action)) {
    String idNum = request.getParameter("idNumber");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String dob = request.getParameter("dob");

    if (idNum != null && fname != null && lname != null && dob != null) {
      try {
        ps = conn.prepareStatement(
          "UPDATE PASSENGER SET fname = ?, lname = ?, dob = ? WHERE idNumber = ? AND createdByCID = ?");
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setDate(3, java.sql.Date.valueOf(dob));
        ps.setString(4, idNum);
        ps.setInt(5, cid);
        ps.executeUpdate();
        ps.close();
        msg = "Passenger updated.";
      } catch (Exception e) {
        msg = "Failed to update: " + e.getMessage();
      }
    }
  }

%>

<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Passengers"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="customer"/><jsp:param name="active" value="passengers"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">A8</span> Concourse A &middot; Passport control</div>
      <h1>Your travelling <em>companions.</em></h1>
      <p class="lede">Save the people you fly with and check-in becomes a single tap. Details can be amended any time before departure.</p>
    </div>
  </header>

<% if (msg != null) {
     boolean failed = msg.startsWith("Failed"); %>
  <div class="announce <%= failed ? "is-stamp" : "is-go" %> reveal">
    <svg class="ico"><use href="#<%= failed ? "i-megaphone" : "i-check" %>"/></svg>
    <div><strong><%= failed ? "Passport control" : "Stamped" %></strong><p><%= esc(msg) %></p></div>
  </div>
<% } %>

  <div class="passports reveal reveal-2">
<%
  ps = conn.prepareStatement("SELECT idNumber, fname, lname, dob FROM PASSENGER WHERE createdByCID = ?");
  ps.setInt(1, cid);
  rs = ps.executeQuery();
  int shown = 0;
  while (rs.next()) {
    shown++;
    String pf = rs.getString("fname"), pl = rs.getString("lname"), pid = rs.getString("idNumber");
%>
    <form method="post" class="passport">
      <div class="passport-head">
        <span class="caps">Passport &middot; Contrail</span>
        <span class="code-chip"><%= String.format("%02d", shown) %></span>
      </div>
      <div class="passport-body">
        <div class="passport-photo"><%= esc(initials(pf, pl)) %></div>
        <div class="fields">
          <div class="field"><label>Document no.</label><input type="text" name="idNumber" value="<%= esc(pid) %>" readonly /></div>
          <div class="fields fields-2">
            <div class="field"><label>Given name</label><input type="text" name="fname" value="<%= esc(pf) %>" /></div>
            <div class="field"><label>Surname</label><input type="text" name="lname" value="<%= esc(pl) %>" /></div>
          </div>
          <div class="field"><label>Date of birth</label><input type="date" name="dob" value="<%= rs.getDate("dob") %>" /></div>
        </div>
      </div>
      <div class="mrz" aria-hidden="true">P&lt;CTR<%= esc((pl == null ? "" : pl).toUpperCase()) %>&lt;&lt;<%= esc((pf == null ? "" : pf).toUpperCase()) %>&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;</div>
      <div class="btn-row" style="margin-top:14px; justify-content:flex-end">
        <button type="submit" name="action" value="delete" class="btn btn-danger btn-sm" data-confirm="Remove this passenger from your account?"><svg class="ico"><use href="#i-trash"/></svg> Remove</button>
        <button type="submit" name="action" value="update" class="btn btn-sm"><svg class="ico"><use href="#i-check"/></svg> Save</button>
      </div>
    </form>
<%
  }
  rs.close();
  ps.close();
  conn.close();
%>

    <form method="post" class="passport" style="border-style:dashed; background:var(--sand-50)">
      <div class="passport-head">
        <span class="caps">New passport</span>
        <span class="code-chip sand">+</span>
      </div>
      <div class="fields">
        <div class="field"><label for="newId">Document no.</label><input id="newId" name="idNumber" required placeholder="e.g. X1234567" /></div>
        <div class="fields fields-2">
          <div class="field"><label for="newF">Given name</label><input id="newF" name="fname" required /></div>
          <div class="field"><label for="newL">Surname</label><input id="newL" name="lname" required /></div>
        </div>
        <div class="field"><label for="newDob">Date of birth</label><input id="newDob" type="date" name="dob" required /></div>
      </div>
      <div class="btn-row" style="margin-top:18px; justify-content:flex-end">
        <button type="submit" name="action" value="add" class="btn btn-sky btn-sm"><svg class="ico"><use href="#i-plus"/></svg> Add passenger</button>
      </div>
    </form>
  </div>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
