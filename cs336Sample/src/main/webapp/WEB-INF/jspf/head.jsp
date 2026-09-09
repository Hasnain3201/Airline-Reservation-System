<%@ page pageEncoding="UTF-8" %><%
  String pageTitle = request.getParameter("title");
  String ctx = request.getContextPath();
%>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= pageTitle != null ? pageTitle + " - Contrail" : "Contrail" %></title>
  <meta name="theme-color" content="#E1EDF7">
  <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 40 40'%3E%3Ccircle cx='20' cy='20' r='18' fill='%23E1EDF7' stroke='%231C2E40' stroke-width='2'/%3E%3Cpath d='M7 27c8-1 16-6 22-15' fill='none' stroke='%235B8DBB' stroke-width='2.4' stroke-linecap='round' stroke-dasharray='1 4'/%3E%3Cpath transform='translate(22 6) rotate(35) scale(.55)' fill='%231C2E40' d='M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z'/%3E%3C/svg%3E">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght,SOFT,WONK@0,9..144,300..700,0..100,0..1;1,9..144,300..700,0..100,0..1&family=IBM+Plex+Mono:wght@400;500;600&family=Instrument+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/assets/contrail.css">
  <script src="<%= ctx %>/assets/contrail.js" defer></script>
