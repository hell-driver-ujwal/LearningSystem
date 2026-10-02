// Quiz page: one question at a time with numbered steps, answer keys 1 to 6, a live answered count,
// a countdown for timed quizzes and a warning before submitting unanswered questions.
// The server measures the real time and marks every answer; this script only helps the learner.
(function () {
    "use strict";
    var bar = document.getElementById("quizTimer");
    if (!bar) return;
    var questions = Array.prototype.slice.call(document.querySelectorAll("[data-question]"));
    var answeredLabel = document.getElementById("quizAnswered");
    var progress = document.getElementById("quizProgress");
    var current = 0, steps = [];
    function fx() { return window.inkFx || { play: function () { } }; }

    function isAnswered(question) { return !!question.querySelector("input:checked"); }
    function answered() { return questions.filter(isAnswered).length; }
    function update() {
        var count = answered();
        answeredLabel.textContent = count + " of " + questions.length + " answered";
        progress.value = count;
        steps.forEach(function (step, i) { step.classList.toggle("answered", isAnswered(questions[i])); });
    }

    // Number keys on each option so learners can answer with 1, 2, 3...
    questions.forEach(function (question) {
        question.querySelectorAll(".quiz-option").forEach(function (option, i) {
            var key = document.createElement("span");
            key.className = "key"; key.textContent = String(i + 1); key.setAttribute("aria-hidden", "true");
            option.insertBefore(key, option.firstChild);
        });
    });

    // One question at a time: step buttons plus Back and Next under the question.
    if (questions.length > 1) {
        var holder = questions[0].parentNode;
        holder.classList.add("is-stepped");
        var list = document.createElement("ol");
        list.className = "quiz-steps"; list.setAttribute("aria-label", "Questions");
        questions.forEach(function (question, i) {
            var item = document.createElement("li");
            var step = document.createElement("button");
            step.type = "button"; step.textContent = String(i + 1);
            step.setAttribute("aria-label", "Question " + (i + 1));
            step.addEventListener("click", function () { show(i, true); });
            item.appendChild(step); list.appendChild(item); steps.push(step);
        });
        holder.insertBefore(list, questions[0]);
        var nav = document.createElement("div");
        nav.className = "quiz-nav";
        var back = document.createElement("button"); back.type = "button"; back.className = "button secondary"; back.textContent = "Back";
        var next = document.createElement("button"); next.type = "button"; next.className = "button"; next.textContent = "Next question";
        back.addEventListener("click", function () { show(current - 1, true); });
        next.addEventListener("click", function () { show(current + 1, true); });
        nav.appendChild(back); nav.appendChild(next);
        questions[questions.length - 1].parentNode.insertBefore(nav, questions[questions.length - 1].nextSibling);

        var show = function (index, moveFocus) {
            if (index < 0 || index >= questions.length) return;
            current = index;
            questions.forEach(function (question, i) { question.hidden = i !== index; });
            steps.forEach(function (step, i) { if (i === index) step.setAttribute("aria-current", "step"); else step.removeAttribute("aria-current"); });
            back.disabled = index === 0;
            next.hidden = index === questions.length - 1;
            if (moveFocus) { var legend = questions[index].querySelector("legend"); legend.setAttribute("tabindex", "-1"); legend.focus(); }
        };
        window.quizShow = show;
        show(0, false);
    }

    document.addEventListener("change", function (event) {
        if (!event.target.name || event.target.name.indexOf("q_") !== 0) return;
        update(); fx().play("click");
        // Move on to the next question after a short pause, so the choice is visible first.
        if (questions.length > 1 && current < questions.length - 1 && questions[current].contains(event.target)) {
            var from = current;
            window.setTimeout(function () { if (current === from) window.quizShow(current + 1, false); }, 450);
        }
    });

    // Number keys choose an option in the question on screen (not while typing in a field).
    document.addEventListener("keydown", function (event) {
        if (event.ctrlKey || event.altKey || event.metaKey || /input|textarea|select/i.test(event.target.tagName) && event.target.type !== "radio") return;
        var number = Number(event.key);
        if (!number) return;
        var options = questions[current].querySelectorAll("input[type=radio]");
        if (options[number - 1]) { options[number - 1].checked = true; options[number - 1].focus(); options[number - 1].dispatchEvent(new Event("change", { bubbles: true })); }
    });
    update();

    window.quizConfirm = function () {
        var missing = questions.length - answered();
        if (missing === 0) return true;
        var first = questions.findIndex(function (q) { return !isAnswered(q); });
        if (window.quizShow) window.quizShow(first, true);
        return window.confirm(missing + (missing === 1 ? " question is" : " questions are") + " unanswered and will score zero. Submit anyway?");
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
