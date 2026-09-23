<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
  String error = request.getParameter("error");

  List<String[]> departures = new ArrayList<>();
  SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
  SimpleDateFormat dayFmt = new SimpleDateFormat("MMM dd", Locale.US);
  try (Connection c = new ApplicationDB().getConnection();
       PreparedStatement ps = c.prepareStatement(
         "SELECT f.airlineID, f.flightNum, f.departureTime, ap1.airportID AS depCode, ap2.city AS arrCity, " +
         "f.departureTime < NOW() AS gone, f.departureTime < NOW() + INTERVAL 14 DAY AS soon " +
         "FROM FLIGHT f " +
         "JOIN AIRPORT ap1 ON f.DepartureAirportID = ap1.airportID " +
         "JOIN AIRPORT ap2 ON f.ArrivalAirportID = ap2.airportID " +
         "ORDER BY (f.departureTime < NOW()), f.departureTime LIMIT 7");
       ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
      Timestamp t = rs.getTimestamp("departureTime");
      String status = rs.getBoolean("gone") ? "DEPARTED" : rs.getBoolean("soon") ? "BOARDING" : "ON TIME";
      departures.add(new String[] {
        rs.getString("airlineID") + rs.getInt("flightNum"),
        String.format("%-13.13s", rs.getString("arrCity")),
        rs.getString("depCode"),
        timeFmt.format(t),
        dayFmt.format(t),
        status
      });
    }
  } catch (Exception ignored) {
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="/WEB-INF/jspf/head.jsp"><jsp:param name="title" value="Check in"/></jsp:include>
</head>
<body class="is-login">
<jsp:include page="/WEB-INF/jspf/sprite.jsp"/>

<div class="sky-scene" aria-hidden="true">
  <div class="sky-cloud" style="top:9%;  width:220px; animation-duration:95s;  animation-delay:-20s;"><svg viewBox="0 0 64 40"><use href="#i-cloud"/></svg></div>
  <div class="sky-cloud" style="top:26%; width:130px; animation-duration:70s;  animation-delay:-52s; opacity:.75"><svg viewBox="0 0 64 40"><use href="#i-cloud"/></svg></div>
  <div class="sky-cloud" style="top:4%;  width:90px;  animation-duration:60s;  animation-delay:-8s;  opacity:.6"><svg viewBox="0 0 64 40"><use href="#i-cloud"/></svg></div>
  <div class="sky-cloud" style="top:44%; width:300px; animation-duration:140s; animation-delay:-90s; opacity:.55"><svg viewBox="0 0 64 40"><use href="#i-cloud"/></svg></div>
  <div class="sky-cloud" style="top:16%; width:170px; animation-duration:110s; animation-delay:-75s;"><svg viewBox="0 0 64 40"><use href="#i-cloud"/></svg></div>
</div>

<header class="login-top">
  <div class="shell">
    <a class="brand" href="login.jsp" aria-label="Contrail">
      <svg class="brand-mark" viewBox="0 0 40 40" aria-hidden="true">
        <circle cx="20" cy="20" r="18" fill="#E1EDF7" stroke="#1C2E40" stroke-width="1.6"/>
        <circle cx="20" cy="20" r="13.5" fill="none" stroke="#A7C8E3" stroke-width="1" stroke-dasharray="2 3"/>
        <path d="M6 28c8-1 15-5.5 21-14" fill="none" stroke="#5B8DBB" stroke-width="2.2" stroke-linecap="round" stroke-dasharray="0.5 4"/>
        <g transform="translate(21.5 5.5) rotate(35) scale(.55)"><path fill="#1C2E40" d="M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/></g>
      </svg>
      <span class="brand-word">Contrail<small>Terminal&nbsp;1</small></span>
    </a>
    <div class="terminal">
      <span class="caps">Local time</span>
      <span class="flap flap-light" data-clock>00:00</span>
    </div>
  </div>
</header>

<main class="shell">
  <section class="login-hero">
    <div class="reveal">
      <div class="eyebrow"><span class="gate-sign">T1</span> Reservations desk &middot; Now boarding all rows</div>
      <h1>
        <span class="line">Every journey</span>
        <span class="line">begins <em>at the gate.</em></span>
      </h1>
      <p class="lede">Search routes, pick your window seat, and keep every boarding pass in one quiet little terminal. Representatives and the control tower check in here too.</p>

      <figure class="routemap reveal reveal-3" aria-label="Illustrated route map">
        <svg viewBox="0 0 640 300" role="img">
          <defs>
            <pattern id="dots" width="16" height="16" patternUnits="userSpaceOnUse">
              <circle cx="2" cy="2" r="1" fill="#C8DDEE"/>
            </pattern>
            <symbol id="mapplane" viewBox="0 0 24 24"><path d="M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/></symbol>
          </defs>
          <rect width="640" height="300" fill="url(#dots)"/>
          <g fill="none" stroke="#C8DDEE" stroke-width="1">
            <path d="M0 70 Q320 40 640 70"/><path d="M0 140 Q320 110 640 140"/><path d="M0 210 Q320 180 640 210"/>
            <path d="M120 0 Q105 150 120 300"/><path d="M260 0 Q250 150 260 300"/><path d="M400 0 Q405 150 400 300"/><path d="M540 0 Q555 150 540 300"/>
          </g>

          <g fill="none" stroke-linecap="round">
            <path id="r1" d="M520 128 Q300 0 95 200" stroke="#7FAAD0" stroke-width="1.8" stroke-dasharray="2 7"/>
            <path id="r2" d="M95 200 Q230 70 380 110" stroke="#7FAAD0" stroke-width="1.8" stroke-dasharray="2 7"/>
            <path id="r3" d="M380 110 Q460 60 520 128" stroke="#7FAAD0" stroke-width="1.8" stroke-dasharray="2 7"/>
            <path id="r4" d="M80 66 Q280 140 500 262" stroke="#C2A67B" stroke-width="1.6" stroke-dasharray="2 7"/>
            <path id="r5" d="M565 78 Q400 10 232 142" stroke="#C2A67B" stroke-width="1.6" stroke-dasharray="2 7"/>
          </g>

          <g fill="#1C2E40">
            <g><use href="#mapplane" width="18" height="18" x="-9" y="-9" transform="rotate(90)"/><animateMotion dur="14s" repeatCount="indefinite" rotate="auto"><mpath href="#r1"/></animateMotion></g>
            <g><use href="#mapplane" width="15" height="15" x="-7.5" y="-7.5" transform="rotate(90)"/><animateMotion dur="10s" begin="-4s" repeatCount="indefinite" rotate="auto"><mpath href="#r2"/></animateMotion></g>
            <g><use href="#mapplane" width="14" height="14" x="-7" y="-7" transform="rotate(90)"/><animateMotion dur="7s" begin="-2s" repeatCount="indefinite" rotate="auto"><mpath href="#r3"/></animateMotion></g>
            <g fill="#8E744D"><use href="#mapplane" width="15" height="15" x="-7.5" y="-7.5" transform="rotate(90)"/><animateMotion dur="16s" begin="-9s" repeatCount="indefinite" rotate="auto"><mpath href="#r4"/></animateMotion></g>
            <g fill="#8E744D"><use href="#mapplane" width="14" height="14" x="-7" y="-7" transform="rotate(90)"/><animateMotion dur="12s" begin="-3s" repeatCount="indefinite" rotate="auto"><mpath href="#r5"/></animateMotion></g>
          </g>

          <g font-family="IBM Plex Mono, monospace" font-size="11" font-weight="600" fill="#1C2E40">
            <circle cx="520" cy="128" r="11" fill="none" stroke="#5B8DBB" stroke-width="1.2" opacity=".6">
              <animate attributeName="r" values="5;16;5" dur="3s" repeatCount="indefinite"/>
              <animate attributeName="opacity" values=".8;0;.8" dur="3s" repeatCount="indefinite"/>
            </circle>
            <g stroke="#FBF8F1" stroke-width="2.5">
              <circle cx="520" cy="128" r="5"/><circle cx="95" cy="200" r="5"/><circle cx="380" cy="110" r="5"/>
              <circle cx="80" cy="66" r="4"/><circle cx="500" cy="262" r="4"/><circle cx="565" cy="78" r="4"/><circle cx="232" cy="142" r="4"/>
            </g>
            <text x="532" y="140">EWR</text>
            <text x="64" y="222">LAX</text>
            <text x="366" y="98">ORD</text>
            <text x="92" y="60" fill="#5D7084">SEA</text>
            <text x="512" y="274" fill="#5D7084">MIA</text>
            <text x="575" y="74" fill="#5D7084">BOS</text>
            <text x="200" y="162" fill="#5D7084">DEN</text>
          </g>

          <g transform="translate(590 240)" fill="none" stroke="#A7C8E3">
            <circle r="26" stroke-dasharray="2 3"/>
            <circle r="17"/>
            <path d="M0 -30 L5 0 L0 30 L-5 0 Z" fill="#E1EDF7" stroke="#7FAAD0"/>
            <path d="M-30 0 L0 5 L30 0 L0 -5 Z" fill="#F2E9DA" stroke="#C2A67B"/>
            <text y="-34" text-anchor="middle" font-family="IBM Plex Mono, monospace" font-size="9" fill="#5D7084" stroke="none">N</text>
          </g>
        </svg>
        <figcaption class="legend"><span><i></i>Scheduled routes</span><span><i style="border-color:#C2A67B"></i>Seasonal</span></figcaption>
      </figure>
    </div>

    <div>
      <form class="pass-login" action="checkLogin.jsp" method="post" autocomplete="on">
        <div class="pass-band">
          <span><svg class="ico"><use href="#i-plane"/></svg>&nbsp; Boarding pass</span>
          <span>Contrail &middot; Seq 336</span>
        </div>
        <div class="pass-body">
          <div class="pass-route">
            <div>
              <div class="lbl">From</div>
              <div class="code">YOU</div>
            </div>
            <div class="mid" aria-hidden="true">
              <svg viewBox="0 0 100 30" preserveAspectRatio="none"><path d="M2 26 Q50 -6 98 26" fill="none" stroke="currentColor" stroke-width="1.4" stroke-dasharray="2 4" vector-effect="non-scaling-stroke"/></svg>
            </div>
            <div style="text-align:right">
              <div class="lbl">To</div>
              <div class="code" style="color:var(--sky-600)">ANY</div>
            </div>
          </div>

<% if ("1".equals(error)) { %>
          <div class="announce is-stamp">
            <svg class="ico"><use href="#i-megaphone"/></svg>
            <div><strong>Gate agent</strong><p>That email and password combination didn't match our manifest. Please try again.</p></div>
          </div>
<% } else if ("2".equals(error)) { %>
          <div class="announce is-amber">
            <svg class="ico"><use href="#i-megaphone"/></svg>
            <div><strong>Ground delay</strong><p>We couldn't reach the reservations system just now. Please try again shortly.</p></div>
          </div>
<% } %>

          <div class="fields">
            <div class="field">
              <label for="email">Passenger email</label>
              <input type="email" name="email" id="email" required placeholder="you@example.com" autocomplete="username" />
            </div>
            <div class="field">
              <label for="password">Boarding code</label>
              <input type="password" name="password" id="password" required placeholder="Your password" autocomplete="current-password" />
            </div>
          </div>

          <div class="pass-meta">
            <div class="meta-item"><span class="label">Gate</span><span class="val">T1&middot;04</span></div>
            <div class="meta-item"><span class="label">Seat</span><span class="val">Window</span></div>
            <div class="meta-item"><span class="label">Boards</span><span class="val flap-light" data-clock>--:--</span></div>
          </div>

          <button type="submit" class="btn btn-lg" style="width:100%">
            Board now <svg class="ico ico-go"><use href="#i-arrow"/></svg>
          </button>
        </div>
        <div class="pass-foot" aria-hidden="true">
          <span class="seq">CTRL 0336 A</span>
          <div class="barcode"></div>
        </div>
      </form>

      <div class="crew reveal reveal-4">
        <span class="caps">Demo crew &mdash; tap a tag to fill in</span>
        <div class="crew-tags">
          <button type="button" data-fill-email="customer@demo.com" data-fill-pass="customer123"><span>Passenger</span><b>Jordan</b></button>
          <button type="button" data-fill-email="rep@demo.com" data-fill-pass="rep123"><span>Ops desk</span><b>Alex</b></button>
          <button type="button" data-fill-email="admin@demo.com" data-fill-pass="admin123"><span>Control tower</span><b>Admin</b></button>
        </div>
      </div>
    </div>
  </section>

  <section class="board reveal reveal-5" aria-label="Departures">
    <div class="board-head">
      <div class="board-title"><svg class="ico"><use href="#i-takeoff"/></svg> Departures &middot; Abflug &middot; D&eacute;parts</div>
      <span class="caps" style="color:rgba(200,221,238,.6)">Updated <span class="blink">&#9679;</span> live</span>
    </div>
    <div class="board-scroll">
    <table>
      <thead>
        <tr><th>Flight</th><th>Destination</th><th class="hide-sm">From</th><th>Time</th><th class="hide-sm">Date</th><th>Remarks</th></tr>
      </thead>
      <tbody>
<% if (departures.isEmpty()) { %>
        <tr class="board-row"><td colspan="6"><span data-flap class="is-amber">BOARD TEMPORARILY UNAVAILABLE</span></td></tr>
<% } %>
<% for (String[] d : departures) {
     String tone = "DEPARTED".equals(d[5]) ? "is-sky" : "BOARDING".equals(d[5]) ? "is-amber" : "is-go"; %>
        <tr class="board-row">
          <td><span data-flap><%= d[0] %></span></td>
          <td><span data-flap><%= d[1] %></span></td>
          <td class="hide-sm"><span data-flap class="is-sky"><%= d[2] %></span></td>
          <td><span data-flap><%= d[3] %></span></td>
          <td class="hide-sm"><span data-flap class="is-sky"><%= d[4] %></span></td>
          <td><span data-flap class="<%= tone %>"><%= String.format("%-8s", d[5]) %></span></td>
        </tr>
<% } %>
      </tbody>
    </table>
    </div>
    <div class="board-foot"><span>Terminal 1 &middot; Concourses A&ndash;C</span><span>Sign in to book</span></div>
  </section>
</main>

<jsp:include page="/WEB-INF/jspf/foot.jsp"/>
</body>
</html>
