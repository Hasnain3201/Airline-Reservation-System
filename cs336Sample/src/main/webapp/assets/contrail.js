(function () {
  "use strict";

  var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var GLYPHS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  function flap(el, text) {
    var target = (text != null ? text : el.getAttribute("data-flap") || el.textContent).toUpperCase();
    el.setAttribute("data-flap", target);
    el.setAttribute("aria-label", target);
    el.classList.add("flap");
    el.innerHTML = "";
    var tiles = [];
    for (var i = 0; i < target.length; i++) {
      var tile = document.createElement("i");
      tile.setAttribute("aria-hidden", "true");
      tile.textContent = target[i] === " " ? "\u00A0" : target[i];
      el.appendChild(tile);
      tiles.push(tile);
    }
    if (reduceMotion) return;
    tiles.forEach(function (tile, idx) {
      var ch = target[idx];
      if (ch === " " || ch === ":" || ch === "." || ch === "-" || ch === "/") return;
      var spins = 5 + Math.floor(Math.random() * 6) + idx;
      var n = 0;
      var timer = setInterval(function () {
        n++;
        if (n >= spins) {
          tile.textContent = ch;
          clearInterval(timer);
          return;
        }
        tile.textContent = GLYPHS[Math.floor(Math.random() * GLYPHS.length)];
      }, 45);
    });
  }

  function pad(n) { return n < 10 ? "0" + n : "" + n; }

  function initClocks() {
    var clocks = document.querySelectorAll("[data-clock]");
    if (!clocks.length) return;
    var last = "";
    function tick() {
      var d = new Date();
      var t = pad(d.getHours()) + ":" + pad(d.getMinutes());
      if (t !== last) {
        last = t;
        clocks.forEach(function (c) { flap(c, t); });
      }
    }
    tick();
    setInterval(tick, 5000);
  }

  function initGreeting() {
    document.querySelectorAll("[data-greeting]").forEach(function (el) {
      var h = new Date().getHours();
      el.textContent = h < 5 ? "Flying late" : h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening";
    });
  }

  function initFill() {
    document.querySelectorAll("[data-fill-email]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var email = document.getElementById("email");
        var pass = document.getElementById("password");
        if (!email || !pass) return;
        email.value = btn.getAttribute("data-fill-email");
        pass.value = btn.getAttribute("data-fill-pass");
        email.dispatchEvent(new Event("input"));
        var submit = document.querySelector(".pass-login button[type=submit]");
        if (submit) submit.focus();
      });
    });
  }

  function syncOd(select) {
    var box = select.closest(".od-end");
    if (!box) return;
    var opt = select.options[select.selectedIndex];
    var code = box.querySelector(".od-code");
    var city = box.querySelector(".od-city");
    var hasValue = opt && opt.value;
    if (code) {
      code.textContent = hasValue ? opt.value : "???";
      code.classList.toggle("is-empty", !hasValue);
    }
    if (city) city.textContent = hasValue ? (opt.getAttribute("data-city") || "") : (select.getAttribute("data-empty") || "");
  }

  function initOd() {
    var selects = document.querySelectorAll("[data-od]");
    selects.forEach(function (s) {
      syncOd(s);
      s.addEventListener("change", function () { syncOd(s); });
    });
    var swap = document.querySelector("[data-swap]");
    if (swap) {
      swap.addEventListener("click", function () {
        var a = document.getElementById("dep");
        var b = document.getElementById("arr");
        if (!a || !b) return;
        var tmp = a.value; a.value = b.value; b.value = tmp;
        syncOd(a); syncOd(b);
      });
    }
  }

  function initSeats() {
    var out = document.querySelector("[data-seat-out]");
    if (!out) return;
    document.querySelectorAll(".seat input").forEach(function (input) {
      input.addEventListener("change", function () {
        if (input.checked) flap(out, input.value.length < 2 ? "0" + input.value : input.value);
      });
    });
  }

  function initConfirm() {
    document.querySelectorAll("[data-confirm]").forEach(function (el) {
      el.addEventListener("click", function (e) {
        if (!window.confirm(el.getAttribute("data-confirm"))) e.preventDefault();
      });
    });
  }

  function initBoardLinks() {
    document.querySelectorAll("tr[data-href]").forEach(function (row) {
      row.classList.add("board-link");
      row.addEventListener("click", function () { window.location.href = row.getAttribute("data-href"); });
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll("[data-flap]").forEach(function (el, i) {
      setTimeout(function () { flap(el); }, reduceMotion ? 0 : i * 18);
    });
    initClocks();
    initGreeting();
    initFill();
    initOd();
    initSeats();
    initConfirm();
    initBoardLinks();
  });

  window.Contrail = { flap: flap };
})();
