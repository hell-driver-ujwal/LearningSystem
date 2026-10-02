// Shared game effects: sounds, confetti, toasts, count-up numbers and the level-up screen.
// Everything here is decoration: pages work the same without it, and motion is skipped
// for visitors who ask their device to reduce motion.
(function () {
    "use strict";
    var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    // ---------- settings saved in this browser only ----------
    function load(key, fallback) { try { var v = window.localStorage.getItem(key); return v === null ? fallback : v; } catch (e) { return fallback; } }
    function save(key, value) { try { window.localStorage.setItem(key, value); } catch (e) { } }

    // ---------- sound: short tones made with the Web Audio API (no audio files) ----------
    var audio = null;
    var soundOn = load("inkwell-sound", "on") === "on";
    var tunes = {
        click: [[520, .05]],
        flip: [[660, .05], [880, .05]],
        correct: [[660, .08], [880, .08], [1180, .12]],
        wrong: [[220, .12], [180, .18]],
        complete: [[523, .1], [659, .1], [784, .1], [1047, .25]],
        levelup: [[392, .1], [523, .1], [659, .1], [784, .1], [1047, .3]]
    };
    function play(name) {
        if (!soundOn || !tunes[name]) return;
        try {
            audio = audio || new (window.AudioContext || window.webkitAudioContext)();
            var start = audio.currentTime;
            tunes[name].forEach(function (note) {
                var osc = audio.createOscillator(), gain = audio.createGain();
                osc.type = name === "wrong" ? "sawtooth" : "triangle";
                osc.frequency.value = note[0];
                gain.gain.setValueAtTime(.0001, start);
                gain.gain.exponentialRampToValueAtTime(.12, start + .01);
                gain.gain.exponentialRampToValueAtTime(.0001, start + note[1]);
                osc.connect(gain); gain.connect(audio.destination);
                osc.start(start); osc.stop(start + note[1] + .02);
                start += note[1] * .85;
            });
        } catch (e) { }
    }
    document.querySelectorAll("[data-sound-toggle]").forEach(function (button) {
        button.setAttribute("aria-pressed", String(soundOn));
        button.addEventListener("click", function () {
            soundOn = !soundOn;
            save("inkwell-sound", soundOn ? "on" : "off");
            document.querySelectorAll("[data-sound-toggle]").forEach(function (b) { b.setAttribute("aria-pressed", String(soundOn)); });
            toast(soundOn ? "Sound effects on" : "Sound effects off");
            play("click");
        });
    });

    // ---------- confetti: coloured pieces falling over the page for about two seconds ----------
    function confetti(amount) {
        if (reduceMotion) return;
        var canvas = document.createElement("canvas");
        canvas.className = "fx-confetti"; canvas.setAttribute("aria-hidden", "true");
        document.body.appendChild(canvas);
        var ctx = canvas.getContext("2d");
        canvas.width = window.innerWidth; canvas.height = window.innerHeight;
        var colours = ["#9d8cff", "#5ee39a", "#ffcb47", "#ff7cc0", "#5fd3f3", "#ff9a52"];
        var pieces = [];
        for (var i = 0; i < (amount || 140); i++) {
            pieces.push({ x: canvas.width / 2 + (Math.random() - .5) * 200, y: canvas.height * .35, vx: (Math.random() - .5) * 14, vy: -Math.random() * 14 - 4,
                size: 6 + Math.random() * 6, spin: Math.random() * 6, turn: (Math.random() - .5) * .3, colour: colours[i % colours.length] });
        }
        var frames = 0;
        (function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            pieces.forEach(function (p) {
                p.vy += .35; p.vx *= .99; p.x += p.vx; p.y += p.vy; p.spin += p.turn;
                ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.spin);
                ctx.fillStyle = p.colour; ctx.fillRect(-p.size / 2, -p.size / 4, p.size, p.size / 2);
                ctx.restore();
            });
            if (++frames < 130) window.requestAnimationFrame(draw); else canvas.remove();
        }());
    }

    // ---------- toasts: short messages in the corner ----------
    function toast(text, iconName) {
        var area = document.getElementById("toast-area");
        if (!area) return;
        var node = document.createElement("div");
        node.className = "toast";
        if (iconName) node.innerHTML = '<svg class="icon" aria-hidden="true"><use href="#i-' + iconName + '"></use></svg>';
        node.appendChild(document.createTextNode(text));
        area.appendChild(node);
        window.setTimeout(function () { node.remove(); }, 4600);
    }

    // ---------- numbers that count up when the page opens ----------
    document.querySelectorAll("[data-count-up]").forEach(function (node) {
        var target = Number(node.getAttribute("data-count-up"));
        if (reduceMotion || !isFinite(target) || target <= 0) return;
        var began = null;
        (function step(time) {
            began = began || time;
            var t = Math.min(1, (time - began) / 900);
            node.textContent = Math.round(target * (1 - Math.pow(1 - t, 3))).toLocaleString();
            if (t < 1) window.requestAnimationFrame(step);
        }(performance.now()));
    });

    // ---------- celebrations requested by a page (for example a perfect score) ----------
    document.querySelectorAll("[data-celebrate]").forEach(function (node) {
        var kind = node.getAttribute("data-celebrate");
        window.setTimeout(function () {
            if (kind === "big") { confetti(180); play("complete"); }
            else if (kind === "small") { confetti(70); play("correct"); }
            else play("click");
        }, 350);
    });

    // ---------- level up: compares the level shown now with the last level seen in this browser ----------
    var levelNode = document.querySelector("[data-level]");
    if (levelNode) {
        var key = "inkwell-level-" + levelNode.getAttribute("data-player");
        var now = Number(levelNode.getAttribute("data-level"));
        var seen = Number(load(key, "0"));
        var template = document.getElementById("levelup-template");
        if (seen > 0 && now > seen && template) {
            var overlay = template.content.firstElementChild.cloneNode(true);
            document.body.appendChild(overlay);
            var close = overlay.querySelector("button");
            close.addEventListener("click", function () { overlay.remove(); levelNode.focus && levelNode.focus(); });
            overlay.addEventListener("keydown", function (e) { if (e.key === "Escape") overlay.remove(); });
            close.focus();
            confetti(220); play("levelup");
        }
        save(key, String(now));
    }

    // ---------- gentle reveal of sections as they scroll into view ----------
    if (!reduceMotion && "IntersectionObserver" in window) {
        var watcher = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) { if (entry.isIntersecting) { entry.target.classList.add("is-visible"); watcher.unobserve(entry.target); } });
        }, { threshold: .12 });
        document.querySelectorAll(".reveal").forEach(function (node) { watcher.observe(node); });
    } else {
        document.querySelectorAll(".reveal").forEach(function (node) { node.classList.add("is-visible"); });
    }

    window.inkFx = { play: play, confetti: confetti, toast: toast, reduceMotion: reduceMotion };
}());
