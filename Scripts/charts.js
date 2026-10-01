/* Plain canvas horizontal count charts. The adjacent HTML table is the accessible alternative. */
(function () {
    "use strict";
    function draw(canvas) {
        var data = JSON.parse(canvas.getAttribute("data-chart"));
        var width = Math.max(260, canvas.parentElement.clientWidth - 36);
        var height = Math.max(160, data.labels.length * 56 + 24);
        var ratio = window.devicePixelRatio || 1;
        canvas.width = width * ratio; canvas.height = height * ratio;
        canvas.style.width = "100%"; canvas.style.height = height + "px";
        var ctx = canvas.getContext("2d");
        if (!ctx) return;
        ctx.scale(ratio, ratio); ctx.font = "14px Segoe UI, sans-serif";
        var max = Math.max.apply(null, data.values.concat([1]));
        data.labels.forEach(function (label, index) {
            var y = index * 56 + 20;
            ctx.fillStyle = "#202536";
            // Full labels and exact values remain in the HTML table at narrow widths.
            while (ctx.measureText(label).width > width - 10 && label.length > 4) label = label.slice(0, -2);
            ctx.fillText(label, 0, y);
            var bar = data.values[index] / max * (width - 50);
            ctx.fillStyle = "#5737b4"; ctx.fillRect(0, y + 8, bar, 18);
            ctx.fillStyle = "#202536"; ctx.fillText(String(data.values[index]), bar + 6, y + 22);
        });
    }
    function render() { document.querySelectorAll("canvas[data-chart]").forEach(draw); }
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", render); else render();
    window.addEventListener("resize", render);
}());
