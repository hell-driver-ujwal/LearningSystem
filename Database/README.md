# Inkwell database and demo data

`CreateDatabase.sql` rebuilds the whole `LearningSystem` database from scratch: it drops any existing copy, creates all 25 tables with their keys, checks and indexes, inserts the demo data, runs integrity checks and finally detaches the database so the web application can attach `App_Data\LearningSystem.mdf`.

**Running it destroys the existing database and all of its data.**

## How to run it

Prerequisites: SQL Server LocalDB (`MSSQLLocalDB`) and `sqlcmd`. Stop the website (IIS Express) and close any SSMS connections first.

From the repository root in a Developer Command Prompt (cmd.exe):

```bat
if not exist App_Data mkdir App_Data
sqlcmd -S "(LocalDB)\MSSQLLocalDB" -E -b -l 30 -i Database\CreateDatabase.sql -v DataPath="%CD%\App_Data"
```

In PowerShell, call cmd so the path with spaces is passed correctly:

```powershell
cmd /c 'sqlcmd -S "(LocalDB)\MSSQLLocalDB" -E -b -l 30 -i Database\CreateDatabase.sql -v DataPath="%CD%\App_Data"'
```

A successful run prints a summary row (12 users, 19 courses, 72 materials, 73 activities) followed by `LearningSystem detached successfully.` You can run it again at any time to reset the demo.

If LocalDB reports that the instance does not exist, create and start it once:

```bat
sqllocaldb create MSSQLLocalDB -s
```

## Demo accounts

Every account uses the password **Password123**. The `.test` email addresses are reserved for testing and never receive mail.

| Role | Name | Email | Notes |
| --- | --- | --- | --- |
| Admin | Sanjana Shrestha | admin@inkwell.test | Also authors 4 courses |
| Lecturer | Asha Sharma | asha.sharma@inkwell.test | HTML and CSS, JavaScript (paid), Digital Safety |
| Lecturer | Daniel Tan | daniel.tan@inkwell.test | Small Business, Personal Finance (paid) |
| Lecturer | Maya Rai | maya.rai@inkwell.test | Cells, Chemistry, Ecosystems (draft) |
| Lecturer | Rohan Karki | rohan.karki@inkwell.test | Algebra, Statistics (paid) |
| Lecturer | Elena Costa | elena.costa@inkwell.test | Academic Writing, Presenting |
| Lecturer | Bikash Thapa | bikash.thapa@inkwell.test | Python, AI Foundations, Network Security |
| Lecturer (pending) | Ravi Thapa | ravi.thapa@inkwell.test | Application waiting for approval |
| Learner | Anita Karki | anita.karki@inkwell.test | Most active: current learning streak and one completed course (certificate ready) |
| Learner | Ben Lee | ben.lee@inkwell.test | |
| Learner | Chandra Gurung | chandra.gurung@inkwell.test | |
| Learner | Dina Wong | dina.wong@inkwell.test | |

Lecturers use the **Lecturer log in** page, learners the **Learner log in** page and the admin the **Administrator log in** page (all linked from `Account/Login.aspx`).

Password hashes use PBKDF2 (`Rfc2898DeriveBytes`, SHA-256, 100,000 iterations, a random 16-byte salt per account, 32-byte hash) stored as `PBKDF2$100000$<salt>$<hash>`. `GenerateDemoHashes.ps1` produces hashes in exactly this format if you need new ones.

## What the demo data contains

- **8 subjects:** Programming, Cybersecurity, Artificial Intelligence, Mathematics and Data, Business, Science, English and Communication, Study Skills.
- **19 courses:** 14 written by the six lecturers (2 or 3 each) and 4 authored by the admin. "Introduction to Ecosystems" is a draft. Three courses are paid (NPR 299 to 499).
- **72 lesson materials:** formatted readings, diagrams, PDF handouts, narrated MP3 audio, captioned MP4 video and interactive code labs.
- **73 activities:** quizzes, self-assessments, discussions, branching scenarios and all eight game types (Matching, Memory, Word scramble, Sort, Flashcards, Fill in the blank, True or false, Put in order).
- **Learner journeys:** enrolments, completed lessons, quiz and game attempts (including retakes), self-assessments, scenario outcomes, discussion posts with lecturer replies, bookmarks and two completed sandbox payments.
- Activity dates are relative to the day the script is run, so dashboards and learning streaks look current.
- Reviews and page analytics start empty on purpose: they are filled by real use, not invented.

Media files live in `Uploads/` with GUID file names that match the `FilePath` and `CoverImagePath` values in the script. Keep the folder with the script when copying the project.

## Integrity checks

Before committing, the script stops with an error if any of these fail: table count, account mix (1 admin, 6 active lecturers, 1 pending, 4 learners), 4 to 5 admin-authored courses, 2 to 3 courses per lecturer, every activity type and game template published, a code lab exists, every quiz question has 2 to 6 options with exactly one correct, quiz and self-assessment answers belong to their attempt's activity, attempt fields match their activity type, learners only post in courses they are enrolled in, and paid enrolments have a completed payment.
