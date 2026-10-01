(function () {
    "use strict";
    var root = document.getElementById("gameRoot");
    if (!root) return;
    var data = JSON.parse(root.getAttribute("data-game"));
    var began = Date.now() - Number(root.getAttribute("data-elapsed")) * 1000;
    var answers = {}, moves = 0, memoryComplete = false;
    var status = element("p", "Select an item to begin.", "game-status");
    status.setAttribute("role", "status");
    status.setAttribute("aria-live", "polite");
    root.appendChild(status);
    var clock = element("p", "Elapsed: 0 seconds", "muted");
    root.appendChild(clock);
    window.setInterval(function () { clock.textContent = "Elapsed: " + elapsed() + " seconds"; }, 1000);

    // Shared helpers: use textContent for all database text; native buttons support touch and keyboard.
    function element(tag, text, className) {
        var node = document.createElement(tag);
        if (text !== null) node.textContent = text;
        if (className) node.className = className;
        return node;
    }
    function button(text, action) {
        var node = element("button", text, "game-button");
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
    function announce(text) { status.textContent = text; }
    function section(title, container) {
        var node = element("section", null, "game-column");
        node.appendChild(element("h3", title));
        container.appendChild(node); return node;
    }

    // 1. Matching: select a left item, then select its right-side match. No drag-and-drop.
    function matching() {
        announce("Select an item, then its matching answer. Use Tab and Enter or Space, or tap/click. Select an item again to change a match.");
        var layout = element("div", null, "game-columns"); root.appendChild(layout);
        var left = section("Items", layout), right = section("Choose the match", layout);
        var selected = null, leftButtons = {}, rightButtons = {};
        function refresh() {
            data.items.forEach(function (item) {
                var node = leftButtons[item.id];
                node.setAttribute("aria-pressed", String(selected === item.id));
                node.classList.toggle("is-selected", selected === item.id);
                var target = data.items.filter(function (other) { return String(other.id) === answers[item.id]; })[0];
                node.textContent = item.text + (target ? " → " + target.match : " — not placed");
            });
            data.items.forEach(function (target) {
                var source = data.items.filter(function (item) { return answers[item.id] === String(target.id); })[0];
                rightButtons[target.id].textContent = target.match + (source ? " ← " + source.text : "");
            });
        }
        shuffled(data.items).forEach(function (item) {
            leftButtons[item.id] = button(item.text, function () { selected = item.id; refresh(); announce("Selected " + item.text + ". Choose its match."); });
            left.appendChild(leftButtons[item.id]);
        });
        shuffled(data.items).forEach(function (target) {
            rightButtons[target.id] = button(target.match, function () {
                if (selected === null) { announce("Select an item first."); return; }
                // Each right-side match can be used once; moving it frees the earlier assignment.
                data.items.forEach(function (item) { if (answers[item.id] === String(target.id)) delete answers[item.id]; });
                answers[selected] = String(target.id); selected = null; refresh();
                announce(Object.keys(answers).length + " of " + data.items.length + " items placed.");
            });
            right.appendChild(rightButtons[target.id]);
        });
        refresh();
    }

    // 2. Memory: one move is counted on the second flip of a complete two-card turn.
    function memory() {
        announce("Flip two cards to find a pair. Each two-card turn counts as one move. Finish all pairs before submitting.");
        var board = element("div", null, "memory-board"); root.appendChild(board);
        var cards = [], first = null, busy = false, matched = 0;
        data.items.forEach(function (item) {
            cards.push({ pair: item.id, text: item.text });
            cards.push({ pair: item.id, text: item.match });
        });
        shuffled(cards).forEach(function (card, index) {
            var faceDown = "Card " + (index + 1) + " — face down";
            var node = button(faceDown, function () {
                if (busy || node.disabled || (first && first.node === node)) return;
                node.textContent = card.text; node.classList.add("is-flipped");
                node.setAttribute("aria-label", "Card " + (index + 1) + ": " + card.text);
                if (!first) { first = { card: card, node: node, label: faceDown }; announce("First card: " + card.text + ". Flip a second card."); return; }
                moves++; // A first flip alone never counts.
                var previous = first; first = null;
                if (previous.card.pair === card.pair) {
                    matched++; previous.node.disabled = true; node.disabled = true;
                    previous.node.classList.add("is-matched"); node.classList.add("is-matched");
                    memoryComplete = matched === data.items.length;
                    announce("Pair found. " + matched + " of " + data.items.length + " pairs; " + moves + " moves." + (memoryComplete ? " Complete — submit your result." : ""));
                } else {
                    busy = true; announce("Not a pair. " + moves + " moves. The cards will turn back over.");
                    window.setTimeout(function () {
                        previous.node.textContent = previous.label; node.textContent = faceDown;
                        previous.node.setAttribute("aria-label", previous.label); node.setAttribute("aria-label", faceDown);
                        previous.node.classList.remove("is-flipped"); node.classList.remove("is-flipped"); busy = false;
                    }, 1100);
                }
            });
            node.classList.add("memory-card"); board.appendChild(node);
        });
    }

    // 3. Word Scramble: a shuffled word and hint, with a labelled typed answer for each item.
    function scramble() {
        announce("Unscramble every word using its hint. Type letters only, then submit.");
        shuffled(data.items).forEach(function (item) {
            var letters = shuffled(item.text.toUpperCase().split(""));
            if (letters.join("") === item.text.toUpperCase()) {
                for (var i = 1; i < letters.length; i++) {
                    if (letters[i] !== letters[0]) { var first = letters[0]; letters[0] = letters[i]; letters[i] = first; break; }
                }
            }
            var card = element("div", null, "scramble-card");
            var label = element("label", "Letters: " + letters.join(" "));
            label.htmlFor = "word_" + item.id;
            var input = document.createElement("input"); input.type = "text"; input.id = label.htmlFor;
            input.maxLength = 15; input.autocomplete = "off"; input.spellcheck = false;
            var hint = element("p", "Hint: " + item.match); hint.id = "hint_" + item.id;
            input.setAttribute("aria-describedby", hint.id);
            input.addEventListener("input", function () { answers[item.id] = input.value.trim(); });
            card.appendChild(label); card.appendChild(hint); card.appendChild(input); root.appendChild(card);
        });
    }

    // 4. Sort: select an item, then a group button. Re-select placed items to move them.
    function sort() {
        announce("Select an item, then its group. Use Tab and Enter or Space, or tap/click. You can change placements before submitting.");
        var layout = element("div", null, "game-columns"); root.appendChild(layout);
        var items = section("Items", layout), groups = section("Choose a group", layout);
        var selected = null, itemButtons = {}, lists = {};
        function refresh() {
            data.items.forEach(function (item) {
                var group = data.groups.filter(function (g) { return String(g.id) === answers[item.id]; })[0];
                var node = itemButtons[item.id]; node.textContent = item.text + (group ? " → " + group.name : " — not placed");
                node.setAttribute("aria-pressed", String(selected === item.id)); node.classList.toggle("is-selected", selected === item.id);
            });
            data.groups.forEach(function (group) {
                var list = lists[group.id]; list.textContent = ""; var count = 0;
                data.items.forEach(function (item) { if (answers[item.id] === String(group.id)) { list.appendChild(element("li", item.text)); count++; } });
                if (!count) list.appendChild(element("li", "No items placed yet."));
            });
        }
        shuffled(data.items).forEach(function (item) {
            itemButtons[item.id] = button(item.text, function () { selected = item.id; refresh(); announce("Selected " + item.text + ". Choose a group."); });
            items.appendChild(itemButtons[item.id]);
        });
        data.groups.forEach(function (group) {
            var card = element("div", null, "sort-group");
            card.appendChild(button("Place in " + group.name, function () {
                if (selected === null) { announce("Select an item first."); return; }
                answers[selected] = String(group.id); selected = null; refresh();
                announce(Object.keys(answers).length + " of " + data.items.length + " items placed.");
            }));
            lists[group.id] = element("ul", null); card.appendChild(lists[group.id]); groups.appendChild(card);
        });
        refresh();
    }

    if (data.template === "Matching") matching();
    else if (data.template === "Memory") memory();
    else if (data.template === "Scramble") scramble();
    else if (data.template === "Sort") sort();

    // Exact hfResult contract: no client score. The server validates IDs and recalculates results.
    window.learningGame = {
        prepare: function () {
            var result = { timeTakenSeconds: elapsed(), answers: [] };
            if (data.template === "Memory") {
                if (!memoryComplete) { announce("Find all pairs before submitting."); return false; }
                result.moves = moves;
            } else {
                for (var i = 0; i < data.items.length; i++) {
                    var item = data.items[i], value = answers[item.id];
                    if (!value) { announce("Complete every item before submitting."); return false; }
                    if (data.template === "Scramble" && !/^[A-Za-z]{3,15}$/.test(value)) { announce("Each answer must contain 3–15 letters only."); return false; }
                    result.answers.push({ itemId: item.id, value: value });
                }
            }
            document.getElementById("hfResult").value = JSON.stringify(result);
            return true;
        }
    };
}());
