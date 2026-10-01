/* Q35: navigate only to the server-supplied public/current-role destinations. */
(function () {
    "use strict";
    document.addEventListener("keydown", function (event) {
        if (!event.altKey || event.ctrlKey || event.metaKey || event.shiftKey || event.repeat || event.isComposing || event.keyCode === 229) return;
        var target = event.target;
        if (target && (target.closest("input,textarea,select") || target.isContentEditable)) return;
        var keys = { h: "home", c: "courses", d: "dashboard", q: "help" };
        var key = keys[event.key.toLowerCase()];
        var settings = document.getElementById("shortcut-settings");
        var destination = key && settings ? settings.getAttribute("data-" + key) : null;
        if (!destination) return;
        event.preventDefault();
        window.location.assign(destination);
    });
}());
