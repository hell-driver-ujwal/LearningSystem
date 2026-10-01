// Shared page behaviour. Every feature here is an enhancement: pages still work without JavaScript.
(function () {
    "use strict";
    document.documentElement.classList.remove("no-js");

    // Mobile menu: show or hide the navigation and keep aria-expanded in step for screen readers.
    var toggle = document.querySelector(".menu-toggle");
    var nav = document.getElementById("site-nav");
    if (toggle && nav) {
        toggle.addEventListener("click", function () {
            var open = nav.classList.toggle("is-open");
            toggle.setAttribute("aria-expanded", String(open));
        });
    }

    // ASP.NET validators hide their message as soon as a field loses focus. That moves the layout while the
    // visitor is pressing a button, so the click can be lost. Waiting a moment lets the click finish first.
    if (typeof window.ValidatorOnChange === "function") {
        var updateValidators = window.ValidatorOnChange;
        window.ValidatorOnChange = function (event) {
            window.setTimeout(function () { updateValidators(event); }, 300);
        };
    }

    // Help page: filter FAQ questions as the visitor types.
    var filter = document.getElementById("faq-filter");
    if (filter) {
        var count = document.getElementById("faq-count");
        filter.addEventListener("input", function () {
            var term = filter.value.trim().toLowerCase();
            var shown = 0;
            document.querySelectorAll("[data-faq]").forEach(function (item) {
                var match = term === "" || item.textContent.toLowerCase().indexOf(term) >= 0;
                item.hidden = !match;
                if (match) shown++;
                if (match && term !== "") item.open = true;
            });
            if (count) count.textContent = term === "" ? "" : shown + (shown === 1 ? " question matches." : " questions match.");
        });
    }

    // Code lab: run the learner's HTML inside a sandboxed frame. The frame has no access to this page.
    document.querySelectorAll("[data-codelab]").forEach(function (lab) {
        var editor = lab.querySelector("textarea");
        var output = lab.querySelector("iframe");
        var original = editor.value;
        function run() { output.srcdoc = editor.value; }
        lab.querySelector("[data-run]").addEventListener("click", run);
        lab.querySelector("[data-reset]").addEventListener("click", function () {
            editor.value = original;
            run();
            editor.focus();
        });
        // Tab inserts two spaces; Escape then Tab still moves focus out, so keyboard users are never trapped.
        var escaped = false;
        editor.addEventListener("keydown", function (event) {
            if (event.key === "Escape") { escaped = true; return; }
            if (event.key === "Tab" && !event.shiftKey && !escaped) {
                event.preventDefault();
                var start = editor.selectionStart;
                editor.value = editor.value.slice(0, start) + "  " + editor.value.slice(editor.selectionEnd);
                editor.selectionStart = editor.selectionEnd = start + 2;
            }
            if (event.key !== "Tab") escaped = false;
        });
        run();
    });
}());
