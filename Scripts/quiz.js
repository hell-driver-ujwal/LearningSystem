(function () {
    "use strict";
    var timer = document.getElementById("quizTimer");
    if (!timer) return;
    var deadline = Date.now() + Number(timer.getAttribute("data-seconds")) * 1000;
    var submitted = false;
    function tick() {
        var remaining = Math.max(0, Math.ceil((deadline - Date.now()) / 1000));
        timer.textContent = "Time remaining: " + Math.floor(remaining / 60) + ":" + ("0" + remaining % 60).slice(-2);
        if (remaining === 0 && !submitted) {
            submitted = true;
            document.getElementById(timer.getAttribute("data-submit")).click();
        }
    }
    tick();
    window.setInterval(tick, 1000);
}());
