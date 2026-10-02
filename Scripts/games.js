// Inkwell learning games. Each game fills in the same hidden result field (hfResult);
// the server checks every answer again and calculates the real score, so nothing here can change a mark.
// Inky (the mascot) coaches in a speech bubble; the "Save my score" step appears only when a round is finished.
(function () {
    "use strict";
    var root = document.getElementById("gameRoot");
    if (!root) return;
    var data = JSON.parse(root.getAttribute("data-game"));
    var began = Date.now() - Number(root.getAttribute("data-elapsed")) * 1000;
    var shell = root.closest(".game-shell");
    var answers = {}, moves = 0, memoryComplete = false, finished = false, combo = 0, bestCombo = 0;

    // ---------- shared helpers: database text is always set with textContent ----------
    function element(tag, text, className) {
        var node = document.createElement(tag);
        if (text !== null && text !== undefined) node.textContent = text;
        if (className) node.className = className;
        return node;
    }
    function button(text, action, className) {
        var node = element("button", text, className || "game-button");
        node.type = "button";
        node.addEventListener("click", action);
        return node;
    }
    function icon(name) {
        var span = element("span");
        span.innerHTML = '<svg class="icon" aria-hidden="true"><use href="#i-' + name + '"></use></svg>';
        return span.firstChild;
    }
    function shuffled(values) {
        var copy = values.slice();
        for (var i = copy.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var value = copy[i]; copy[i] = copy[j]; copy[j] = value;
        }
        return copy;
    }
    function elapsed() { return Math.max(0, Math.floor((Date.now() - began) / 1000)); }
    function count(object) { return Object.keys(object).length; }
    function fx() { return window.inkFx || { play: function () { }, confetti: function () { }, toast: function () { } }; }
    // A copy of one of Inky's poses, rendered by the server into a hidden holder on the page.
    function mascot(pose) {
        var source = document.querySelector("#inky-poses .inky-" + pose);
        return source ? source.cloneNode(true) : element("span");
    }

    // ---------- heads-up display: counter, progress, combo and time ----------
    var hud = element("div", null, "game-hud");
    var counter = element("span", "", "pill-stat");
    var progressWrap = element("div", null, "game-progress");
    var progressBar = element("progress");
    progressBar.max = data.items.length; progressBar.value = 0;
    progressBar.setAttribute("aria-label", "Game progress");
    progressWrap.appendChild(progressBar);
    var comboPill = element("span", "", "pill-stat combo");
    comboPill.hidden = true;
    var clock = element("span", null, "pill-stat");
    var clockText = document.createTextNode("0:00");
    clock.appendChild(icon("clock")); clock.appendChild(clockText);
    hud.appendChild(counter); hud.appendChild(progressWrap); hud.appendChild(comboPill); hud.appendChild(clock);
    root.appendChild(hud);

    // ---------- coach: Inky with a speech bubble that announces every change ----------
    var coach = element("div", null, "game-coach");
    var coachFace = mascot("think");
    var status = element("p", "", "game-status");
    status.setAttribute("role", "status");
    status.setAttribute("aria-live", "polite");
    coach.appendChild(coachFace); coach.appendChild(status);
    root.appendChild(coach);
    var board = element("div");
    root.appendChild(board);

    function setProgress(done, label) {
        progressBar.value = done;
        counter.textContent = label || (done + " of " + data.items.length);
    }
    function announce(text, mood) {
        status.textContent = text;
        status.className = "game-status" + (mood ? " " + mood : "");
        var pose = mood === "good" ? "cheer" : mood === "bad" ? "oops" : "think";
        if (!coachFace.classList.contains("inky-" + pose)) {
            var next = mascot(pose);
            coach.replaceChild(next, coachFace); coachFace = next;
        }
    }
    function bumpCombo(hit) {
        combo = hit ? combo + 1 : 0;
        bestCombo = Math.max(bestCombo, combo);
        comboPill.hidden = combo < 2;
        comboPill.textContent = "Combo x" + combo;
        if (combo >= 2) { comboPill.classList.remove("bump"); void comboPill.offsetWidth; comboPill.classList.add("bump"); }
    }
    window.setInterval(function () {
        if (finished) return;
        var s = elapsed();
        clockText.textContent = Math.floor(s / 60) + ":" + ("0" + s % 60).slice(-2);
    }, 1000);
    function section(title, container) {
        var node = element("section", null, "game-column");
        node.appendChild(element("h3", title));
        container.appendChild(node); return node;
    }

    // ---------- finishing a round: celebration, then the real submit button ----------
    var finishPanel = null;
    function finish(heading, summary) {
        finished = true;
        if (shell) shell.classList.add("is-finished");
        if (!finishPanel) {
            finishPanel = element("div", null, "game-finish");
            finishPanel.setAttribute("role", "region");
            finishPanel.setAttribute("aria-label", "Round finished");
            root.appendChild(finishPanel);
        }
        finishPanel.textContent = "";
        finishPanel.appendChild(mascot("trophy"));
        var text = element("div");
        text.appendChild(element("h3", heading));
        text.appendChild(element("p", summary + " Save your score to see your mark and earn XP."));
        var save = button("Save my score", function () {
            var submit = document.querySelector(".submit-row input[type=submit]");
            if (submit) submit.click();
        }, "button large accent");
        text.appendChild(save);
        finishPanel.appendChild(text);
        fx().confetti(120); fx().play("complete");
        save.focus();
    }
    function unfinish() {
        finished = false;
        if (shell) shell.classList.remove("is-finished");
        if (finishPanel) { finishPanel.remove(); finishPanel = null; }
    }

    // ---------- 1. Matching: pick an item, then its match; each pair gets its own colour ----------
    function matching() {
        announce("Pick an item on the left, then its match on the right. Pick an item again to change its match.");
        var layout = element("div", null, "game-columns"); board.appendChild(layout);
        var left = section("Items", layout), right = section("Matches", layout);
        var selected = null, leftButtons = {}, rightButtons = {}, order = shuffled(data.items);
        function pairIndex(itemId) { for (var i = 0; i < order.length; i++) if (order[i].id === itemId) return i; return -1; }
        function paint(node, index, label) {
            node.className = node.className.replace(/\s?pair-\d+/g, "");
            var tag = node.querySelector(".pair-tag");
            if (index < 0) { if (tag) tag.remove(); return; }
            node.classList.add("pair-" + (index % 8));
            if (!tag) { tag = element("span", "", "pair-tag"); node.insertBefore(tag, node.firstChild); }
            tag.textContent = label;
        }
        function refresh() {
            var number = 0;
            order.forEach(function (item) {
                var node = leftButtons[item.id], target = answers[item.id];
                node.setAttribute("aria-pressed", String(selected === item.id));
                node.classList.toggle("is-selected", selected === item.id);
                if (target) { number++; paint(node, pairIndex(item.id), String(number)); paint(rightButtons[target], pairIndex(item.id), String(number)); }
                else paint(node, -1);
                node.setAttribute("aria-label", item.text + (target ? ", matched with " + rightButtons[target].getAttribute("data-text") : ", not matched yet"));
            });
            data.items.forEach(function (target) {
                var used = data.items.some(function (item) { return answers[item.id] === String(target.id); });
                if (!used) paint(rightButtons[target.id], -1);
            });
            setProgress(count(answers));
            if (count(answers) === data.items.length && !finished) finish("Every item is matched!", "Check the colours: each pair shares a number.");
            else if (finished) unfinish();
        }
        order.forEach(function (item) {
            leftButtons[item.id] = button(item.text, function () { selected = item.id; refresh(); fx().play("click"); announce("Now pick the match for: " + item.text); });
            left.appendChild(leftButtons[item.id]);
        });
        shuffled(data.items).forEach(function (target) {
            var node = button(target.match, function () {
                if (selected === null) { announce("Pick an item on the left first.", "bad"); fx().play("wrong"); return; }
                // Each match can be used once; choosing it again moves it to the new item.
                data.items.forEach(function (item) { if (answers[item.id] === String(target.id)) delete answers[item.id]; });
                answers[selected] = String(target.id); selected = null; fx().play("flip");
                announce(count(answers) + " of " + data.items.length + " matched.");
                refresh();
            });
            node.setAttribute("data-text", target.match);
            rightButtons[String(target.id)] = node;
            right.appendChild(node);
        });
        refresh();
    }

    // ---------- 2. Memory: flip two cards; matching pairs stay up, a streak builds a combo ----------
    function memory() {
        announce("Flip two cards to find a matching pair. Each pair of flips counts as one move.");
        var grid = element("div", null, "memory-board"); board.appendChild(grid);
        var cards = [], first = null, busy = false, matched = 0;
        data.items.forEach(function (item) { cards.push({ pair: item.id, text: item.text }); cards.push({ pair: item.id, text: item.match }); });
        function update() { setProgress(matched, matched + " of " + data.items.length + " pairs, " + moves + " moves"); }
        shuffled(cards).forEach(function (card, index) {
            var node = element("button", null, "memory-card");
            node.type = "button";
            var back = element("span", null, "memory-face memory-back");
            back.appendChild(mascot("wave"));
            var front = element("span", card.text, "memory-face memory-front");
            node.appendChild(back); node.appendChild(front);
            node.setAttribute("aria-label", "Card " + (index + 1) + ", face down");
            node.addEventListener("click", function () {
                if (busy || node.disabled || node.classList.contains("is-flipped")) return;
                node.classList.add("is-flipped"); fx().play("flip");
                node.setAttribute("aria-label", "Card " + (index + 1) + ": " + card.text);
                if (!first) { first = { card: card, node: node }; announce("First card: " + card.text + ". Pick a second card."); return; }
                moves++;
                var previous = first; first = null;
                if (previous.card.pair === card.pair) {
                    matched++; previous.node.disabled = true; node.disabled = true;
                    previous.node.classList.add("is-matched"); node.classList.add("is-matched");
                    bumpCombo(true); fx().play("correct");
                    memoryComplete = matched === data.items.length;
                    announce(memoryComplete ? "All pairs found!" : combo >= 2 ? "Pair! " + combo + " in a row!" : "A pair! Keep going.", "good");
                    if (memoryComplete) finish("All pairs found!", "You needed " + moves + " moves. Best run: " + bestCombo + " pairs in a row.");
                } else {
                    busy = true; bumpCombo(false); fx().play("wrong");
                    previous.node.classList.add("is-wrong"); node.classList.add("is-wrong");
                    announce("Not a pair. Remember where they are.", "bad");
                    window.setTimeout(function () {
                        [previous.node, node].forEach(function (n) { n.classList.remove("is-flipped", "is-wrong"); });
                        previous.node.setAttribute("aria-label", previous.node.getAttribute("aria-label").replace(/:.*/, ", face down"));
                        node.setAttribute("aria-label", "Card " + (index + 1) + ", face down");
                        busy = false;
                    }, 1100);
                }
                update();
            });
            grid.appendChild(node);
        });
        update();
    }

    // ---------- 3. Word scramble: tap letter tiles (or type) to build each word ----------
    function scramble() {
        announce("Tap the letters in the right order, or type the word. The hint tells you what it means.");
        shuffled(data.items).forEach(function (item, index) {
            var letters = shuffled(item.text.toUpperCase().split(""));
            if (letters.join("") === item.text.toUpperCase() && letters.length > 1) letters.push(letters.shift());
            var card = element("div", null, "scramble-card");
            var label = element("label", "Word " + (index + 1) + ": " + item.match);
            label.htmlFor = "word_" + item.id;
            var tiles = element("div", null, "scramble-letters");
            tiles.setAttribute("aria-label", "Letters: " + letters.join(" "));
            var row = element("div", null, "scramble-answer");
            var input = document.createElement("input");
            input.type = "text"; input.id = label.htmlFor; input.maxLength = 15; input.autocomplete = "off"; input.spellcheck = false;
            var tileButtons = [];
            function sync() {
                // Grey out tiles already used in the typed word, letter by letter.
                var remaining = input.value.toUpperCase().split("");
                tileButtons.forEach(function (tile) {
                    var at = remaining.indexOf(tile.textContent);
                    tile.disabled = at >= 0; if (at >= 0) remaining.splice(at, 1);
                });
                if (input.value.trim()) answers[item.id] = input.value.trim(); else delete answers[item.id];
                setProgress(count(answers));
                var allFull = data.items.every(function (it) { return answers[it.id] && answers[it.id].length === it.text.length; });
                if (allFull && !finished) finish("Every word is built!", "Check your spelling before you save.");
                else if (!allFull && finished) unfinish();
            }
            letters.forEach(function (letter) {
                var tile = button(letter, function () { input.value += letter; fx().play("click"); sync(); }, "letter-tile");
                tile.setAttribute("aria-label", "Add letter " + letter);
                tileButtons.push(tile); tiles.appendChild(tile);
            });
            var undo = button("Undo", function () { input.value = input.value.slice(0, -1); sync(); input.focus(); }, "button small secondary");
            var clear = button("Clear", function () { input.value = ""; sync(); input.focus(); }, "button small secondary");
            input.addEventListener("input", sync);
            row.appendChild(input); row.appendChild(undo); row.appendChild(clear);
            card.appendChild(label); card.appendChild(tiles); card.appendChild(row); board.appendChild(card);
        });
        setProgress(0);
    }

    // ---------- 4. Sort: drag items into the group buckets, or tap an item then a bucket ----------
    function sort() {
        announce("Drag each item into its group. You can also tap an item, then tap a group.");
        var tray = element("div", null, "sort-tray");
        tray.setAttribute("aria-label", "Items to sort");
        var boardGrid = element("div", null, "sort-board");
        board.appendChild(tray); board.appendChild(boardGrid);
        var selected = null, itemButtons = {}, buckets = {};
        function place(itemId, groupId) {
            if (groupId === null) delete answers[itemId]; else answers[itemId] = String(groupId);
            selected = null; fx().play("flip"); refresh();
        }
        function refresh() {
            data.items.forEach(function (item) {
                var node = itemButtons[item.id], groupId = answers[item.id];
                node.classList.toggle("is-selected", selected === item.id);
                node.setAttribute("aria-pressed", String(selected === item.id));
                var home = groupId ? buckets[groupId].list : tray;
                if (node.parentNode !== home) home.appendChild(node);
            });
            setProgress(count(answers));
            if (count(answers) === data.items.length && !finished) finish("Everything is sorted!", "Move any item before you save if you change your mind.");
            else if (finished) unfinish();
        }
        function dropTarget(zone, groupId) {
            zone.addEventListener("dragover", function (e) { e.preventDefault(); zone.classList.add("is-over"); });
            zone.addEventListener("dragleave", function () { zone.classList.remove("is-over"); });
            zone.addEventListener("drop", function (e) {
                e.preventDefault(); zone.classList.remove("is-over");
                var id = Number(e.dataTransfer.getData("text/plain"));
                if (itemButtons[id]) { place(id, groupId); announce(count(answers) + " of " + data.items.length + " sorted."); }
            });
        }
        dropTarget(tray, null);
        data.groups.forEach(function (group) {
            var bucket = element("section", null, "sort-bucket");
            bucket.appendChild(element("h3", group.name));
            var list = element("div", null, "sort-items");
            var drop = button("Put the selected item here", function () {
                if (selected === null) { announce("Pick an item first.", "bad"); fx().play("wrong"); return; }
                place(selected, group.id); announce(count(answers) + " of " + data.items.length + " sorted.");
            }, "game-button drop-here");
            bucket.appendChild(list); bucket.appendChild(drop);
            buckets[String(group.id)] = { list: list };
            dropTarget(bucket, group.id);
            boardGrid.appendChild(bucket);
        });
        shuffled(data.items).forEach(function (item) {
            var node = button(item.text, function () {
                selected = selected === item.id ? null : item.id; fx().play("click"); refresh();
                if (selected !== null) announce("Where does this belong: " + item.text + "?");
            });
            node.draggable = true;
            node.addEventListener("dragstart", function (e) { e.dataTransfer.setData("text/plain", String(item.id)); node.classList.add("dragging"); });
            node.addEventListener("dragend", function () { node.classList.remove("dragging"); });
            itemButtons[item.id] = node;
        });
        refresh();
    }

    // ---------- 5. Flashcards: recall, flip, then rate yourself honestly ----------
    function flashcards() {
        var order = shuffled(data.items), index = 0;
        var stage = element("div", null, "flashcard-stage"); board.appendChild(stage);
        var dots = element("div", null, "flash-dots"); dots.setAttribute("aria-hidden", "true");
        order.forEach(function () { dots.appendChild(element("span")); });
        var card = element("button", null, "flashcard"); card.type = "button";
        var inner = element("span", null, "flashcard-inner");
        var front = element("span", null, "flashcard-face"), back = element("span", null, "flashcard-face flashcard-back");
        inner.appendChild(front); inner.appendChild(back); card.appendChild(inner);
        stage.appendChild(dots); stage.appendChild(card);
        var rate = element("div", null, "actions"); stage.appendChild(rate);
        var learning = button("Still learning", function () { record("learning"); }, "button secondary");
        var knew = button("I knew it", function () { record("known"); }, "button accent");
        rate.appendChild(learning); rate.appendChild(knew);
        function show() {
            var item = order[index];
            card.classList.remove("is-flipped");
            front.textContent = ""; back.textContent = "";
            front.appendChild(element("small", "Card " + (index + 1) + " of " + order.length)); front.appendChild(document.createTextNode(item.text));
            back.appendChild(element("small", "Answer")); back.appendChild(document.createTextNode(item.match));
            card.setAttribute("aria-label", "Card " + (index + 1) + ": " + item.text + ". Select to flip.");
            Array.prototype.forEach.call(dots.children, function (dot, i) { dot.classList.toggle("now", i === index); });
            rate.hidden = true;
            announce("Think of the answer, then flip the card.");
        }
        card.addEventListener("click", function () {
            if (finished) return;
            card.classList.toggle("is-flipped"); fx().play("flip");
            var flipped = card.classList.contains("is-flipped");
            card.setAttribute("aria-label", flipped ? "Answer: " + order[index].match + ". Select to flip back." : "Card: " + order[index].text);
            if (flipped) { rate.hidden = false; announce("Did you know it? Be honest: it helps you review."); }
        });
        function record(value) {
            answers[order[index].id] = value;
            dots.children[index].classList.add(value);
            if (value === "known") { bumpCombo(true); fx().play("correct"); } else bumpCombo(false);
            index++;
            setProgress(count(answers));
            if (index < order.length) { show(); card.focus(); return; }
            rate.hidden = true; card.disabled = true;
            var known = Object.keys(answers).filter(function (k) { return answers[k] === "known"; }).length;
            announce("Deck finished!", "good");
            finish("Deck finished!", "You knew " + known + " of " + order.length + " cards.");
        }
        setProgress(0); show();
    }

    // ---------- 6. Fill in the blank: type the missing word in each sentence ----------
    function fillBlank() {
        announce("Type the missing word or phrase in each sentence. Spelling counts; capital letters do not.");
        data.items.forEach(function (item, index) {
            var card = element("div", null, "blank-card");
            var parts = item.match.split("___");
            var sentence = element("span", null, "sentence");
            sentence.appendChild(document.createTextNode((index + 1) + ". " + parts[0]));
            sentence.appendChild(element("span", "?", "gap"));
            sentence.appendChild(document.createTextNode(parts[1] || ""));
            var label = element("label", "Your answer for sentence " + (index + 1));
            label.className = "visually-hidden";
            label.htmlFor = "blank_" + item.id;
            var input = document.createElement("input");
            input.type = "text"; input.id = label.htmlFor; input.maxLength = 100; input.autocomplete = "off"; input.placeholder = "Type the missing word";
            input.addEventListener("input", function () {
                if (input.value.trim()) answers[item.id] = input.value.trim(); else delete answers[item.id];
                sentence.querySelector(".gap").textContent = input.value.trim() || "?";
                setProgress(count(answers));
                if (count(answers) === data.items.length && !finished) finish("Every gap is filled!", "Read each sentence once more before you save.");
                else if (count(answers) < data.items.length && finished) unfinish();
            });
            card.appendChild(sentence); card.appendChild(label); card.appendChild(input); board.appendChild(card);
        });
        setProgress(0);
    }

    // ---------- 7. True or false speed round: a few seconds per statement, streaks build a combo ----------
    function trueFalse() {
        var order = shuffled(data.items), index = 0, right = 0, timer = null, deadline = 0;
        var SECONDS = 12;
        var stageCard = element("div", null, "tf-card"); board.appendChild(stageCard);
        var bar = element("div", null, "tf-timer"); var fill = element("span"); bar.appendChild(fill);
        var text = element("p", "", "statement-text");
        var choices = element("div", null, "tf-buttons");
        var yes = button("True", function () { answer("True"); }, "true");
        var no = button("False", function () { answer("False"); }, "false");
        choices.appendChild(yes); choices.appendChild(no);
        stageCard.appendChild(bar); stageCard.appendChild(text); stageCard.appendChild(choices);
        function show() {
            stageCard.classList.remove("is-right", "is-wrong");
            text.textContent = order[index].match;
            yes.disabled = no.disabled = false;
            setProgress(index, "Statement " + (index + 1) + " of " + order.length);
            deadline = Date.now() + SECONDS * 1000;
            timer = window.setInterval(function () {
                var left = Math.max(0, deadline - Date.now());
                fill.style.width = (left / (SECONDS * 10)) + "%";
                if (left === 0) answer("Skip");
            }, 100);
            yes.focus();
        }
        function answer(value) {
            window.clearInterval(timer);
            yes.disabled = no.disabled = true;
            var item = order[index];
            answers[item.id] = value;
            if (value === item.text) {
                right++; bumpCombo(true); fx().play("correct"); stageCard.classList.add("is-right");
                announce(combo > 1 ? "Correct! Combo x" + combo + "!" : "Correct!", "good");
            } else {
                bumpCombo(false); fx().play("wrong"); stageCard.classList.add("is-wrong");
                announce((value === "Skip" ? "Time is up. " : "Not quite. ") + "That statement is " + item.text.toLowerCase() + ".", "bad");
            }
            index++;
            setProgress(index, "Statement " + Math.min(index + 1, order.length) + " of " + order.length);
            window.setTimeout(function () {
                if (index < order.length) { show(); return; }
                text.textContent = right + " of " + order.length + " correct";
                choices.hidden = true; bar.hidden = true;
                finish("Round complete!", right + " of " + order.length + " correct, best combo " + bestCombo + ".");
            }, 1300);
        }
        announce("Decide quickly: is each statement true or false? You have " + SECONDS + " seconds for each one.");
        show();
    }

    // ---------- 8. Put in order: drag the steps, or use the arrow buttons ----------
    function sequence() {
        announce("Drag the steps into the right order, or use the arrow buttons. Press Check order when you are happy.");
        var order = shuffled(data.items);
        var list = element("ol", null, "sequence-list"); board.appendChild(list);
        var done = button("Check order", function () { finish("Order locked in!", "You can still move steps before you save."); }, "button");
        var doneRow = element("div", null, "actions"); doneRow.appendChild(done); board.appendChild(doneRow);
        function record() {
            order.forEach(function (item, position) { answers[item.id] = String(position + 1); });
            setProgress(order.length, "Steps placed");
        }
        function render(focusId, direction) {
            list.textContent = "";
            order.forEach(function (item, position) {
                var row = element("li");
                row.setAttribute("data-id", item.id);
                var grip = element("span", null, "grip"); grip.appendChild(icon("grip"));
                row.appendChild(grip);
                row.appendChild(element("span", item.text));
                var move = element("span", null, "move");
                var up = button("↑", function () { swap(position, position - 1, item.id, "up"); }, "small");
                var down = button("↓", function () { swap(position, position + 1, item.id, "down"); }, "small");
                up.setAttribute("aria-label", "Move up: " + item.text); down.setAttribute("aria-label", "Move down: " + item.text);
                up.disabled = position === 0; down.disabled = position === order.length - 1;
                move.appendChild(up); move.appendChild(down); row.appendChild(move); list.appendChild(row);
                if (item.id === focusId) (direction === "up" && !up.disabled ? up : !down.disabled ? down : up).focus();
                enableDrag(row);
            });
            record();
        }
        function swap(from, to, id, direction) {
            if (to < 0 || to >= order.length) return;
            var value = order[from]; order[from] = order[to]; order[to] = value;
            fx().play("flip"); render(id, direction);
            announce("Moved " + value.text + " to position " + (to + 1) + ".");
        }
        // Pointer dragging works for mouse, pen and touch: the row follows the pointer and swaps with its neighbours.
        function enableDrag(row) {
            row.addEventListener("pointerdown", function (e) {
                if (e.target.closest("button")) return;
                var startY = e.clientY, dragged = row; dragged.classList.add("dragging");
                dragged.setPointerCapture(e.pointerId);
                function moveTo(ev) {
                    dragged.style.transform = "translateY(" + (ev.clientY - startY) + "px)";
                    var rows = Array.prototype.slice.call(list.children);
                    var index = rows.indexOf(dragged);
                    var neighbour = ev.clientY - startY > 0 ? rows[index + 1] : rows[index - 1];
                    if (!neighbour) return;
                    var box = neighbour.getBoundingClientRect(), mid = box.top + box.height / 2;
                    if ((ev.clientY - startY > 0 && ev.clientY > mid) || (ev.clientY - startY < 0 && ev.clientY < mid)) {
                        var before = dragged.getBoundingClientRect().top;
                        if (ev.clientY - startY > 0) list.insertBefore(neighbour, dragged); else list.insertBefore(dragged, neighbour);
                        startY += dragged.getBoundingClientRect().top - before;
                        dragged.style.transform = "translateY(" + (ev.clientY - startY) + "px)";
                    }
                }
                function end() {
                    dragged.classList.remove("dragging"); dragged.style.transform = "";
                    dragged.removeEventListener("pointermove", moveTo); dragged.removeEventListener("pointerup", end); dragged.removeEventListener("pointercancel", end);
                    var ids = Array.prototype.map.call(list.children, function (li) { return Number(li.getAttribute("data-id")); });
                    order = ids.map(function (id) { return data.items.filter(function (it) { return it.id === id; })[0]; });
                    fx().play("flip"); render();
                }
                dragged.addEventListener("pointermove", moveTo); dragged.addEventListener("pointerup", end); dragged.addEventListener("pointercancel", end);
            });
        }
        render();
    }

    var games = { Matching: matching, Memory: memory, Scramble: scramble, Sort: sort, Flashcards: flashcards, FillBlank: fillBlank, TrueFalse: trueFalse, Sequence: sequence };
    if (games[data.template]) games[data.template]();

    // ---------- the exact hfResult contract: no score is ever sent ----------
    window.learningGame = {
        prepare: function () {
            var result = { timeTakenSeconds: elapsed(), answers: [] };
            if (data.template === "Memory") {
                if (!memoryComplete) { announce("Find all the pairs before you save.", "bad"); return false; }
                result.moves = moves;
            } else {
                for (var i = 0; i < data.items.length; i++) {
                    var item = data.items[i], value = answers[item.id];
                    if (!value) { announce(data.template === "TrueFalse" || data.template === "Flashcards" ? "Finish the round before you save." : "Complete every item before you save.", "bad"); return false; }
                    if (data.template === "Scramble" && !/^[A-Za-z]{3,15}$/.test(value)) { announce("Each word must be 3 to 15 letters, with no spaces or numbers.", "bad"); return false; }
                    result.answers.push({ itemId: item.id, value: value });
                }
            }
            document.getElementById("hfResult").value = JSON.stringify(result);
            return true;
        }
    };
}());
