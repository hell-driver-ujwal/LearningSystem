/* Plain canvas horizontal count charts. The adjacent HTML table is the accessible alternative. */
(function () {
    "use strict";
    // Bar colours from the dark site palette, each well above 3:1 against the card (WCAG non-text contrast).
    var colours = ["#9d8cff", "#ff7cc0", "#ffcb47", "#5fd3f3", "#5ee39a"];
    // Label colour comes from the stylesheet so charts follow the theme.
    function ink() { return getComputedStyle(document.body).getPropertyValue("--ink").trim() || "#f2f4fc"; }
    // Bar with a rounded right end; browsers without roundRect get a plain rectangle.
    function roundedBar(ctx, x, y, width, height) {
        if (typeof ctx.roundRect !== "function") { ctx.fillRect(x, y, width, height); return; }
        ctx.beginPath();
        ctx.roundRect(x, y, width, height, [0, height / 2, height / 2, 0]);
        ctx.fill();
    }
    function draw(canvas) {
        var data = JSON.parse(canvas.getAttribute("data-chart"));
        var width = Math.max(260, canvas.parentElement.clientWidth - 36);
        var height = Math.max(160, data.labels.length * 56 + 24);
        var ratio = window.devicePixelRatio || 1;
        canvas.width = width * ratio; canvas.height = height * ratio;
        canvas.style.width = "100%"; canvas.style.height = height + "px";
        var ctx = canvas.getContext("2d");
        if (!ctx) return;
        ctx.scale(ratio, ratio); ctx.font = "700 15px Nunito, Segoe UI, sans-serif";
        var max = Math.max.apply(null, data.values.concat([1]));
        data.labels.forEach(function (label, index) {
            var y = index * 56 + 20;
            ctx.fillStyle = ink();
            // Full labels and exact values remain in the HTML table at narrow widths.
            while (ctx.measureText(label).width > width - 10 && label.length > 4) label = label.slice(0, -2);
            ctx.fillText(label, 0, y);
            var bar = data.values[index] / max * (width - 50);
            ctx.fillStyle = colours[index % colours.length];
            if (data.values[index] > 0) roundedBar(ctx, 0, y + 8, Math.max(bar, 4), 18);
            ctx.fillStyle = ink(); ctx.fillText(String(data.values[index]), bar + 8, y + 22);
        });
    }
    function render() { document.querySelectorAll("canvas[data-chart]").forEach(draw); }
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", render); else render();
    // Draw again once the web font has loaded, so labels use the right font and are measured correctly.
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(render);
    window.addEventListener("resize", render);
}());
