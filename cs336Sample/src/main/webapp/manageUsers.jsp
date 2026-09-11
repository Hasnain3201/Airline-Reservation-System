<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/util.jspf" %>

<%
  if (session == null || session.getAttribute("userEmail") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String email = (String) session.getAttribute("userEmail");
  String action = request.getParameter("action");
  String type = request.getParameter("type");

  ApplicationDB db = new ApplicationDB();
  Connection conn = db.getConnection();

  if ("delete".equals(action)) {
    String id = request.getParameter("id");
    String table = "customer".equals(type) ? "CUSTOMER" : "CUSTOMERREP";
    String idField = "customer".equals(type) ? "cid" : "repID";
    try (PreparedStatement ps = conn.prepareStatement("DELETE FROM " + table + " WHERE " + idField + " = ?")) {
      ps.setInt(1, Integer.parseInt(id));
      ps.executeUpdate();
    }
  }

  if ("add".equals(action)) {
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String emailNew = request.getParameter("email");
    String password = request.getParameter("password");

    if ("customer".equals(type)) {
      String address = request.getParameter("address");
      String dob = request.getParameter("dob");
      try (PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO CUSTOMER (fname, lname, email, password, address, dob) VALUES (?, ?, ?, ?, ?, ?)")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailNew);
        ps.setString(4, password);
        ps.setString(5, address);
        ps.setDate(6, java.sql.Date.valueOf(dob));
        ps.executeUpdate();
      }
    } else {
      try (PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO CUSTOMERREP (fname, lname, email, password) VALUES (?, ?, ?, ?)")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailNew);
        ps.setString(4, password);
        ps.executeUpdate();
      }
    }
  }

  if ("edit".equals(action)) {
    String id = request.getParameter("id");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String emailEdit = request.getParameter("email");

    if ("customer".equals(type)) {
      String address = request.getParameter("address");
      String dob = request.getParameter("dob");
      try (PreparedStatement ps = conn.prepareStatement(
          "UPDATE CUSTOMER SET fname = ?, lname = ?, email = ?, address = ?, dob = ? WHERE cid = ?")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailEdit);
        ps.setString(4, address);
        ps.setDate(5, java.sql.Date.valueOf(dob));
        ps.setInt(6, Integer.parseInt(id));
        ps.executeUpdate();
      }
    } else {
      try (PreparedStatement ps = conn.prepareStatement(
          "UPDATE CUSTOMERREP SET fname = ?, lname = ?, email = ? WHERE repID = ?")) {
        ps.setString(1, fname);
        ps.setString(2, lname);
        ps.setString(3, emailEdit);
        ps.setInt(4, Integer.parseInt(id));
        ps.executeUpdate();
      }
    }
  }

  Statement stmt = conn.createStatement();
  ResultSet customers = stmt.executeQuery("SELECT * FROM CUSTOMER");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="People"/></jsp:include>
</head>
<body>
<jsp:include page="/WEB-INF/jspf/nav.jsp"><jsp:param name="role" value="admin"/><jsp:param name="active" value="users"/></jsp:include>

<main class="shell">
  <header class="page-head reveal">
    <div>
      <div class="eyebrow"><span class="gate-sign">C2</span> Concourse C &middot; Crew &amp; passenger records</div>
      <h1>Manage <em>people.</em></h1>
      <p class="lede">Customers who fly with us and the representatives who look after them. Edit in place or add someone new.</p>
    </div>
    <div class="head-actions">
      <a class="btn btn-ghost btn-sm" href="#customers"><svg class="ico"><use href="#i-person"/></svg> Customers</a>
      <a class="btn btn-ghost btn-sm" href="#reps"><svg class="ico"><use href="#i-group"/></svg> Representatives</a>
    </div>
  </header>

  <section id="customers" class="reveal reveal-2">
    <div class="section-title"><h2>Customers</h2><span class="caps">Passenger accounts</span></div>
    <div class="table-wrap">
      <table class="manifest" style="min-width:1020px">
        <thead><tr><th style="width:70px">ID</th><th>Name</th><th>Email</th><th>Address</th><th style="width:170px">Date of birth</th><th class="right" style="width:190px">Actions</th></tr></thead>
        <tbody>
<%
  while (customers.next()) {
    String f = "cu" + customers.getInt("cid");
%>
          <tr>
            <td class="num">
              <form id="<%= f %>" method="post" action="manageUsers.jsp">
                <input type="hidden" name="action" value="edit"/>
                <input type="hidden" name="type" value="customer"/>
                <input type="hidden" name="id" value="<%= customers.getInt("cid") %>"/>
              </form>
              <span class="code-chip"><%= customers.getInt("cid") %></span>
            </td>
            <td><div style="display:flex; gap:6px">
              <input form="<%= f %>" name="fname" value="<%= esc(customers.getString("fname")) %>" aria-label="First name"/>
              <input form="<%= f %>" name="lname" value="<%= esc(customers.getString("lname")) %>" aria-label="Last name"/>
            </div></td>
            <td><input form="<%= f %>" name="email" value="<%= esc(customers.getString("email")) %>" aria-label="Email"/></td>
            <td><input form="<%= f %>" name="address" value="<%= esc(customers.getString("address")) %>" aria-label="Address"/></td>
            <td><input form="<%= f %>" name="dob" type="date" value="<%= customers.getDate("dob") %>" aria-label="Date of birth"/></td>
            <td class="right"><div class="btn-row" style="justify-content:flex-end">
              <button form="<%= f %>" type="submit" class="btn btn-sm">Update</button>
              <a class="btn btn-danger btn-sm" href="manageUsers.jsp?action=delete&amp;type=customer&amp;id=<%= customers.getInt("cid") %>" data-confirm="Delete this customer?" aria-label="Delete"><svg class="ico"><use href="#i-trash"/></svg></a>
            </div></td>
          </tr>
<%
  }
  customers.close();
