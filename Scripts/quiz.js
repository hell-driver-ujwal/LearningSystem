// Quiz page: count answered questions, count down a time limit and warn before submitting unanswered questions.
// The server measures the real time and marks every answer; this script only helps the learner.
(function () {
    "use strict";
    var bar = document.getElementById("quizTimer");
    if (!bar) return;
    var questions = document.querySelectorAll("[data-question]");
    var answeredLabel = document.getElementById("quizAnswered");
    var progress = document.getElementById("quizProgress");

    function answered() {
        var count = 0;
        questions.forEach(function (question) { if (question.querySelector("input:checked")) count++; });
        return count;
    }
    function update() {
        var count = answered();
        answeredLabel.textContent = count + " of " + questions.length + " answered";
        progress.value = count;
    }
    document.addEventListener("change", function (event) { if (event.target.name && event.target.name.indexOf("q_") === 0) update(); });
    update();

    window.quizConfirm = function () {
        var missing = questions.length - answered();
        return missing === 0 || window.confirm(missing + (missing === 1 ? " question is" : " questions are") + " unanswered and will score zero. Submit anyway?");
    };

    var clock = document.getElementById("quizClock");
    if (!clock) return;
    var deadline = Date.now() + Number(bar.getAttribute("data-seconds")) * 1000;
    var submitted = false;
    function tick() {
        var remaining = Math.max(0, Math.ceil((deadline - Date.now()) / 1000));
        clock.lastElementChild.textContent = Math.floor(remaining / 60) + ":" + ("0" + remaining % 60).slice(-2) + " left";
        bar.classList.toggle("low", remaining <= 60);
        if (remaining === 0 && !submitted) {
            submitted = true;
            window.quizConfirm = function () { return true; };
            document.getElementById(bar.getAttribute("data-submit")).click();
        }
    }
    tick();
    window.setInterval(tick, 1000);
}());
