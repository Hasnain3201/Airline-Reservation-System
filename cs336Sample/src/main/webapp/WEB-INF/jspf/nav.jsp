<%@ page pageEncoding="UTF-8" %><%
  String navRole = request.getParameter("role");
  String navActive = request.getParameter("active");
  String navEmail = (String) session.getAttribute("userEmail");
  if (navRole == null) navRole = "customer";
  if (navActive == null) navActive = "";

  String homeHref;
  String roleLabel;
  String[][] items;
  if ("rep".equals(navRole)) {
    homeHref = "repHome.jsp";
    roleLabel = "Ops desk";
    items = new String[][] {
      {"home", "repHome.jsp", "i-home", "B1", "Desk"},
      {"make", "makeReservation.jsp", "i-plus", "B2", "Book"},
      {"edit", "editReservation.jsp", "i-edit", "B4", "Amend"},
      {"fleet", "viewFlights.jsp", "i-plane", "B5", "Fleet &amp; routes"},
      {"waitlist", "viewWaitingList.jsp", "i-hourglass", "B6", "Waitlist"},
      {"airport", "viewAirportFlights.jsp", "i-tower", "B7", "Airport board"},
      {"answer", "answerQuestions.jsp", "i-chat", "B8", "Inbox"}
    };
  } else if ("admin".equals(navRole)) {
    homeHref = "adminHome.jsp";
    roleLabel = "Control tower";
    items = new String[][] {
      {"home", "adminHome.jsp", "i-tower", "C1", "Tower"},
      {"users", "manageUsers.jsp", "i-group", "C2", "People"},
      {"sales", "salesReport.jsp", "i-chart", "C3", "Sales"},
      {"lookup", "reservationLookup.jsp", "i-search", "C4", "Lookup"},
      {"revenue", "revenueSummary.jsp", "i-receipt", "C5", "Revenue"},
      {"top", "topCustomer.jsp", "i-trophy", "C6", "Top flyer"},
      {"active", "activeFlights.jsp", "i-takeoff", "C7", "Busiest"}
    };
  } else {
    homeHref = "customerHome.jsp";
    roleLabel = "Passenger";
    items = new String[][] {
      {"home", "customerHome.jsp", "i-home", "A1", "Lounge"},
      {"search", "searchFlights.jsp", "i-takeoff", "A2", "Search"},
      {"trips", "viewReservations.jsp", "i-luggage", "A6", "My trips"},
      {"passengers", "managePassengers.jsp", "i-passport", "A8", "Passengers"},
      {"qna", "browseQnA.jsp", "i-info", "A9", "Info desk"}
    };
  }
%>
<jsp:include page="/WEB-INF/jspf/sprite.jsp"/>
<header class="topbar">
  <div class="shell">
    <a class="brand" href="<%= homeHref %>" aria-label="Contrail home">
      <svg class="brand-mark" viewBox="0 0 40 40" aria-hidden="true">
        <circle cx="20" cy="20" r="18" fill="#E1EDF7" stroke="#1C2E40" stroke-width="1.6"/>
        <circle cx="20" cy="20" r="13.5" fill="none" stroke="#A7C8E3" stroke-width="1" stroke-dasharray="2 3"/>
        <path d="M6 28c8-1 15-5.5 21-14" fill="none" stroke="#5B8DBB" stroke-width="2.2" stroke-linecap="round" stroke-dasharray="0.5 4"/>
        <g transform="translate(21.5 5.5) rotate(35) scale(.55)"><path fill="#1C2E40" d="M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/></g>
      </svg>
      <span class="brand-word">Contrail<small>Terminal&nbsp;1</small></span>
    </a>

    <nav class="wayfinder<%= items.length > 5 ? " is-dense" : "" %>" aria-label="Primary">
<% for (String[] it : items) { %>
      <a href="<%= it[1] %>" class="<%= it[0].equals(navActive) ? "is-active" : "" %>"<%= it[0].equals(navActive) ? " aria-current=\"page\"" : "" %>>
        <svg class="ico"><use href="#<%= it[2] %>"/></svg>
        <span><%= it[4] %></span>
        <span class="gate-no"><%= it[3] %></span>
      </a>
<% } %>
    </nav>

    <span class="luggage" title="<%= navEmail != null ? navEmail : "" %>">
      <span>
        <span class="role"><%= roleLabel %></span><br>
        <span class="who"><%= navEmail != null ? navEmail : "Guest" %></span>
      </span>
    </span>
    <a class="icon-btn" href="logout.jsp" title="Log out" aria-label="Log out"><svg class="ico"><use href="#i-logout"/></svg></a>
  </div>
</header>
