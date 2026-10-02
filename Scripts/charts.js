/* Plain canvas horizontal count charts. The adjacent HTML table is the accessible alternative. */
(function () {
    "use strict";
    // Soft pastel bar colours from the site palette; exact values are printed beside each bar.
    var colours = ["#8b73e0", "#e57ba1", "#e0a43a", "#5b9be0", "#4fae7f"];
    function roundedBar(ctx, x, y, width, height) {
        var r = Math.min(height / 2, width / 2);
        ctx.beginPath();
        ctx.moveTo(x, y); ctx.lineTo(x + width - r, y);
        ctx.arc(x + width - r, y + r, r, -Math.PI / 2, Math.PI / 2);
        ctx.lineTo(x, y + height); ctx.closePath(); ctx.fill();
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
    window.addEventListener("resize", render);
}());
