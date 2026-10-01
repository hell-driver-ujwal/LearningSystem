// Inkwell learning games. Each game fills in the same hidden result field (hfResult);
// the server checks every answer again and calculates the real score, so nothing here can change a mark.
(function () {
    "use strict";
    var root = document.getElementById("gameRoot");
    if (!root) return;
    var data = JSON.parse(root.getAttribute("data-game"));
    var began = Date.now() - Number(root.getAttribute("data-elapsed")) * 1000;
    var answers = {}, moves = 0, memoryComplete = false, finished = false;

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

    // ---------- heads-up display: progress, time and a live status message ----------
    var hud = element("div", null, "game-hud");
    var progressWrap = element("div", null, "game-progress");
    var progressLabel = element("span", "", "visually-hidden");
    var progressBar = element("progress");
    progressBar.max = data.items.length; progressBar.value = 0;
    progressBar.setAttribute("aria-label", "Game progress");
    progressWrap.appendChild(progressLabel); progressWrap.appendChild(progressBar);
    var counter = element("span", "", "pill-stat");
    var clock = element("span", "0:00", "pill-stat");
    hud.appendChild(counter); hud.appendChild(progressWrap); hud.appendChild(clock);
    root.appendChild(hud);
    var status = element("p", "", "game-status");
    status.setAttribute("role", "status");
    status.setAttribute("aria-live", "polite");
    root.appendChild(status);
    var board = element("div");
    root.appendChild(board);

    function setProgress(done, label) {
        progressBar.value = done;
        counter.textContent = label || (done + " of " + data.items.length);
        progressLabel.textContent = counter.textContent;
    }
    function announce(text, mood) {
        status.textContent = text;
        status.className = "game-status" + (mood ? " " + mood : "");
    }
    window.setInterval(function () {
        var s = elapsed();
        clock.textContent = Math.floor(s / 60) + ":" + ("0" + s % 60).slice(-2);
    }, 1000);
    function section(title, container) {
        var node = element("section", null, "game-column");
        node.appendChild(element("h3", title));
        container.appendChild(node); return node;
    }

    // ---------- 1. Matching: select an item, then the answer it belongs with ----------
    function matching() {
        announce("Select an item on the left, then its match on the right. Select an item again to change its match.");
        var layout = element("div", null, "game-columns"); board.appendChild(layout);
        var left = section("Items", layout), right = section("Matches", layout);
        var selected = null, leftButtons = {}, rightButtons = {};
        function refresh() {
            data.items.forEach(function (item) {
                var node = leftButtons[item.id];
                var target = data.items.filter(function (other) { return String(other.id) === answers[item.id]; })[0];
                node.setAttribute("aria-pressed", String(selected === item.id));
                node.classList.toggle("is-selected", selected === item.id);
                node.classList.toggle("is-placed", !!target && selected !== item.id);
                node.textContent = item.text + (target ? "  →  " + target.match : "");
            });
            data.items.forEach(function (target) {
                var used = data.items.some(function (item) { return answers[item.id] === String(target.id); });
                rightButtons[target.id].classList.toggle("is-placed", used);
            });
            setProgress(count(answers));
        }
        shuffled(data.items).forEach(function (item) {
            leftButtons[item.id] = button(item.text, function () { selected = item.id; refresh(); announce("Now choose the match for: " + item.text); });
            left.appendChild(leftButtons[item.id]);
        });
        shuffled(data.items).forEach(function (target) {
            rightButtons[target.id] = button(target.match, function () {
                if (selected === null) { announce("Select an item on the left first."); return; }
                // Each match can be used once; choosing it again moves it to the new item.
                data.items.forEach(function (item) { if (answers[item.id] === String(target.id)) delete answers[item.id]; });
                answers[selected] = String(target.id); selected = null; refresh();
                announce(count(answers) === data.items.length ? "Every item is matched. Check your pairs, then submit." : count(answers) + " of " + data.items.length + " matched.");
            });
            right.appendChild(rightButtons[target.id]);
        });
        refresh();
    }

    // ---------- 2. Memory: one move is the second card of a two-card turn ----------
    function memory() {
        announce("Turn over two cards to find a matching pair. Each pair of flips counts as one move.");
        var grid = element("div", null, "memory-board"); board.appendChild(grid);
        var cards = [], first = null, busy = false, matched = 0;
        data.items.forEach(function (item) {
            cards.push({ pair: item.id, text: item.text });
            cards.push({ pair: item.id, text: item.match });
        });
        function update() { setProgress(matched, matched + " of " + data.items.length + " pairs, " + moves + " moves"); progressBar.max = data.items.length; }
        shuffled(cards).forEach(function (card, index) {
            var faceDown = "Card " + (index + 1);
            var node = button(faceDown, function () {
                if (busy || node.disabled || (first && first.node === node)) return;
                node.textContent = card.text; node.classList.add("is-flipped");
                node.setAttribute("aria-label", "Card " + (index + 1) + ": " + card.text);
                if (!first) { first = { card: card, node: node }; announce("First card: " + card.text + ". Choose a second card."); return; }
                moves++;
                var previous = first; first = null;
                if (previous.card.pair === card.pair) {
                    matched++; previous.node.disabled = true; node.disabled = true;
                    previous.node.classList.add("is-matched"); node.classList.add("is-matched");
                    memoryComplete = matched === data.items.length;
                    announce(memoryComplete ? "All pairs found in " + moves + " moves. Submit your result." : "A pair! Keep going.", "good");
                } else {
                    busy = true; announce("Not a pair. Remember where they are.", "bad");
                    window.setTimeout(function () {
                        [previous.node, node].forEach(function (n) { n.classList.remove("is-flipped"); n.removeAttribute("aria-label"); });
                        previous.node.textContent = previous.node.getAttribute("data-label");
                        node.textContent = faceDown; busy = false;
                    }, 1100);
                }
                update();
            }, "game-button memory-card");
            node.setAttribute("data-label", faceDown);
            grid.appendChild(node);
        });
        update();
    }

    // ---------- 3. Word scramble: shuffled letters, a hint and a typed answer ----------
    function scramble() {
        announce("Unscramble each word using its hint. Type letters only.");
        shuffled(data.items).forEach(function (item, index) {
            var letters = shuffled(item.text.toUpperCase().split(""));
            if (letters.join("") === item.text.toUpperCase() && letters.length > 1) letters.push(letters.shift());
            var card = element("div", null, "scramble-card");
            var label = element("label", "Word " + (index + 1) + ": " + item.match);
            label.htmlFor = "word_" + item.id;
            var tiles = element("div", null, "scramble-letters");
            tiles.setAttribute("aria-label", "Letters: " + letters.join(" "));
            letters.forEach(function (letter) { tiles.appendChild(element("span", letter)); });
            var input = document.createElement("input");
            input.type = "text"; input.id = label.htmlFor; input.maxLength = 15; input.autocomplete = "off"; input.spellcheck = false;
            input.addEventListener("input", function () {
                if (input.value.trim()) answers[item.id] = input.value.trim(); else delete answers[item.id];
                setProgress(count(answers));
            });
            card.appendChild(label); card.appendChild(tiles); card.appendChild(input); board.appendChild(card);
        });
        setProgress(0);
    }

    // ---------- 4. Sort: select an item, then its group ----------
    function sort() {
        announce("Select an item, then choose the group it belongs to. You can move items before submitting.");
        var layout = element("div", null, "game-columns"); board.appendChild(layout);
        var items = section("Items", layout), groups = section("Groups", layout);
        var selected = null, itemButtons = {}, lists = {};
        function refresh() {
            data.items.forEach(function (item) {
                var group = data.groups.filter(function (g) { return String(g.id) === answers[item.id]; })[0];
                var node = itemButtons[item.id];
                node.textContent = item.text + (group ? "  →  " + group.name : "");
                node.setAttribute("aria-pressed", String(selected === item.id));
                node.classList.toggle("is-selected", selected === item.id);
                node.classList.toggle("is-placed", !!group && selected !== item.id);
            });
            data.groups.forEach(function (group) {
                var list = lists[group.id]; list.textContent = ""; var placed = 0;
                data.items.forEach(function (item) { if (answers[item.id] === String(group.id)) { list.appendChild(element("li", item.text)); placed++; } });
                if (!placed) list.appendChild(element("li", "Nothing here yet"));
            });
            setProgress(count(answers));
        }
        shuffled(data.items).forEach(function (item) {
            itemButtons[item.id] = button(item.text, function () { selected = item.id; refresh(); announce("Where does this belong: " + item.text + "?"); });
            items.appendChild(itemButtons[item.id]);
        });
        data.groups.forEach(function (group) {
            var card = element("div", null, "sort-group");
            card.appendChild(button("Put in: " + group.name, function () {
                if (selected === null) { announce("Select an item first."); return; }
                answers[selected] = String(group.id); selected = null; refresh();
                announce(count(answers) + " of " + data.items.length + " sorted.");
            }));
            lists[group.id] = element("ul"); card.appendChild(lists[group.id]); groups.appendChild(card);
        });
        refresh();
    }

    // ---------- 5. Flashcards: recall, flip, then rate yourself honestly ----------
    function flashcards() {
        var order = shuffled(data.items), index = 0;
        var stage = element("div", null, "flashcard-stage"); board.appendChild(stage);
        var card = element("button", null, "flashcard"); card.type = "button";
        var inner = element("span", null, "flashcard-inner");
        var front = element("span", null, "flashcard-face"), back = element("span", null, "flashcard-face flashcard-back");
        inner.appendChild(front); inner.appendChild(back); card.appendChild(inner); stage.appendChild(card);
        var rate = element("div", null, "actions"); stage.appendChild(rate);
        var knew = button("I knew it", function () { record("known"); }, "button");
        var learning = button("Still learning", function () { record("learning"); }, "button secondary");
        rate.appendChild(learning); rate.appendChild(knew);
        function show() {
            var item = order[index];
            card.classList.remove("is-flipped");
            front.textContent = ""; back.textContent = "";
            front.appendChild(element("small", "Card " + (index + 1) + " of " + order.length)); front.appendChild(document.createTextNode(item.text));
            back.appendChild(element("small", "Answer")); back.appendChild(document.createTextNode(item.match));
            card.setAttribute("aria-label", "Card " + (index + 1) + ": " + item.text + ". Select to flip.");
            rate.hidden = true;
            announce("Think of the answer, then flip the card.");
        }
        card.addEventListener("click", function () {
            if (finished) return;
            card.classList.toggle("is-flipped");
            var flipped = card.classList.contains("is-flipped");
            card.setAttribute("aria-label", flipped ? "Answer: " + order[index].match + ". Select to flip back." : "Card: " + order[index].text);
            if (flipped) { rate.hidden = false; announce("Did you know it? Rate yourself to move on."); }
        });
        function record(value) {
            answers[order[index].id] = value; index++;
            setProgress(count(answers));
            if (index < order.length) { show(); card.focus(); return; }
            finished = true; rate.hidden = true; card.disabled = true;
            var known = Object.keys(answers).filter(function (k) { return answers[k] === "known"; }).length;
            announce("Deck finished. You knew " + known + " of " + order.length + " cards. Submit to save, or play again later to review the rest.", "good");
        }
        setProgress(0); show();
    }

    // ---------- 6. Fill in the blank: type the missing word in each sentence ----------
    function fillBlank() {
        announce("Type the missing word or phrase in each sentence. Spelling counts; capital letters do not.");
        data.items.forEach(function (item, index) {
            var card = element("div", null, "blank-card");
            var parts = item.match.split("___");
            var label = element("label");
            label.htmlFor = "blank_" + item.id;
            label.appendChild(document.createTextNode((index + 1) + ". " + parts[0] + "_____" + (parts[1] || "")));
            var input = document.createElement("input");
            input.type = "text"; input.id = label.htmlFor; input.maxLength = 100; input.autocomplete = "off";
            input.addEventListener("input", function () {
                if (input.value.trim()) answers[item.id] = input.value.trim(); else delete answers[item.id];
                setProgress(count(answers));
            });
            card.appendChild(label); card.appendChild(input); board.appendChild(card);
        });
        setProgress(0);
    }

    // ---------- 7. True or false speed round: a few seconds per statement ----------
    function trueFalse() {
        var order = shuffled(data.items), index = 0, streak = 0, best = 0, right = 0, timer = null, deadline = 0;
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
            text.textContent = order[index].match;
            yes.disabled = no.disabled = false;
            setProgress(index, "Statement " + (index + 1) + " of " + order.length + ", streak " + streak);
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
            if (value === item.text) { right++; streak++; best = Math.max(best, streak); announce("Correct!" + (streak > 1 ? " " + streak + " in a row." : ""), "good"); }
            else { streak = 0; announce((value === "Skip" ? "Time is up. " : "Not quite. ") + "That statement is " + item.text.toLowerCase() + ".", "bad"); }
            index++;
            setProgress(index, "Statement " + Math.min(index + 1, order.length) + " of " + order.length + ", streak " + streak);
            window.setTimeout(function () {
                if (index < order.length) { show(); return; }
                finished = true; text.textContent = "Round complete: " + right + " of " + order.length + " correct. Best streak: " + best + ".";
                choices.hidden = true; bar.hidden = true;
                announce("Submit your result to save it.", "good");
            }, 1400);
        }
        announce("Decide quickly: is each statement true or false? You have " + SECONDS + " seconds for each one.");
        show();
    }

    // ---------- 8. Put in order: move steps up and down ----------
    function sequence() {
        announce("Use the arrow buttons to move each step until the list is in the correct order.");
        var order = shuffled(data.items);
        var list = element("ol", null, "sequence-list"); board.appendChild(list);
        function render(focusId, direction) {
            list.textContent = "";
            order.forEach(function (item, position) {
                var row = element("li");
                row.appendChild(element("span", item.text));
                var move = element("span", null, "move");
                var up = button("↑", function () { swap(position, position - 1, item.id, "up"); }, "small");
                var down = button("↓", function () { swap(position, position + 1, item.id, "down"); }, "small");
                up.setAttribute("aria-label", "Move up: " + item.text); down.setAttribute("aria-label", "Move down: " + item.text);
                up.disabled = position === 0; down.disabled = position === order.length - 1;
                move.appendChild(up); move.appendChild(down); row.appendChild(move); list.appendChild(row);
                if (item.id === focusId) (direction === "up" && !up.disabled ? up : !down.disabled ? down : up).focus();
            });
            order.forEach(function (item, position) { answers[item.id] = String(position + 1); });
            setProgress(order.length, "Step order set");
        }
        function swap(from, to, id, direction) {
            if (to < 0 || to >= order.length) return;
            var value = order[from]; order[from] = order[to]; order[to] = value;
            render(id, direction);
            announce("Moved " + value.text + " to position " + (to + 1) + ".");
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
                if (!memoryComplete) { announce("Find all the pairs before you submit.", "bad"); return false; }
                result.moves = moves;
            } else {
                for (var i = 0; i < data.items.length; i++) {
                    var item = data.items[i], value = answers[item.id];
                    if (!value) { announce(data.template === "TrueFalse" || data.template === "Flashcards" ? "Finish the round before you submit." : "Complete every item before you submit.", "bad"); return false; }
                    if (data.template === "Scramble" && !/^[A-Za-z]{3,15}$/.test(value)) { announce("Each scramble answer must be 3 to 15 letters, with no spaces or numbers.", "bad"); return false; }
                    result.answers.push({ itemId: item.id, value: value });
                }
            }
            document.getElementById("hfResult").value = JSON.stringify(result);
            return true;
        }
    };
}());
