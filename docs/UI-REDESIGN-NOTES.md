# UI redesign notes (2 October 2026)

A visual redesign only. No features, database objects, query strings, validators, event handlers or server-control IDs were added, removed or renamed.

## Inspiration taken from the reference image

The team supplied a pastel dashboard mock-up (a music app) as a style reference. We took its visual language, not its content:

- Soft lavender, cream, pink, butter, sky and mint surfaces with dark, readable text.
- Large rounded corners, pill-shaped buttons and search bar, gentle layered shadows.
- A strong left sidebar with icon and label links and a white "pill" for the current page.
- A large rounded banner at the top of each dashboard, then pastel one-number stat cards.
- A wide rounded call-to-action strip at the bottom of dashboards.

Left out on purpose: cartoon characters, music content, fake media controls, invented numbers or trends, and notification badges that the system does not support. Only real counts (pending applications, unread messages) show a badge, as before.

## Major visual changes

| Area | Change |
| --- | --- |
| App shell | Signed-in users get a left sidebar (logo, "Hi, name" card, workspace links with icons, a help card linking to Help). The top bar keeps the main links, pill search and the profile chip. Public visitors keep the top-bar browsing layout. |
| Lesson and activity pages (`Member/`) | The sidebar shrinks to a slim icon rail so lessons, quizzes, games and scenarios keep their width. Labels stay available to screen readers and as tooltips. |
| Phones and tablets (960px and below) | The sidebar becomes a scrollable row of pill links under the top bar; the menu button still opens the main navigation. |
| Dashboards | The page header becomes a soft gradient banner with a decorative study-desk picture (books, plant, certificate). Stat cards use rotating pastel colours with an icon badge. A closing call-to-action strip links to an existing page (Courses, Results or Analytics). |
| Course cards and subject tiles | Inset rounded cover image, pill subject and price tags, pastel subject tiles. |
| Tables | Card-like container, rounded lavender header row, more row spacing, horizontal scrolling kept. |
| Forms | Rounded inputs, pill search fields, softer focus glow; validation messages and summaries keep their red styling. |
| Activities | Pastel start and result panels, pill meta chips, rounded quiz options, rating scale and game pieces. The code lab keeps its dark editor for code readability. |
| Auth, status and legal pages | Pastel side panels, gradient status panel, lavender table of contents. |
| Footer | Soft lavender footer with rounded top corners. |
| Charts | `Scripts/charts.js` draws rounded bars in the pastel palette; values and the data table are unchanged. |

## Shared style system (`Styles/site.css`)

- **Tokens on `:root`:** text (`--ink`, `--ink-soft`, `--muted`), surfaces (`--bg`, `--paper`, `--card`, `--line`), brand (`--primary`, `--primary-dark`, `--primary-tint`, `--primary-soft`), pastels (`--lavender`, `--pink`, `--butter`, `--sky`, `--mint`, `--peach`), status colours, radii (`--radius-sm` to `--radius-xl`, `--pill`), shadows (`--shadow`, `--shadow-lift`, `--shadow-inset`), gradients (`--hero-gradient`, `--sidebar-gradient`), spacing (`--space-1` to `--space-5`) and `--sidebar-width`.
- **New classes:** `.app-sidebar`, `.sidebar-logo`, `.sidebar-user`, `.sidebar-card`, `.nav-label`, `.hero-banner`, `.icon-badge`, `.cta-band.slim`, `.surface`; body classes `public`, `has-sidebar` and `is-rail`.
- All existing class names were kept, so every page picked up the new look without markup changes.
- All text colour pairs were checked against WCAG AA (4.5:1 or higher). Focus outlines stay at 3px.

## Code changes outside the stylesheet (presentation only)

- `Site.Master`: body class; workspace panel moved out of the header into the sidebar (same `pnlWorkspace` and `phWorkspace` IDs); one new icon (`i-wallet`).
- `Site.Master.cs`: `BodyClass`, `SidebarFirstName`, `SidebarInitial` and `SidebarRole` properties; `AddLink` takes an optional icon name for sidebar links. Navigation rules, role checks and badge counts are unchanged.
- `Learner/`, `Teacher/` and `Admin/Dashboard.aspx`: `hero-banner` class on the page header and a call-to-action strip with an existing link.
- `Error.aspx`, `AccessDenied.aspx`, `NotFound.aspx`: illustration colours.
- New asset `Assets/images/study-desk.svg` (added to the project file).
- The logo, favicon and web manifest keep the original Inkwell brand colours.

## Still worth a manual look

- Long admin navigation: on screens shorter than about 920px the help card at the bottom of the sidebar needs a small scroll inside the sidebar.
- Builder and editor forms (QuizBuilder, GameBuilder, ScenarioBuilder, MaterialEdit) use the shared form styles and were only spot-checked; check long forms for spacing.
- Certificate printing: print styles hide the sidebar; print one certificate to confirm.
- The eSewa demo screens keep eSewa green on purpose so the payment step is recognisable.