%>
        </tbody>
      </table>
    </div>

    <form method="post" action="manageUsers.jsp" class="card card-sand" style="margin-top:18px">
      <input type="hidden" name="action" value="add"/>
      <input type="hidden" name="type" value="customer"/>
      <div class="card-head"><h3><svg class="ico"><use href="#i-plus"/></svg> Add a customer</h3></div>
      <div class="fields fields-3">
        <div class="field"><label for="cf">First name</label><input id="cf" name="fname" required/></div>
        <div class="field"><label for="cl">Last name</label><input id="cl" name="lname" required/></div>
        <div class="field"><label for="ce">Email</label><input id="ce" type="email" name="email" required/></div>
        <div class="field"><label for="cp">Password</label><input id="cp" type="password" name="password" required/></div>
        <div class="field"><label for="ca">Address</label><input id="ca" name="address" required/></div>
        <div class="field"><label for="cd">Date of birth</label><input id="cd" type="date" name="dob" required/></div>
      </div>
      <div class="btn-row" style="margin-top:18px; justify-content:flex-end">
        <button type="submit" class="btn btn-sky"><svg class="ico"><use href="#i-plus"/></svg> Add customer</button>
      </div>
    </form>
  </section>

<%
  ResultSet reps = stmt.executeQuery("SELECT * FROM CUSTOMERREP");
%>
  <section id="reps" class="section reveal reveal-3">
    <div class="section-title"><h2>Customer <em>representatives</em></h2><span class="caps">Ops desk crew</span></div>
    <div class="table-wrap">
      <table class="manifest" style="min-width:760px">
        <thead><tr><th style="width:70px">ID</th><th>Name</th><th>Email</th><th class="right" style="width:190px">Actions</th></tr></thead>
        <tbody>
<%
  while (reps.next()) {
    String f = "rp" + reps.getInt("repID");
%>
          <tr>
            <td class="num">
              <form id="<%= f %>" method="post" action="manageUsers.jsp">
                <input type="hidden" name="action" value="edit"/>
                <input type="hidden" name="type" value="rep"/>
                <input type="hidden" name="id" value="<%= reps.getInt("repID") %>"/>
              </form>
              <span class="code-chip sand"><%= reps.getInt("repID") %></span>
            </td>
            <td><div style="display:flex; gap:6px">
              <input form="<%= f %>" name="fname" value="<%= esc(reps.getString("fname")) %>" aria-label="First name"/>
              <input form="<%= f %>" name="lname" value="<%= esc(reps.getString("lname")) %>" aria-label="Last name"/>
            </div></td>
            <td><input form="<%= f %>" name="email" value="<%= esc(reps.getString("email")) %>" aria-label="Email"/></td>
            <td class="right"><div class="btn-row" style="justify-content:flex-end">
              <button form="<%= f %>" type="submit" class="btn btn-sm">Update</button>
              <a class="btn btn-danger btn-sm" href="manageUsers.jsp?action=delete&amp;type=rep&amp;id=<%= reps.getInt("repID") %>" data-confirm="Delete this representative?" aria-label="Delete"><svg class="ico"><use href="#i-trash"/></svg></a>
            </div></td>
          </tr>
<%
  }
  reps.close();
  conn.close();
%>
        </tbody>
      </table>
    </div>

    <form method="post" action="manageUsers.jsp" class="card card-sand" style="margin-top:18px">
      <input type="hidden" name="action" value="add"/>
      <input type="hidden" name="type" value="rep"/>
      <div class="card-head"><h3><svg class="ico"><use href="#i-plus"/></svg> Add a representative</h3></div>
      <div class="fields fields-4">
        <div class="field"><label for="rf">First name</label><input id="rf" name="fname" required/></div>
        <div class="field"><label for="rl">Last name</label><input id="rl" name="lname" required/></div>
        <div class="field"><label for="re">Email</label><input id="re" type="email" name="email" required/></div>
        <div class="field"><label for="rpw">Password</label><input id="rpw" type="password" name="password" required/></div>
      </div>
      <div class="btn-row" style="margin-top:18px; justify-content:flex-end">
        <button type="submit" class="btn btn-sky"><svg class="ico"><use href="#i-plus"/></svg> Add representative</button>
      </div>
    </form>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
