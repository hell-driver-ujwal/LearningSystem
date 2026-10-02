# Advanced redesign notes (2 October 2026, branch `sunil/advanced`)

This replaces the pastel look described in `UI-REDESIGN-NOTES.md` with a dark, high-contrast game-style design, adds Inky the mascot and a game layer (XP, levels, streaks, badges), and reworks the features that felt awkward. No database tables or columns changed and no scores are calculated in the browser.

## Look and feel

| Area | What changed |
| --- | --- |
| Theme | Plain, flat dark surfaces in the style of GitHub's and freeCodeCamp's dark themes (`#0d1117` page, `#151b23` cards, 1px borders). No gradients, glows or dot patterns. Green for actions, blue for links. Every text pair passes WCAG AA. |
| Type | The operating system's own interface font (Segoe UI on Windows, San Francisco on Mac), as large platforms use, in normal weights. Source Serif 4 is kept for the printed certificate and Source Code Pro for code. |
| Buttons | Flat buttons with small radii: green primary, grey secondary, red-outlined danger. |
| Role colours | A small accent per role for the active menu item: green for learners, blue for lecturers, orange for the admin (`body.role-*`). |
| Motion | Bobbing and blinking mascot, confetti, toasts, count-up numbers, card flips and shakes. Everything is switched off by `prefers-reduced-motion`. |
| Sound | Short game sounds made with the Web Audio API (no files), with a mute button in the top bar. The setting is remembered in the browser. This was optional feature O14. |

## Inky the mascot

`Helpers/MascotHelper.cs` draws Inky (a blue ink drop, matching the Inkwell logo) as inline SVG, so CSS can animate the eyes and arms. Each pose is the same body plus a face, arms and an optional prop: wave, cheer, think, read, point, sleep, oops, search, lock, trophy, fire and graduate. Inky appears in the sidebar, on dashboards, in the learning path, on the start and result screens of every activity, on the log-in pages and on the 404, 403 and error pages.

## Game layer (`Helpers/GamificationHelper.cs`)

Everything is worked out from existing records every time, like course progress. Nothing new is stored.

| Rule | Value |
| --- | --- |
| Lesson completed | 10 XP |
| Discussion joined (first post) | 15 XP per discussion |
| Self-assessment submitted | 20 XP |
| Quiz or game | half the best score, up to 50 XP |
| Scenario | best ending reached: Best 40, Acceptable 25, Poor 10 |
| Course finished (100%) | 100 XP bonus |
| Levels | level n starts at 50 x n x (n - 1) XP: 0, 100, 300, 600, 1000... with titles from Ink Drop to Legend |
| Daily goal | 3 learning items today (lessons, attempts or posts) |
| Badges | 12, for example First steps, Code crafter, Quiz whiz, Game on, Big thinker, On fire, Course champion |

The level-up celebration is shown once, when the dashboard shows a higher level than the last one seen in that browser.

## Features reworked

| Feature | Before | Now |
| --- | --- | --- |
| Course home | A plain list of items | A learning path of round nodes (done, up next, to do) with Inky pointing at the next one. Every node still opens any time. |
| Lessons | "Mark as complete" reloaded the same page | "Complete and continue" saves progress, shows +10 XP and goes straight to the next item |
| Quizzes | Every question on one long page | One question at a time with numbered steps, Back and Next, answer keys 1 to 6, and a gentle move to the next question after answering. Correct answers are still never sent to the browser. |
| Games | A "Submit" button visible before playing; tap-only sorting; tiny arrows for ordering | Save appears only when the round is finished, inside a celebration panel. Matching pairs share a colour and number, memory cards flip in 3D, scramble letters are tappable tiles, sorting supports drag and drop into buckets, ordering supports dragging, and true or false and memory build combos. |
| Results | A score ring | Inky reacts to the score, confetti for strong results, and the XP the activity is now worth |
| Scenarios | Lettered choices; plain ending box | Lettered choice cards; the ending shows Inky's reaction and the scenario XP |
| Log in | A chooser page, then a portal page | The header goes straight to the learner portal, which has Learner, Lecturer and Admin tabs |
| Learner dashboard | Stat tiles and lists | Player card (level, XP bar, streak, daily goal, badges), next quest, stats, courses, badge shelf |

## More games

38 new games, one per topic, each using a game type the topic did not have yet, so every course now mixes several kinds of game (77 games in a fresh database, up from 39). They are added by `Database/AddMoreGames.sql`, which is also run at the end of `CreateDatabase.sql`. Courses that learners had already finished got no new games, so finished courses and their certificates stay valid.

## Files

- New: `Helpers/MascotHelper.cs`, `Helpers/GamificationHelper.cs`, `Helpers/GameUiHelper.cs`, `Scripts/fx.js`, `Database/AddMoreGames.sql`.
- Rewritten: `Styles/site.css`, `Scripts/games.js`, `Scripts/quiz.js`.
- Changed markup: `Site.Master`, the learner, lecturer and admin dashboards, course home, lesson, quiz, game, scenario, log-in, register, home and error pages. `Scripts/charts.js` uses the theme's text colour.
- Server changes are presentation only, except `Lesson.aspx.cs`, which now redirects to the next item after completion.
- The home tour video was rebuilt from the dark design.

## Checks run

- MSBuild Debug: 0 errors, 0 warnings.
- All 8 game types played to the end in preview mode and scored by the server (25 checks).
- Layout with no sideways scrolling at 1366, 820 and 390 pixels on 20 pages for every role; code lab, validators, admin filter, game preview and keyboard checks (28 checks).
- Level-up shows once and closes, sound toggle, complete and continue, quiz stepping and keyboard answers, quiz preview result (12 checks). The one lesson completion made by the test was removed afterwards.
- No JavaScript errors in any run.
