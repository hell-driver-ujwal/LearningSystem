# Inkwell: a web-based learning system

Inkwell is an ASP.NET Web Forms learning platform built for the APU module CT050-3-2 Web Applications. Learners browse a catalogue of short courses, enrol, study lessons and practise with quizzes, eight kinds of learning game, code labs, self-assessments, discussions and branching scenarios. Lecturers build and publish courses; the administrator manages accounts, subjects, content, messages, payments and analytics, and can also author courses.

## Technology

| Area | Used |
| --- | --- |
| Framework | ASP.NET Web Forms, .NET Framework 4.8, C# code-behind |
| Database | SQL Server LocalDB, `App_Data/LearningSystem.mdf`, built by `Database/CreateDatabase.sql` |
| Data access | ADO.NET with parameterised `SqlCommand` (no ORM) |
| Sign-in | Forms Authentication with roles in the ticket; PBKDF2 password hashes |
| Front end | HTML5, one external stylesheet (`Styles/site.css`), plain JavaScript in `Scripts/` |
| Fonts | Source Serif 4, Source Sans 3 and Source Code Pro, bundled in `Fonts/` (SIL Open Font Licence) |
| Payments | eSewa sandbox (test mode only) |

No CSS framework, JavaScript library or CDN is used, so the site works without internet access (except eSewa checkout and optional YouTube lessons).

## Run it locally

1. Open `LearningSystem.slnx` in Visual Studio 2022 or later and restore NuGet packages (only the Roslyn compiler package is used).
2. Build the database (see `Database/README.md` for details):
   ```bat
   if not exist App_Data mkdir App_Data
   sqlcmd -S "(LocalDB)\MSSQLLocalDB" -E -b -l 30 -i Database\CreateDatabase.sql -v DataPath="%CD%\App_Data"
   ```
3. Press F5. The site opens at `https://localhost:44393/` (plain HTTP requests are redirected to HTTPS).

Demo accounts (password `Password123` for all):

| Role | Email |
| --- | --- |
| Administrator | admin@inkwell.test |
| Lecturer | asha.sharma@inkwell.test (also daniel.tan, maya.rai, rohan.karki, elena.costa, bikash.thapa) |
| Learner | anita.karki@inkwell.test (also ben.lee, chandra.gurung, dina.wong) |
| Pending lecturer | ravi.thapa@inkwell.test (cannot log in until approved) |

## Folder structure

| Folder | Contents |
| --- | --- |
| `/` (root) | Public pages: Home, Courses, CourseDetails, Preview, About, Help, Contact, SiteMap, Privacy, Terms, error pages, `Site.Master`, `Media.ashx` |
| `Account/` | Log in (learner, lecturer, admin), register, log out |
| `Learner/` | Dashboard, my courses, course home, results, bookmarks, payments, certificate, checkout |
| `Member/` | Pages for any signed-in user: lesson, quiz, games, scenario, self-assessment, discussion, profile, password |
| `Teacher/` | Course builder and editors (used by lecturers and by the admin for courses they author) |
| `Admin/` | Users, lecturer applications, subjects, course and activity oversight, messages, FAQs, payments, analytics |
| `Payment/` | eSewa success and failure returns |
| `Helpers/` | Shared C# classes (database, security, progress, games, uploads, presentation) |
| `Styles/`, `Scripts/`, `Fonts/` | CSS, JavaScript and bundled fonts |
| `Assets/` | Site images, icons and the home page video |
| `Uploads/` | Course media with GUID file names, served only through `Media.ashx` |
| `Database/` | Rebuild script, hash generator and instructions |
| `docs/` | Blueprint, contracts, decisions, progress, verification reports |

## Assignment requirements map

| Requirement | Where to see it |
| --- | --- |
| Interlinked pages and navigation | Header menu, role workspace bar, breadcrumbs, footer, Site map, lesson next/previous |
| HTML5 elements | `header`, `nav`, `main`, `section`, `article`, `aside`, `figure`, `video`, `audio`, `track`, `progress`, `details`, `summary`, `canvas`, input types email/number/search/url/password |
| External, internal and inline CSS | `Styles/site.css`; the `<style>` block in `Site.Master`; the commented `style=""` on the home page |
| Database CRUD | Courses, topics, lessons, activities, users, subjects, FAQs, reviews, posts, bookmarks (create, list, edit, delete) |
| Registration, member and admin modules | `Account/Register.aspx`, `Learner/`, `Member/`, `Teacher/`, `Admin/` |
| Form validation | ASP.NET validators on every form plus server-side checks in each save handler |
| Multimedia | Course covers, diagrams, PDF handouts, narrated audio, captioned video, code labs, games |

See `docs/DECISIONS.md` for every change agreed after the blueprint, and `docs/PROGRESS.md` for the feature checklist.
