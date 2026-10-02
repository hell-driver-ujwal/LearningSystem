/* Plain canvas horizontal count charts. The adjacent HTML table is the accessible alternative. */
(function () {
    "use strict";
    // Bar colours from the site palette, each at least 3:1 against the card (WCAG non-text contrast).
    var colours = ["#7b62d6", "#c2416f", "#a86a00", "#2f6fb5", "#2f7f57"];
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
        ctx.scale(ratio, ratio); ctx.font = "15px \"Source Sans 3\", Segoe UI, sans-serif";
        var max = Math.max.apply(null, data.values.concat([1]));
        data.labels.forEach(function (label, index) {
            var y = index * 56 + 20;
            ctx.fillStyle = "#26223a";
            // Full labels and exact values remain in the HTML table at narrow widths.
            while (ctx.measureText(label).width > width - 10 && label.length > 4) label = label.slice(0, -2);
            ctx.fillText(label, 0, y);
            var bar = data.values[index] / max * (width - 50);
            ctx.fillStyle = colours[index % colours.length];
            if (data.values[index] > 0) roundedBar(ctx, 0, y + 8, Math.max(bar, 4), 18);
            ctx.fillStyle = "#26223a"; ctx.fillText(String(data.values[index]), bar + 8, y + 22);
        });
    }
    function render() { document.querySelectorAll("canvas[data-chart]").forEach(draw); }
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", render); else render();
    // Draw again once the web font has loaded, so labels use the right font and are measured correctly.
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(render);
    window.addEventListener("resize", render);
}());
