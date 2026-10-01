# Web-Based Learning System: Final Requirements Blueprint

CT050-3-2-WAPP Web Applications, Group Assignment

Version 1.0, confirmed 28 September 2026

*Status: single source of truth for design and development. Any change must be added to the Decisions Log (Section 19).*

Team: P1 \_\_\_\_\_\_\_\_ P2 \_\_\_\_\_\_\_\_ P3 \_\_\_\_\_\_\_\_ P4 \_\_\_\_\_\_\_\_

# 1. Project Summary

A teacher-managed, multi-subject learning platform. Teachers create courses, lessons and learning activities. Learners enrol, study and take part in those activities. Visitors can browse courses and free previews. The admin manages users, subjects and oversees all content.

| Item | Value |
| --- | --- |
| Technology | ASP.NET Web Forms (.aspx pages + C# code-behind), SQL Server database in App_Data, ADO.NET with SQL written directly, HTML5, CSS, JavaScript. Confirmed from the module slides and textbook. |
| Authentication | Forms Authentication with the team’s own login page checking the database |
| Roles | Visitor (not logged in), Learner, Teacher, Admin |
| Primary audience | **PROVISIONAL:** pre-university and foundation students across several subjects (e.g. IT, Business, Science). Confirm before writing the proposal. |
| Learning activities | Quiz, Self-Assessment, Discussion, Educational Games (4 templates), Branching Scenario (simulation) |
| Size | 182 features, 23 database tables, 50 pages + 1 master page |

## Feature count by type

| Type | Meaning | Count |
| --- | --- | --- |
| M | Mandatory: the brief directly requires it | 35 |
| E | Essential: the chosen design cannot work without it | 67 |
| C | Chosen enhancement in the core build (full-version scope) | 46 |
| Opt | Optional feature chosen in Step 19 (O1–O14), built in tiers after the core | 34 |
|  | Total | 182 |

# 2. User Roles

|  | Visitor | Learner | Teacher | Admin |
| --- | --- | --- | --- | --- |
| Login needed | No | Yes | Yes | Yes |
| Account created by | — | Self-registers (active at once) | Applies on Register page; admin approves | Seeded in the database script only |
| Can see | Home, About, Help, Contact, Site Map, catalogue, course outlines, free previews, reviews | Everything a visitor sees + full lessons and activities of enrolled courses, own results, bookmarks, certificates | Own courses and activities, results of learners in own courses, preview of own content (including drafts) | Everything |
| Can do | Browse, search, filter, register, log in, send contact message | Enrol/leave, study, mark complete, attempt activities, post/edit/delete own posts, review courses, bookmark, print certificate, edit profile | Create/edit/delete own courses, topics, materials and all activity types; publish; remove posts in own courses; view results | Manage users, approve teachers, unlock accounts, manage subjects and FAQ, read contact messages, unpublish/delete any content, remove any post or review |
| Cannot do | Attempt activities, post, enrol, review | Create official content, see others’ results, edit others’ posts | Manage users, touch other teachers’ courses, delete reviews of own courses | Author courses, edit results, create other admins, change a user’s role |

WSDM audience hierarchy for the report: Visitor is the top audience class; Registered User is its subclass and splits into Learner and Teacher; Admin is a separate class.

# 3. Modules

| \# | Module | Purpose | Main users | Owner |
| --- | --- | --- | --- | --- |
| 1 | Public | Let visitors discover courses and free content | All | P1 |
| 2 | Authentication & Account | Register, log in/out, profile, password, teacher application | All | P1 |
| 3 | Subject & Course | Organise content as Subject → Course → Topic | Admin, Teacher | P2 (subjects: P1) |
| 4 | Learning Materials | Lessons: text, image, PDF, video, audio, YouTube | Teacher, Learner | P2 |
| 5 | Enrolment & Progress | Join/leave courses, progress % | Learner, Teacher | P2 |
| 6 | Quiz | Graded multiple-choice checks, marked on the server | Teacher, Learner | P3 |
| 7 | Self-Assessment | Learner rates own confidence 1–5 | Teacher, Learner | P3 |
| 8 | Discussion | Topic discussions with one level of replies | All logged in | P3 |
| 9 | Educational Games | Matching, Memory, Word Scramble, Sort into Groups | Teacher, Learner | P4 |
| 10 | Simulation (Branching Scenario) | Step-by-step decisions leading to endings with feedback | Teacher, Learner | P4 |
| 11 | Results & Reports | Learner, teacher and admin views of outcomes | All logged in | P3 (admin stats: P1) |
| 12 | Admin | Users, applications, subjects, oversight, messages, FAQ | Admin | P1 |
| 13 | System Support | Master page, access checks, errors, uploads, helpers | All | Shared |
| 14 | Optional extras (O1–O14) | Charts, account lock, forced password change, site map, reviews, contact, bookmarks, certificate, FAQ management, dark mode, shortcuts, CAPTCHA, HTTPS, game sounds | Various | See Section 16 |

# 4. Feature List

Types: **M** mandatory, **E** essential, **C** chosen enhancement, **Opt-A/B/C** optional feature and its build tier. DB operations: C create, R read, U update, D delete.

## 4.1 Public (PUB)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| PUB-01 | Home page | All | Intro video, subjects, 6 newest published courses, activity types, Register button | R Course, Subject | M |
| PUB-02 | About page | All | Mission, objectives, how the platform works, contact details | — | E |
| PUB-03 | Browse subjects | All | Subjects with course counts | R Subject | E |
| PUB-04 | Course catalogue | All | Published courses only | R Course | M |
| PUB-05 | Search courses | All | Keyword search on title and description; published only | R Course | E |
| PUB-06 | Filter by subject | All | Show courses from one subject | R Course | E |
| PUB-07 | Course outline | All | Topics, teacher name, last updated, activity counts, Enrol button | R Course, Topic | M |
| PUB-08 | Free preview | All | Materials the teacher marked as free preview | R Material | E |
| PUB-09 | Help / FAQ page | All | Always reachable from the nav bar; content from the FAQ table (O9) | R FAQ | E |
| PUB-10 | Contact information | All | Email and address on About page and in the footer | — | E |

## 4.2 Authentication & Account (AUTH)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| AUTH-01 | Register as learner | Visitor | Active account; then Login page with success message | C User | M |
| AUTH-02 | Apply as teacher | Visitor | Pending account with a reason; Home page with pending message | C User | C |
| AUTH-03 | Log in | All | Email + password (hash compare) + status check; Forms Authentication cookie | R User | M |
| AUTH-04 | Block non-active accounts | System | Separate messages for Pending, Rejected, Deactivated (and Locked, O2) | R User | E |
| AUTH-05 | Log out | Logged in | Ends login cookie and session; back to Home | — | M |
| AUTH-06 | Role redirect | System | Own dashboard after login, or the page the user was trying to open | — | E |
| AUTH-07 | View profile | Logged in | Own details | R User | E |
| AUTH-08 | Edit profile | Logged in | Name, email (must stay unique) | U User | E |
| AUTH-09 | Change password | Logged in | Needs current password | U User | E |
| AUTH-10 | Page protection | System | Protected pages need login + correct role | R User | M |

## 4.3 Subject & Course (CRS)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| CRS-01 | Add subject | Admin | Name + description | C Subject | E |
| CRS-02 | List subjects | Admin | Management table | R Subject | E |
| CRS-03 | Edit subject | Admin |  | U Subject | E |
| CRS-04 | Delete subject | Admin | Blocked if any course uses it | D Subject | E |
| CRS-05 | Create course | Teacher | Title, subject, description, cover image; saved as draft | C Course | E |
| CRS-06 | My courses list | Teacher | Own courses with draft/published status | R Course | E |
| CRS-07 | Edit course | Teacher | Owner only | U Course | E |
| CRS-08 | Publish / unpublish | Teacher | Publish needs ≥1 topic with ≥1 published item; drafts hidden from public | U Course | E |
| CRS-09 | Delete course | Teacher | Blocked if any attempts exist (unpublish instead); deletes topics, content and files | D Course | E |
| CRS-10 | Add topic | Teacher | Title + order | C Topic | E |
| CRS-11 | Edit / reorder topic | Teacher |  | U Topic | E |
| CRS-12 | Delete topic | Teacher | Same attempt rule as CRS-09 | D Topic | E |
| CRS-13 | View all courses | Admin | Every course from every teacher | R Course | M |
| CRS-14 | Unpublish / delete any course | Admin | Oversight; same attempt rule | U/D Course | M |

## 4.4 Learning Materials (MAT)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| MAT-01 | Add text lesson | Teacher | Plain text with paragraph breaks (no HTML input) | C Material | E |
| MAT-02 | Upload image / PDF | Teacher | Type and size checked | C Material | M |
| MAT-03 | Add video / audio | Teacher | MP4 (≤25 MB), MP3 (≤10 MB) or YouTube link | C Material | M |
| MAT-04 | Edit material | Teacher | Can replace the file; old file deleted from disk | U Material | E |
| MAT-05 | Delete material | Teacher | Also deletes the stored file | D Material | E |
| MAT-06 | Mark as free preview | Teacher | Tick box | U Material | E |
| MAT-07 | View material | Enrolled learner | Full lesson page | R Material | E |
| MAT-08 | Download PDF | Enrolled learner |  | R Material | E |
| MAT-09 | Mark complete | Learner | Counts toward progress | C MaterialCompletion | C |
| MAT-10 | Alt text on images | Teacher | Required when uploading an image | C/U Material | E |

## 4.5 Enrolment & Progress (ENR)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| ENR-01 | Enrol | Learner | One click; published courses only | C Enrolment | E |
| ENR-02 | Leave course | Learner | After confirmation; past attempts are kept | D Enrolment | E |
| ENR-03 | My Courses | Learner | Enrolled courses; unpublished ones shown as Currently unavailable | R Enrolment | E |
| ENR-04 | Progress % | Learner | Calculated, never stored (definition in Section 18) | R (calculated) | C |
| ENR-05 | Learner dashboard | Learner | Courses, recent results, shortcuts | R several | E |
| ENR-06 | Enrolled learners list | Teacher | Names only (no emails) | R Enrolment | E |

## 4.6 Quiz (QZ)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| QZ-01 | Create quiz | Teacher | Title, topic, time limit, attempt limit | C Activity | M |
| QZ-02 | Add question | Teacher | Question, 2–6 options, exactly 1 correct, marks | C QuizQuestion, QuizOption | M |
| QZ-03 | Edit question | Teacher | Locked once attempts exist | U QuizQuestion, QuizOption | M |
| QZ-04 | Delete question | Teacher | Locked once attempts exist | D QuizQuestion | M |
| QZ-05 | Edit quiz settings | Teacher | Title and description always editable | U Activity | M |
| QZ-06 | Publish / unpublish | Teacher | Needs ≥1 question | U Activity | E |
| QZ-07 | Delete quiz | Teacher | Blocked if attempts exist | D Activity | M |
| QZ-08 | Quiz intro | Learner | Question count, time limit, attempts left | R Activity | E |
| QZ-09 | Take quiz | Learner | Countdown timer; start time kept in the session; correct answers never sent to the browser | R | M |
| QZ-10 | Submit + auto-mark | System | Attempt created only on submit; marked on the server; redirect to result | C Attempt, QuizAnswer | M |
| QZ-11 | Result + review | Learner | Score, right/wrong per question | R Attempt, QuizAnswer | M |
| QZ-12 | Attempt history | Learner | All past attempts, latest and best | R Attempt | E |
| QZ-13 | Quiz results | Teacher | All attempts on own quizzes | R Attempt | E |

## 4.7 Self-Assessment (SA)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| SA-01 | Create self-assessment | Teacher | Title, topic | C Activity | C |
| SA-02 | Add statement | Teacher | e.g. I can write a SELECT query | C SAStatement | C |
| SA-03 | Edit statement | Teacher | Locked once attempts exist | U SAStatement | C |
| SA-04 | Delete statement | Teacher | Locked once attempts exist | D SAStatement | C |
| SA-05 | Settings / publish | Teacher | Needs ≥1 statement | U Activity | C |
| SA-06 | Delete self-assessment | Teacher | Blocked if attempts exist | D Activity | C |
| SA-07 | Complete it | Learner | Rate every statement 1–5 | C Attempt, SAResponse | C |
| SA-08 | Feedback summary | Learner | Average + one of 3 fixed feedback levels | R | C |
| SA-09 | Past self-assessments | Learner | Compare confidence over time | R | C |
| SA-10 | Class summary | Teacher | Average rating per statement | R | C |

## 4.8 Discussion (DSC)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| DSC-01 | Create discussion | Teacher | Title, prompt, topic | C Activity | E |
| DSC-02 | Edit discussion | Teacher |  | U Activity | E |
| DSC-03 | Close / reopen | Teacher | Closed = read only | U Activity | E |
| DSC-04 | Delete discussion | Teacher | Removes its posts | D Activity | E |
| DSC-05 | View thread | Enrolled, teacher, admin | Posts with their replies | R DiscussionPost | M |
| DSC-06 | Write post | Learner, Teacher |  | C DiscussionPost | M |
| DSC-07 | Reply | Learner, Teacher | One level only | C DiscussionPost | M |
| DSC-08 | Edit own post | Author |  | U DiscussionPost | M |
| DSC-09 | Delete own post | Author |  | D DiscussionPost | M |
| DSC-10 | Remove post | Teacher | Own courses only | D DiscussionPost | E |
| DSC-11 | Remove any post | Admin | Moderation | D DiscussionPost | M |

## 4.9 Educational Games (GAM)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| GAM-01 | Create game | Teacher | Template (Matching, Memory, Scramble, Sort), title, topic | C Activity | C |
| GAM-02 | Add content items | Teacher | Pairs (Matching/Memory), word + hint (Scramble), item + group (Sort) | C GameItem | C |
| GAM-03 | Edit item | Teacher | Locked once attempts exist | U GameItem | C |
| GAM-04 | Delete item | Teacher | Locked once attempts exist | D GameItem | C |
| GAM-05 | Manage groups | Teacher | Sort template only, 2–4 groups | C/U/D GameGroup | C |
| GAM-06 | Publish / unpublish | Teacher | Minimum item counts checked | U Activity | C |
| GAM-07 | Delete game | Teacher | Blocked if attempts exist | D Activity | C |
| GAM-08 | Play Matching | Learner | Tap-to-select, tap-to-place (works on touch and keyboard) | R GameItem | C |
| GAM-09 | Play Memory | Learner | Card flip | R GameItem | C |
| GAM-10 | Play Word Scramble | Learner | Unscramble with hint | R GameItem | C |
| GAM-11 | Play Sort into Groups | Learner | Tap-to-select, tap-to-place | R GameItem, GameGroup | C |
| GAM-12 | Save score | System | Answers sent in hidden fields; server re-checks Matching, Scramble, Sort; score 0–100 + time | C Attempt | C |
| GAM-13 | Best score + history | Learner |  | R Attempt | C |
| GAM-14 | Game results | Teacher | Scores per game | R Attempt | C |

## 4.10 Simulation: Branching Scenario (SIM)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| SIM-01 | Create scenario | Teacher | Title, introduction, topic | C Activity | C |
| SIM-02 | Add step | Teacher | Text, optional image + alt text, is ending, outcome (Best/Acceptable/Poor), feedback | C SimStep | C |
| SIM-03 | Edit step | Teacher | Locked once attempts exist | U SimStep | C |
| SIM-04 | Delete step | Teacher | Blocked while choices still lead to it | D SimStep | C |
| SIM-05 | Add choice | Teacher | Choice text + step it leads to | C SimChoice | C |
| SIM-06 | Edit / delete choice | Teacher |  | U/D SimChoice | C |
| SIM-07 | Set start step | Teacher |  | U Activity | C |
| SIM-08 | Check + publish | Teacher | Start step, ≥1 ending, every non-ending step has a choice, every choice leads somewhere | U Activity | C |
| SIM-09 | Delete scenario | Teacher | Blocked if attempts exist | D Activity | C |
| SIM-10 | Play scenario | Learner | Step by step | R SimStep, SimChoice | C |
| SIM-11 | Save outcome | System | Ending reached + date | C Attempt | C |
| SIM-12 | Outcome + restart | Learner | Feedback shown | R Attempt | C |
| SIM-13 | Outcome summary | Teacher | How many reached each ending | R Attempt | C |

## 4.11 Teacher Preview (PRV), Results (RES), Admin (ADM)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| PRV-01 | Preview own content | Teacher, Admin | Materials and all activity types, including drafts | R | C |
| PRV-02 | Preview saves nothing | System | Banner shown; attempt limit ignored; no rows written | — | C |
| RES-01 | My Results | Learner | All quiz, self-assessment, game and scenario attempts | R Attempt | E |
| RES-02 | Results by activity | Teacher | Own courses only | R Attempt | E |
| RES-03 | Teacher dashboard | Teacher | Courses, learner count, recent attempts | R several | E |
| RES-04 | Admin statistics | Admin | Users by role, courses per subject, pending applications, attempts | R several | C |
| ADM-01 | Admin login | Admin | Same login page, admin role | R User | M |
| ADM-02 | List users | Admin | Filter, search; admin accounts shown with actions disabled | R User | M |
| ADM-03 | Create user | Admin | Learner or teacher only | C User | M |
| ADM-04 | Edit user | Admin | Name, email, status; role cannot change | U User | M |
| ADM-05 | Activate / deactivate | Admin | Cannot deactivate self | U User | E |
| ADM-06 | Reset password | Admin | Temporary password | U User | E |
| ADM-07 | Delete user | Admin | Learner: records removed in code. Teacher: blocked while owning courses | D User | M |
| ADM-08 | Pending applications | Admin | With reasons | R User | C |
| ADM-09 | Approve teacher | Admin | Status → Active | U User | C |
| ADM-10 | Reject teacher | Admin | Status → Rejected | U User | C |
| ADM-11 | Manage any activity | Admin | Unpublish or delete (attempt rule applies) | U/D Activity | M |

## 4.12 System Support (SYS), built by the whole team

| ID | Feature | Description | Type |
| --- | --- | --- | --- |
| SYS-01 | Master layout | Header, footer, message area; one master page for all pages | E |
| SYS-02 | Role-based nav bar | Different menu per role (Section 10) | M |
| SYS-03 | Access checks | Login + role + ownership/enrolment on every page that takes an ID | M |
| SYS-04 | Access-denied page |  | E |
| SYS-05 | Friendly error pages | Custom errors on; no technical error screens | E |
| SYS-06 | Success / error messages | One shared message area | E |
| SYS-07 | Empty-state messages | Every list | E |
| SYS-08 | File upload handling | Type/size checks, random file names, one Uploads folder, delete files with records | E |
| SYS-09 | Database connection | Connection string only in web.config | E |
| SYS-10 | Responsive CSS | External + internal + inline styles all used | M |
| SYS-11 | Delete confirmation | On every delete | E |
| SYS-12 | Demo data | Admin account + real content in 3+ subjects | E |
| SYS-13 | Breadcrumb | Built in code on pages that show database names | E |
| SYS-14 | Page necessities | Logo top-left, title + heading, footer with contact and last updated | E |
| SYS-15 | Cancel button | On every form | E |
| SYS-16 | Accessibility | Alt text, heading order, table headers and captions | E |
| SYS-17 | Folder access rules | /Learner, /Teacher, /Admin locked by role in web.config | E |
| SYS-18 | Database build script | One SQL file creates all tables + demo data | E |
| SYS-19 | Deletes in code | Deletes involving users, attempts, answers, replies, steps, bookmarks done in C# in one transaction | E |
| SYS-20 | Role setup | Global.asax attaches the saved role to each request so folder rules work. Build first. | E |

## 4.13 Optional Features (O1–O14)

| ID | Feature | User | Description | DB operation | Type |
| --- | --- | --- | --- | --- | --- |
| CHT-01 | Teacher results chart (O1) | Teacher | Plain canvas bar chart of score spread per activity, no library | R Attempt | Opt-A |
| CHT-02 | Admin statistics charts (O1) | Admin | Users by role, courses per subject | R several | Opt-A |
| LCK-01 | Count failed logins (O2) | System | Reset after a successful login | U User | Opt-A |
| LCK-02 | Lock after 5 failures (O2) | System | 15 minutes; message shows minutes left | U User | Opt-A |
| LCK-03 | Admin unlock (O2) | Admin | Button on Users page | U User | Opt-A |
| FPC-01 | Flag password change (O3) | Admin | Set on user create and password reset | U User | Opt-A |
| FPC-02 | Force change (O3) | System | Every page redirects to Change Password until done | U User | Opt-A |
| MAP-01 | Site map page (O4) | All | Public pages + own role pages; footer link | — | Opt-A |
| CAP-01 | CAPTCHA (O12) | Visitor | Self-built sum question in session, on Register and Contact | — | Opt-A |
| SSL-01 | HTTPS (O13) | System | SSL on, redirect HTTP to HTTPS, secure login cookie | — | Opt-A |
| REV-01 | Write review (O5) | Enrolled learner | Rating 1–5 + comment; one per course | C Review | Opt-B |
| REV-02 | Edit own review (O5) | Author |  | U Review | Opt-B |
| REV-03 | Delete own review (O5) | Author |  | D Review | Opt-B |
| REV-04 | Show reviews + average (O5) | All | On Course Details | R Review | Opt-B |
| REV-05 | Average on course cards (O5) | All | Catalogue and Home | R Review | Opt-B |
| REV-06 | Admin remove review (O5) | Admin | Teachers cannot delete reviews of own courses | D Review | Opt-B |
| CON-01 | Send contact message (O6) | All | Pre-filled for logged-in users; CAPTCHA | C ContactMessage | Opt-B |
| CON-02 | Admin inbox (O6) | Admin | List with unread count in nav | R ContactMessage | Opt-B |
| CON-03 | Read / mark read (O6) | Admin |  | U ContactMessage | Opt-B |
| CON-04 | Delete message (O6) | Admin |  | D ContactMessage | Opt-B |
| BMK-01 | Add bookmark (O7) | Learner | Materials only; toggle on Lesson page | C Bookmark | Opt-B |
| BMK-02 | Remove bookmark (O7) | Learner |  | D Bookmark | Opt-B |
| BMK-03 | My Bookmarks page (O7) | Learner |  | R Bookmark | Opt-B |
| CER-01 | Certificate unlock (O8) | Learner | At 100% progress | R (calculated) | Opt-B |
| CER-02 | Printable certificate (O8) | Learner | Learner, course, teacher, date; print stylesheet | R | Opt-B |
| FAQ-01 | Add FAQ (O9) | Admin | Question, answer, audience, order | C FAQ | Opt-B |
| FAQ-02 | Edit / reorder FAQ (O9) | Admin |  | U FAQ | Opt-B |
| FAQ-03 | Delete FAQ (O9) | Admin |  | D FAQ | Opt-B |
| FAQ-04 | Help reads FAQ (O9) | All | Grouped by audience, shown with details/summary | R FAQ | Opt-B |
| KEY-01 | Keyboard shortcuts (O11) | All | Alt+H, Alt+C, Alt+D, Alt+Q; listed on Help | — | Opt-B |
| DRK-01 | Theme toggle (O10) | All | CSS variables, one colour set per theme | — | Opt-C |
| DRK-02 | Remember theme (O10) | All | Browser cookie; works for visitors | — | Opt-C |
| SND-01 | Game sounds (O14) | Learner | Correct, wrong, finish; only after user action | — | Opt-C |
| SND-02 | Mute switch (O14) | Learner | Remembered in a cookie | — | Opt-C |

# 5. Pages

50 pages + 1 master page. Every page that takes an ?id= checks ownership or enrolment in code. Level: E essential, S supporting, Opt optional feature.

## 5.1 Public (root folder)

| Page | Purpose | Main components | DB | Access | Level |
| --- | --- | --- | --- | --- | --- |
| Default (Home) | First impression | Intro video, subjects, featured courses with ratings, activity types, Register button | R | Anyone | E |
| About | Mission and contact | Mission, objectives, contact details | — | Anyone | E |
| Courses | Catalogue | Search, subject filter, course cards, paging | R | Anyone | E |
| CourseDetails | Course outline | Outline, teacher, last updated, previews, reviews, Enrol button | R; C Enrolment, Review | Anyone | E |
| Preview | Free material | Material viewer | R | Anyone (preview items) | S |
| Help | FAQ | FAQ by audience, shortcut list | R FAQ | Anyone | S |
| Contact | Send a message | Contact form + CAPTCHA | C ContactMessage | Anyone | Opt |
| SiteMap | All main pages | Grouped links | — | Anyone | Opt |
| AccessDenied, NotFound, Error | Safe landing pages | Message + links | — | Anyone | S |

## 5.2 Account and Member folders

| Page | Purpose | Main components | DB | Access | Level |
| --- | --- | --- | --- | --- | --- |
| Account/Register | Learner sign-up or teacher application | Form; reason field for teachers; CAPTCHA | C User | Logged-out only | E |
| Account/Login | Log in | Email, password, status and lock messages | R/U User | Logged-out only | E |
| Account/Logout | End session | Redirects to Home | — | Logged in | E |
| Member/Profile | Own details | Form | R/U User | Any logged-in | E |
| Member/ChangePassword | Change password | Current, new, confirm | U User | Any logged-in | E |
| Member/Discussion | Thread | Posts, replies, reply box, edit/delete/remove | CRUD DiscussionPost | Enrolled, owner teacher, admin | E |
| Member/Lesson | View material | Viewer by type, Mark complete, Bookmark, Next/Previous | R Material; C Completion, Bookmark | Enrolled; owner/admin preview | E |
| Member/Quiz | Take quiz | Intro → questions + timer → Submit | C Attempt, QuizAnswer | Enrolled; owner/admin preview | E |
| Member/QuizResult | Review attempt | Score, answers marked | R | Own attempt; owner teacher; admin | E |
| Member/SelfAssessment | Rate statements | 1–5 scale, feedback after submit | C Attempt, SAResponse | Enrolled; preview | E |
| Member/PlayGame | Play a game | Game area by template, score, best score, mute | C Attempt | Enrolled; preview | E |
| Member/Scenario | Play a scenario | Step, choices, ending, feedback, Restart | C Attempt | Enrolled; preview | E |

## 5.3 Learner folder

| Page | Purpose | Main components | DB | Access | Level |
| --- | --- | --- | --- | --- | --- |
| Dashboard | Overview | Courses, recent results, shortcuts | R | Learner | E |
| MyCourses | Enrolled courses | Cards with progress bars, Leave, Certificate link | R/D Enrolment | Learner | E |
| CourseHome | Study hub | Topics → materials then activities, done ticks, progress bar | R | Enrolled learner | E |
| MyResults | All attempts | Filters, links to reviews, paging | R Attempt | Learner | E |
| Bookmarks | Saved materials | List, remove | R/D Bookmark | Learner | Opt |
| Certificate | Printable certificate | Certificate layout, Print button | R | Learner at 100% | Opt |

## 5.4 Teacher folder

| Page | Purpose | Main components | DB | Access | Level |
| --- | --- | --- | --- | --- | --- |
| Dashboard | Overview | Course count, learner count, recent attempts | R | Teacher | E |
| MyCourses | Course list | Status, Publish, Edit, Delete, Create | R/U/D Course | Teacher | E |
| CourseEdit | Course details | Title, subject, description, cover | C/U Course | Owner | E |
| CourseBuilder | Main work page | Topics; under each, materials and activities with Add and Preview buttons | CRUD Topic | Owner | E |
| MaterialEdit | Add/edit material | Fields by type, upload, alt text | C/U Material | Owner | E |
| QuizBuilder | Build quiz | Settings, questions, options | CRUD | Owner | E |
| SABuilder | Build self-assessment | Statements | CRUD | Owner | E |
| DiscussionEdit | Discussion settings | Title, prompt, Close/Reopen | C/U Activity | Owner | E |
| GameBuilder | Build game | Template, items, groups | CRUD | Owner | E |
| ScenarioBuilder | Build scenario | Steps, choices, start step, Check & Publish | CRUD | Owner | E |
| CourseLearners | Who is enrolled | Names list | R Enrolment | Owner | E |
| Results | Results per activity | Filters, attempts table, summaries, chart | R Attempt | Owner | E |

## 5.5 Admin folder

| Page | Purpose | Main components | DB | Access | Level |
| --- | --- | --- | --- | --- | --- |
| Dashboard | Statistics | Counts, charts, pending applications, unread messages | R | Admin | E |
| Users | Manage users | Table, filter, search, Activate/Deactivate, Unlock, Delete | R/U/D User | Admin | E |
| UserEdit | Create/edit user | Form, Reset Password | C/U User | Admin | E |
| TeacherApplications | Review applications | Pending list, Approve/Reject | U User | Admin | E |
| Subjects | Subject CRUD | Table + form on one page (CRUD demo page) | CRUD Subject | Admin | E |
| Courses | Course oversight | All courses, Unpublish/Delete | R/U/D Course | Admin | E |
| Activities | Activity oversight | Filter by type, Unpublish/Delete, link to discussions | R/U/D Activity | Admin | E |
| Messages | Contact inbox | List, read, delete | R/U/D ContactMessage | Admin | Opt |
| FAQ | FAQ management | Table + form | CRUD FAQ | Admin | Opt |

# 6. Database Requirements

Conceptual design (no SQL yet). Activities use one shared Activity table; every attempt at any activity except discussion goes into one Attempt table. PK = primary key, FK = foreign key.

| \# | Entity | Purpose | Key attributes | PK | FKs |
| --- | --- | --- | --- | --- | --- |
| 1 | User | All accounts | FullName, Email (unique), PasswordHash, Role, Status, ApplicationReason, CreatedDate; FailedLoginCount, LockedUntil (O2); MustChangePassword (O3) | UserID | — |
| 2 | Subject | Top-level grouping | SubjectName (unique), Description | SubjectID | — |
| 3 | Course | A teacher’s course | Title, Description, CoverImagePath, Status, CreatedDate, LastUpdated | CourseID | TeacherID → User; SubjectID → Subject |
| 4 | Topic | Section of a course | Title, SortOrder | TopicID | CourseID → Course |
| 5 | Material | Lesson content | Title, MaterialType, TextContent, FilePath, YouTubeURL, AltText, IsPreview, SortOrder | MaterialID | TopicID → Topic |
| 6 | MaterialCompletion | Material marked done | CompletedDate | LearnerID + MaterialID | LearnerID → User; MaterialID → Material |
| 7 | Enrolment | Learner joined course | EnrolDate | LearnerID + CourseID | LearnerID → User; CourseID → Course |
| 8 | Activity | Shared record for all activity types | ActivityType, Title, Description, Status, SortOrder, CreatedDate; TimeLimitMinutes, MaxAttempts (quiz); GameTemplate (game); IsClosed (discussion); StartStepID (scenario) | ActivityID | TopicID → Topic |
| 9 | QuizQuestion | Quiz question | QuestionText, Marks, SortOrder | QuestionID | ActivityID → Activity |
| 10 | QuizOption | Answer choice | OptionText, IsCorrect | OptionID | QuestionID → QuizQuestion |
| 11 | SAStatement | Statement to rate | StatementText, SortOrder | StatementID | ActivityID → Activity |
| 12 | DiscussionPost | Post or reply | Content, PostedDate, EditedDate | PostID | ActivityID → Activity; UserID → User; ParentPostID → DiscussionPost |
| 13 | GameGroup | Group bucket (Sort) | GroupName | GroupID | ActivityID → Activity |
| 14 | GameItem | Game content item | ItemText, MatchText | ItemID | ActivityID → Activity; GroupID → GameGroup |
| 15 | SimStep | Scenario step | StepText, ImagePath, ImageAlt, IsEnding, Outcome, Feedback | StepID | ActivityID → Activity |
| 16 | SimChoice | Choice on a step | ChoiceText | ChoiceID | FromStepID → SimStep; NextStepID → SimStep |
| 17 | Attempt | Any submitted attempt | SubmittedAt, ScorePercent, TimeTakenSeconds | AttemptID | ActivityID → Activity; LearnerID → User; EndingStepID → SimStep |
| 18 | QuizAnswer | Chosen option | — | AttemptID + QuestionID | AttemptID → Attempt; QuestionID → QuizQuestion; SelectedOptionID → QuizOption |
| 19 | SAResponse | Rating given | Rating (1–5) | AttemptID + StatementID | AttemptID → Attempt; StatementID → SAStatement |
| 20 | Review (O5) | Course review | Rating (1–5), Comment, PostedDate, EditedDate | ReviewID (LearnerID + CourseID unique) | CourseID → Course; LearnerID → User |
| 21 | ContactMessage (O6) | Contact form message | SenderName, SenderEmail, Subject, Message, SentDate, IsRead | MessageID | UserID → User (optional) |
| 22 | Bookmark (O7) | Saved material | CreatedDate | LearnerID + MaterialID | LearnerID → User; MaterialID → Material |
| 23 | FAQ (O9) | Help entry | Question, Answer, Audience, SortOrder | FAQID | — |

## 6.1 Relationships

| Relationship | Type | Note |
| --- | --- | --- |
| User (teacher) → Course | 1 to many |  |
| Subject → Course; Course → Topic; Topic → Material; Topic → Activity | 1 to many each | The content chain |
| User (learner) ↔ Course | Many to many via Enrolment |  |
| User (learner) ↔ Material | Many to many via MaterialCompletion and Bookmark |  |
| Activity → QuizQuestion → QuizOption | 1 to many each |  |
| Activity → SAStatement | 1 to many |  |
| Activity → DiscussionPost; User → DiscussionPost | 1 to many each |  |
| DiscussionPost → DiscussionPost | 1 to many (links to own table) | Replies point to the main post |
| Activity → GameGroup → GameItem | 1 to many (group link optional) |  |
| Activity → SimStep → SimChoice | 1 to many |  |
| SimChoice → SimStep (leads to) | Many to 1 | Two links to the same table |
| Activity → Attempt; User → Attempt | 1 to many each |  |
| Attempt → QuizAnswer; Attempt → SAResponse | 1 to many |  |
| User ↔ Course via Review | Many to many | One review per learner per course |

## 6.2 Delete rules

- **Automatic (cascade) delete only down the content chain:** Course → Topic → Material / Activity → that activity’s content.

- **Everything else is deleted in C# code, children first, inside one transaction (SYS-19):** users, attempts, answers, replies, scenario steps, bookmarks, completions, reviews. SQL Server refuses tables that have two delete paths to the same row.

- Before deleting records with files (materials, cover images, step images), code collects the file paths and deletes those files too.

- Deletes are blocked when attempts exist (courses, topics, activities); unpublish instead.

## 6.3 Deliberately not stored

- Progress % and certificates: calculated each time from completions, attempts and posts.

- Quiz answer correctness: looked up from the chosen option (questions are locked once attempts exist).

- Theme choice and mute setting: kept in browser cookies.

# 7. CRUD Matrix

| Entity | Create | Read | Update | Delete | Where demonstrated |
| --- | --- | --- | --- | --- | --- |
| User | Visitor (register), Admin | Self, Admin | Self (profile, password), Admin (details, status, unlock, reset) | Admin | Register, Profile, Admin Users |
| Subject | Admin | All | Admin | Admin (blocked if in use) | Admin Subjects |
| Course | Teacher | All (published), owner, Admin | Owner; Admin (unpublish) | Owner, Admin | Teacher MyCourses, Admin Courses |
| Topic | Teacher | All | Owner | Owner | CourseBuilder |
| Material | Teacher | Enrolled; visitors (preview only) | Owner | Owner | MaterialEdit, CourseBuilder |
| MaterialCompletion | Learner | Learner, Teacher | — | In code | Lesson |
| Enrolment | Learner | Learner, Teacher | — | Learner (leave) | CourseDetails, MyCourses |
| Activity + content tables | Teacher | Teacher, enrolled learners | Owner (content locked after attempts) | Owner, Admin (blocked if attempts) | Builders, Admin Activities |
| Attempt, QuizAnswer, SAResponse | Learner (on submit) | Learner (own), Teacher (own activities), Admin | Never (history record) | In code only | Play pages, MyResults, Results |
| DiscussionPost | Learner, Teacher | Enrolled, Teacher, Admin | Author | Author, course teacher, Admin | Member Discussion |
| Review (O5) | Enrolled learner | All | Author | Author, Admin | CourseDetails |
| ContactMessage (O6) | Anyone | Admin | Admin (mark read) | Admin | Contact, Admin Messages |
| Bookmark (O7) | Learner | Learner | — | Learner | Lesson, Bookmarks |
| FAQ (O9) | Admin | All | Admin | Admin | Admin FAQ, Help |

## Presentation demo: one full CRUD cycle per role

- Admin → Subjects (all four operations on one page).

- Teacher → Quiz (create, view, edit, delete a question).

- Learner → Discussion post, or Review (O5).

- Why attempts are never updated: they are a record of results; changing them would be tampering.

# 8. Authentication & Authorization

| Part | Requirement |
| --- | --- |
| Registration | Learner: Active at once, then Login page. Teacher: Pending, then Home with pending message. CAPTCHA (O12). |
| Login | Forms Authentication. Checks email, password hash, status, lock (O2), forced change (O3). |
| Logout | Ends login cookie and session; Home. |
| Session | 30-minute timeout. User ID and role available to page code. |
| Passwords | Salted hash. 8–50 characters, ≥1 letter and ≥1 number. Never displayed. |
| Role-based access | Folder rules in web.config + ownership/enrolment checks in code. |
| Status re-check | Master page re-checks status on every protected page, so deactivated users are removed at once. |
| SYS-20 (build first) | Global.asax attaches the saved role to each request. Without it, folder role rules do not work. |
| HTTPS (O13) | Redirect to HTTPS; login cookie HTTPS-only. |

## 8.1 Unauthorized access handling

| Situation | Result |
| --- | --- |
| Logged out, opens protected page | Login, then back to that page |
| Wrong role | Access Denied |
| Right role, not the owner (ID changed in URL) | Access Denied |
| Learner not enrolled opens an activity | Course Details with Enrol first message |
| Learner opens draft or unpublished item | Not Found |
| Logged-in user opens Login or Register | Own dashboard |
| User flagged for password change (O3) | Change Password until done |

## 8.2 Access-control matrix

✓ allowed · ✗ blocked · own = own records only · enrolled = enrolled courses only · preview = nothing saved

| Function / Page | Visitor | Learner | Teacher | Admin |
| --- | --- | --- | --- | --- |
| Home, About, Help, Courses, Course Details, Contact, Site Map | ✓ | ✓ | ✓ | ✓ |
| Free preview materials | ✓ | ✓ | ✓ | ✓ |
| Register / Login | ✓ | ✗ | ✗ | ✗ |
| Profile, Change Password | ✗ | own | own | own |
| Enrol / Leave | ✗ | ✓ | ✗ | ✗ |
| Learner Dashboard, My Courses, My Results, Bookmarks | ✗ | ✓ | ✗ | ✗ |
| Certificate | ✗ | own at 100% | ✗ | ✗ |
| Course Home | ✗ | enrolled | ✗ | ✗ |
| Lesson, Quiz, Self-Assessment, Game, Scenario | ✗ | enrolled | own (preview) | preview |
| Quiz Result (saved attempt) | ✗ | own | own activities | ✓ |
| Discussion: read, post, reply | ✗ | enrolled | own courses | read only |
| Discussion: edit/delete own post | ✗ | own | own | ✗ |
| Discussion: remove any post | ✗ | ✗ | own courses | ✓ |
| Write/edit/delete review | ✗ | enrolled, own | ✗ | ✗ |
| Remove any review | ✗ | ✗ | ✗ | ✓ |
| Teacher Dashboard, My Courses, Course Builder, builders | ✗ | ✗ | own | ✗ |
| Course Learners, Teacher Results | ✗ | ✗ | own courses | ✗ |
| Admin Dashboard, Users, User Edit, Applications, Unlock | ✗ | ✗ | ✗ | ✓ |
| Subjects, FAQ management, Messages | ✗ | ✗ | ✗ | ✓ |
| Unpublish/delete any course or activity | ✗ | ✗ | ✗ | ✓ |

# 9. Forms & Validation

| Short | Control | Checks |
| --- | --- | --- |
| RFV | RequiredFieldValidator | Not empty (existence check) |
| REV | RegularExpressionValidator | Format and length (validity check) |
| CV | CompareValidator | Two fields match, or data type (data type check) |
| RV | RangeValidator | Number within range (range check) |
| CuV | CustomValidator | Own rule, usually a database check |

- **Every save button checks Page.IsValid first.** Without it, the server-side check is skipped.

- A ValidationSummary shows all errors at the top of the form; each field also shows its own message.

- Use HTML5 input types via TextMode: Email, Url, Number, Password, Search, MultiLine.

## 9.1 Field rules

| Form | Field | Rule | Required | Client | Server extra |
| --- | --- | --- | --- | --- | --- |
| Register | Full name | 2–100 chars; letters, spaces, apostrophe, hyphen | Yes | RFV, REV | — |
| Register | Email | Valid format, ≤100 chars | Yes | RFV, REV | Not already used |
| Register | Password | 8–50 chars, ≥1 letter, ≥1 number | Yes | RFV, REV | — |
| Register | Confirm password | Same as password | Yes | CV | — |
| Register | Account type | Learner or Teacher | Yes | RFV | Allowed value |
| Register | Application reason | 20–500 chars | Teacher | CuV | Required only for Teacher |
| Register, Contact | CAPTCHA (O12) | Whole number | Yes | RFV, CV | Matches answer in session |
| Login | Email, Password | Not empty | Yes | RFV | Exists, hash matches, Active, not locked |
| Profile | Name, Email | As Register | Yes | RFV, REV | Email unique except own |
| Change password | Current | Not empty | Yes | RFV | Matches stored hash |
| Change password | New + Confirm | As Register; differs from current | Yes | RFV, REV, CV | Differs from current |
| Admin user | Name, Email | As Register | Yes | RFV, REV | Email unique |
| Admin user | Role | Learner/Teacher, create only | Yes | RFV | Cannot change later |
| Admin user | Status | Active/Deactivated | Yes | RFV | Cannot deactivate self or admins |
| Admin user | Temporary password | Password rules | Create/Reset | RFV, REV | Sets MustChangePassword (O3) |
| Subject | Name | 2–50 chars | Yes | RFV, REV | Unique |
| Subject | Description | ≤300 chars | No | REV | — |
| Course | Title | 5–100 chars | Yes | RFV, REV | — |
| Course | Subject | From list | Yes | RFV | Subject exists |
| Course | Description | 20–1000 chars | Yes | RFV, REV | — |
| Course | Cover image | JPG/PNG ≤2 MB | No | CuV | Type/size re-checked; random name |
| Topic | Title / Order | 3–100 chars / 1–100 | Yes | RFV, REV, RV | Course owned by teacher |
| Material | Title / Type | 3–100 chars / from list | Yes | RFV, REV | — |
| Material | Text | 20–10,000 chars | Text type | CuV | Displayed HTML-encoded |
| Material | File | Image JPG/PNG/GIF ≤2 MB; PDF ≤10 MB; MP4 ≤25 MB; MP3 ≤10 MB | File types | CuV | Type/size re-checked |
| Material | YouTube link | youtube.com/watch or youtu.be | YouTube type | REV | — |
| Material | Alt text | 5–150 chars | Image type | CuV | — |
| Quiz settings | Title / Time limit / Max attempts | 3–100 chars / 0–180 min / 0–10 | Yes | RFV, REV, RV | — |
| Quiz question | Question / Marks | 5–500 chars / 1–10 | Yes | RFV, REV, RV | Blocked if attempts exist |
| Quiz question | Options / Correct | 2–6 options, 1–200 chars, no duplicates / exactly 1 | Yes | RFV, CuV | Count, duplicates, exactly 1 |
| Self-assessment | Title / Statement | 3–100 / 5–200 chars | Yes | RFV, REV | — |
| Discussion settings | Title / Prompt | 5–100 / 10–1000 chars | Yes | RFV, REV | — |
| Discussion post | Content | 2–2000 chars | Yes | RFV, REV | Enrolled/owner; not closed; author edits |
| Game | Title / Template | 3–100 chars / one of 4 | Yes | RFV | Template fixed once items exist |
| Game | Item / Match text | 1–100 / 1–200 chars | Yes | RFV, REV | No duplicates |
| Game | Scramble word | Letters only, 3–15 | Scramble | REV | — |
| Game | Group name | 1–50 chars; 2–4 groups | Sort | RFV | Group count |
| Game | Publish check | Matching ≥4 pairs; Memory 4–12; Scramble ≥3; Sort ≥2 per group | — | — | Blocks publish |
| Scenario | Title / Intro | 3–100 / 10–1000 chars | Yes | RFV, REV | — |
| Scenario | Step text / image / alt | 10–1000 chars; image rules as Material | Text yes | RFV, REV, CuV | — |
| Scenario | Outcome + Feedback | Feedback 10–500 chars | Ending steps | CuV | — |
| Scenario | Choice text / Leads to | 2–150 chars / picked | Yes | RFV, REV | Same scenario; not same step |
| Scenario | Publish check | Start step, ≥1 ending, no step without choices | — | — | Blocks publish |
| Review (O5) | Rating / Comment | 1–5 / 10–1000 chars | Yes | RFV, RV, REV | Enrolled; one per course |
| Contact (O6) | Name / Email / Subject / Message | 2–100 / email / 3–100 / 10–2000 chars | Yes | RFV, REV | CAPTCHA |
| FAQ (O9) | Question / Answer / Audience / Order | 5–200 / 10–2000 chars / list / 1–100 | Yes | RFV, REV, RV | — |
| Quiz answers | — | Unanswered counts as wrong | — | — | Not submitted before; within time + 30 s; attempts left; server marks |
| Self-assessment answers | — | All rated 1–5 | Yes | RFV | All rated; 1–5 |
| Game result | Hidden fields | — | — | — | Answers re-checked; score 0–100 |
| Search box | Keyword | ≤50 chars | No | REV | Passed as SQL parameter |

## 9.2 Database-level rules

- Unique: User.Email, Subject.SubjectName, Review (LearnerID + CourseID).

- NOT NULL on required columns. CHECK rules: ratings 1–5; Role, Status, types from allowed lists.

- Paired primary keys on Enrolment, MaterialCompletion, Bookmark, QuizAnswer, SAResponse make duplicates impossible.

# 10. Navigation

| Role | Nav bar (left) | Nav bar (right) |
| --- | --- | --- |
| Visitor | Logo → Home · Courses · Help · About · Contact | Log in · Register · theme toggle |
| Learner | Logo · Courses · Dashboard · My Courses · My Results · Bookmarks · Help | Name · Profile · Log out · theme toggle |
| Teacher | Logo · Courses · Dashboard · My Courses · Results · Help | Name · Profile · Log out · theme toggle |
| Admin | Logo · Dashboard · Users · Applications (count) · Subjects · Courses · Activities · Messages (unread) · FAQ | Name · Profile · Log out · theme toggle |

- **Breadcrumb** on every page except Home (e.g. Home › Courses › Web Development › Topic 2 › Quiz 1), built in code where names come from the database.

- **Footer** on every page: contact email, address, last updated, links (About, Help, Contact, Site Map), copyright.

- **In-page:** Course Home lists every item; Lesson has Previous/Next; every activity has Back to Course; after submit: View Result, Try Again, Back to Course; builders have Back to Course Builder; after delete, return to the list with a message; preview has Exit preview.

## 10.1 Dead-end check

| Page | Ways out |
| --- | --- |
| AccessDenied / NotFound / Error | Home, own dashboard, browser Back |
| Login success | Return page or own dashboard |
| Logout | Home |
| Register | Login (learner) or Home (teacher) |
| Quiz Result / Scenario ending | Try Again, Back to Course, My Results |
| Certificate | Print, Back to My Courses |
| All other pages | Nav bar, breadcrumb, footer |

## 10.2 Navigation structure for the report (WSDM)

- Hierarchical overall: Home → Subject → Course → Topic → Material/Activity.

- Linear inside lessons, quizzes and scenarios.

- Network links across areas (dashboard shortcuts, results back to activities).

- One navigation track per audience class: Visitor, Learner, Teacher, Admin.

# 11. User Flows

- **F1 Visitor browsing:** Home → Courses → search/filter → Course Details → Preview → Register to enrol.

- **F2 Learner joins and studies:** Register → Login → Dashboard → Courses → Course Details → Enrol → Course Home → Lesson → Mark complete → Next.

- **F3 Quiz:** Course Home → Quiz intro → Start → answer with timer → Submit → server marks → Quiz Result → Course Home. Timer ends → auto-submit. No attempts left → Start disabled.

- **F4 Self-assessment:** Course Home → rate statements → Submit → average + feedback → compare in My Results.

- **F5 Discussion:** Course Home → Discussion → post or reply → edit/delete own. Closed → read only.

- **F6 Game:** Course Home → Play Game → play → hidden fields submitted → server checks → score + best score → Retry or back.

- **F7 Scenario:** Course Home → step → choice → … → ending → outcome saved → Restart or back.

- **F8 Teacher application:** Register (teacher) → pending message → admin approves → teacher logs in → Teacher Dashboard. Rejected → message at login.

- **F9 Teacher builds a course:** Dashboard → My Courses → Create (draft) → Course Builder → topics → materials → activities → Preview → publish items → publish course → appears in catalogue.

- **F10 Teacher monitors:** Dashboard → Results → course/activity → attempts, summaries, chart. Course Learners shows enrolment.

- **F11 Moderation:** Teacher or Admin → Discussion → Remove post. Admin → Course Details → Remove review.

- **F12 Admin manages users:** Dashboard → Users → create/edit/deactivate/unlock/reset/delete. Teacher with courses → delete blocked with reason.

- **F13 Admin reviews applications:** Dashboard (pending count) → Applications → Approve/Reject.

- **F14 Admin oversees content:** Subjects (CRUD) / Courses / Activities → unpublish or delete (blocked if attempts).

- **F15 Blocked access:** Logged out → Login → return. Wrong role → Access Denied. ID changed → Access Denied.

- **F16 Account upkeep:** Profile → edit. Change Password → current + new.

- **F17 Review (O5):** Enrolled learner → Course Details → write review → edit or delete own.

- **F18 Contact (O6):** Contact → form + CAPTCHA → sent message → Admin Messages → read → delete.

- **F19 Certificate (O8):** Complete all items → My Courses → Certificate → Print.

- **F20 Account lock (O2):** 5 wrong passwords → locked message → wait 15 minutes or admin unlocks.

- **F21 Forced password change (O3):** Admin resets password → user logs in → Change Password → continue.

# 12. Multimedia

| Where | Media | Purpose | HTML5 element |
| --- | --- | --- | --- |
| Home | Intro video with cover image | Explains the platform | video (controls, poster) |
| Home, Courses | Subject images, course covers | Fast scanning | img (alt) |
| Lesson | Images with captions | Teaching content | figure, figcaption |
| Lesson | PDF in page + download | Notes, worksheets | iframe / object |
| Lesson | MP4 video, MP3 audio | Video and listening lessons | video, audio |
| Lesson | YouTube link | Existing free videos | iframe |
| Scenario | Step image | Shows the situation | img (alt) |
| Games | Card flip, tap-to-place, sounds (O14) | The interaction is the learning | CSS animation, JavaScript, audio |
| Course Home, My Courses | Progress bars | Progress at a glance | progress |
| Quiz | Countdown | Visible time limit | progress / text |
| Results, Admin Dashboard | Bar charts (O1) | Readable results | canvas |
| Help | Expandable FAQ | Easy scanning | details, summary |

- Nothing plays sound on page load. Every image has alt text. Video/audio contain fallback text.

- Database stores file paths only. Folders: /Uploads/Images, /Uploads/Documents, /Uploads/Video, /Uploads/Audio; site media in /Assets.

- HTML5 checklist: header, nav, main, section, article, footer, figure, figcaption, video, audio, progress, canvas, details, summary; input types email, url, number, password, search.

# 13. Security & Data Integrity

## 13.1 Required

| Requirement | In practice |
| --- | --- |
| Hashed + salted passwords | C# built-in hashing; never plain text |
| Parameterized SQL everywhere | Values passed as SqlCommand / SqlDataSource parameters, never joined into SQL text |
| Forms Authentication + SYS-20 + folder rules | Section 8 |
| Ownership / enrolment checks | Every page with an ID |
| Server-side validation | Page.IsValid before every save |
| HTML-input block stays on | User text displayed encoded |
| File upload checks | Allowed types, size limits, random names, /Uploads only |
| Correct answers stay on the server | No IsCorrect in quiz page HTML or hidden fields |
| Database rules | Section 9.2 |

## 13.2 Strongly recommended

- Custom error pages on (no technical error screens).

- Uploads folder cannot run scripts.

- Login failure message does not say which part was wrong.

- Status re-check on every protected page; 30-minute session timeout.

- Transactions for quiz submission and multi-step deletes.

- Redirect after every save (no double submit on refresh).

- Deletes only by button, never by a link.

## 13.3 Optional features included

- O2 account lock, O3 forced password change, O12 CAPTCHA, O13 HTTPS.

## 13.4 Not needed

- Two-factor login, email verification, full database encryption, third-party login.

# 14. System Components & Conventions

| Component | Level | Notes |
| --- | --- | --- |
| Master page | Essential | Header, nav, breadcrumb, footer, message area |
| Shared message area | Essential | Green success, red error; same everywhere |
| Dashboards (3) | Essential | Learner, Teacher, Admin |
| Error handling | Essential | Custom pages; try/catch around database calls |
| Empty states | Essential | Every list |
| Search and filters | Essential | Catalogue; Users; Activities; Results |
| Paging | Essential | GridView paging on Users, Results, Activities, Messages |
| Responsive layout | Essential | Own external CSS + internal + inline examples, even if a template is used; print.css (O8) |
| web.config | Essential | Connection string, authentication, folder rules, upload limit (raise above 4 MB default), custom errors, session timeout |
| Shared helper code | Essential | Current user, is owner, is enrolled, progress, file upload/delete, publish checks |
| Lesson viewer | Essential | One page renders every material type |
| Database script + demo data | Essential | Shared source of truth; each person rebuilds locally |

## 14.1 Naming convention

| Item | Convention | Example |
| --- | --- | --- |
| Pages | PascalCase | CourseBuilder.aspx |
| Control IDs | Type prefix | txtEmail, btnSave, lblMessage, ddlSubject, gvUsers, rfvEmail |
| Tables and columns | Singular PascalCase | Course, CourseID |
| CSS classes | lowercase-with-hyphens | course-card |
| Uploaded files | Random unique name | Original name kept in database |
| Site images | lowercase-with-hyphens | hero-banner.jpg |

## 14.2 Folder structure

```
LearningSystem/
  Site.Master, Web.config, Global.asax
  Default.aspx, About.aspx, Courses.aspx, CourseDetails.aspx, Preview.aspx, Help.aspx,
  Contact.aspx, SiteMap.aspx, AccessDenied.aspx, NotFound.aspx, Error.aspx
  Account/   Register, Login, Logout
  Member/    Profile, ChangePassword, Discussion, Lesson, Quiz, QuizResult,
             SelfAssessment, PlayGame, Scenario
  Learner/   Dashboard, MyCourses, CourseHome, MyResults, Bookmarks, Certificate
  Teacher/   Dashboard, MyCourses, CourseEdit, CourseBuilder, MaterialEdit, QuizBuilder,
             SABuilder, DiscussionEdit, GameBuilder, ScenarioBuilder, CourseLearners, Results
  Admin/     Dashboard, Users, UserEdit, TeacherApplications, Subjects, Courses,
             Activities, Messages, FAQ
  Helpers/   shared C# classes (App_Code/ if the team uses a Web Site project)
  Styles/    site.css, print.css
  Scripts/   games.js, quiz-timer.js, charts.js, theme.js
  Assets/    Images/, Video/, Audio/        (site-owned media)
  Uploads/   Images/, Documents/, Video/, Audio/   (teacher uploads; scripts blocked)
  App_Data/  LearningSystem.mdf              (local copy only, not shared)
  Database/  CreateDatabase.sql              (tables + demo data, shared)
```

# 15. Dependencies & Build Plan

| Layer | Build | Needs |
| --- | --- | --- |
| 0 | Database script, web.config, master page, CSS, helper code, naming rules | — |
| 1 | Register, Login, Logout, SYS-20 role setup, folder rules, error/denied pages | Layer 0 |
| 2 | Admin: Subjects, Users, Teacher Applications | Seeded admin account |
| 3 | Teacher: Course → Topic → Material, publish | Subjects + approved teacher |
| 4 | Catalogue, Course Details, Enrol, Course Home, Lesson | Published courses |
| 5 | Activity table → Quiz first → Discussion → Self-Assessment → Games → Scenario, with play pages + preview | Topics + enrolment |
| 6 | Attempts → Results → Progress → Dashboards → Admin statistics | Activity modules |
| 7 | Help, accessibility pass, real content in 3+ subjects, screenshots | Everything |
| 8 | Optional Tier A → Tier B → Tier C | All core working |

## 15.1 Key dependencies

| Feature | Needs first |
| --- | --- |
| Any role-based page | SYS-20 |
| Progress %, certificate | MaterialCompletion, Attempt, DiscussionPost |
| Content lock | Attempt table |
| Delete user / teacher | SYS-19 + course ownership check |
| Teacher preview | Member folder play pages + mode logic |
| Game scoring | Agreed hidden-field answer format |
| Charts (O1) | Results and statistics data |
| CAPTCHA on Contact (O12) | Contact page (O6) |

## 15.2 Optional feature tiers and cut order

| Tier | Features | Rule |
| --- | --- | --- |
| A | O1 charts, O2 account lock, O3 forced password change, O4 site map, O12 CAPTCHA, O13 HTTPS | Start only when all 148 core features work |
| B | O5 reviews, O6 contact, O7 bookmarks, O8 certificate, O9 FAQ management, O11 shortcuts | Start only when Tier A works |
| C | O10 dark mode, O14 game sounds | Start only when Tier B works |

**If time runs short, cut in this order:** O10 → O14 → O11 → O9.

**Week 1: all four members together** build Layer 0 and agree on the Activity and Attempt tables. After that, work in parallel using demo data from the script, so nobody waits for another person’s pages.

# 16. Team Allocation

| Person | Core modules | Optional features | Approx. features |
| --- | --- | --- | --- |
| P1 | Public, Authentication, Admin, admin statistics | O1 chart code + admin charts, O2, O3, O4, O11, O12, O13 | ~42 |
| P2 | Subject & Course (teacher side), Materials, Enrolment & Progress | O5, O7, O8, O10 | ~43 |
| P3 | Quiz, Self-Assessment, Discussion, Results | O1 teacher results chart | ~38 |
| P4 | Games (4 templates), Scenario, Teacher Preview | O6, O9, O14 | ~39 |
| All | SYS-01 to SYS-20 (shared) | — | 20 |

Each person must be able to explain their own module in the presentation: its pages, SQL queries, validation, and access checks.

# 17. Traceability Matrix

| Requirement | Module | Key features | Entities | Pages | Marking evidence |
| --- | --- | --- | --- | --- | --- |
| R01 Registered + non-registered users | Public, Auth | PUB-01–10, AUTH-01–03 | User, Course | Home, Courses, CourseDetails, Preview | Requirements fulfilled |
| R02 Learning activities | Quiz, SA, Discussion, Games, Scenario | QZ, SA, DSC, GAM, SIM, PRV | Activity + children, Attempt | Member play pages, builders | Functionality & content |
| R03 Database connectivity | All | All data features | All 23 | All dynamic pages | Database implementation |
| R04 Client + server processing | System | Validators, JS games/timer, server marking | — | Forms, play pages | Forms & validation |
| R05 Multimedia | Materials, Public, Scenario | MAT-02/03, Home video, SIM-02 | Material, SimStep | Home, Lesson, Scenario | Layout, content |
| R06 Interface design | System | SYS-01/14/15/16 | — | All | Layout design |
| R07/R08 Navigation, interlinked pages | System | SYS-02/13, MAP-01 | — | Master page, all | Layout, requirements |
| R09 HTML5 elements | System | Section 12 checklist, canvas (O1) | — | All | Requirements fulfilled |
| R10 CSS | System | SYS-10, print.css (O8), theme variables (O10) | — | All | Layout; report code |
| R11 Quality content | Materials, demo data | SYS-12 | Course, Material, Activity | Catalogue, Lesson | Quality content |
| R12–R15 Insert, display, update, delete | All | Section 7 | All | Builders, lists, admin pages | All CRUD |
| R16 Registration page | Auth | AUTH-01/02 | User | Register | Authentication |
| R17 Member module | Learner, Teacher | ENR, RES, builders, REV, BMK | Enrolment, Attempt, Post, Review | Learner, Teacher, Member folders | Auth + CRUD |
| R18 Admin module | Admin | ADM, CRS-01–04/13/14, FAQ, CON | User, Subject, FAQ, ContactMessage | Admin folder | Auth + CRUD |
| R19 Form validation | All forms | Section 9, CAP-01 | DB rules | All forms | Forms & validation |
| R20 File organization + naming | System | SYS-17, Section 14 | — | Folder structure | Requirements fulfilled |
| R21 Well-designed database | Database | Section 6, SYS-19 | All 23 | — | Database implementation |
| R22 Current web standards | System | HTML5, CSS, accessibility | — | All | Layout, requirements |
| D06 Use cases, flowcharts | Report | Section 11 flows; Section 8 matrix | — | — | All diagrams |
| D07 ERD, wireframes, navigation | Report | Section 6; Section 5; Section 10 | — | — | All diagrams |
| D08 Code explanation | Report | CSS, validators + Page.IsValid, parameterized SQL, SYS-19/20 | — | — | Code snippets |

All 22 system requirements map to at least one feature, entity and page. Weakest link: R11 quality content, which depends on the team writing real content.

# 18. Rules From the Gap Check

| \# | Rule |
| --- | --- |
| 1 | All four members use the same Visual Studio project type (a .csproj file means ASP.NET Web Application). |
| 2 | A quiz attempt is created only on Submit; the start time is kept in the session. |
| 3 | Courses, topics and activities with attempts cannot be deleted; unpublish instead. |
| 4 | Once an activity has attempts, its content is locked (title and description stay editable). |
| 5 | Deleting records with files also deletes the files from disk. |
| 6 | Matching and Sort use tap-to-select, tap-to-place (no browser drag-and-drop). |
| 7 | Inside a topic: materials first, then activities, each in its own order. |
| 8 | A course can be published only with ≥1 topic holding ≥1 published item. |
| 9 | Unpublished courses show as Currently unavailable in My Courses; results stay. |
| 10 | Progress = items done ÷ published items. Material done = marked complete; quiz/self-assessment/game/scenario done = ≥1 submitted attempt; discussion done = ≥1 post. |
| 11 | Redirect after every save; server rejects duplicate submissions. |
| 12 | Admin accounts appear in Users with all actions disabled. |
| 13 | Home shows the 6 newest published courses. |
| 14 | Teachers see learner names only; only the admin sees emails. |
| 15 | Game answers may be in the page (needed to play); the server re-checks scores. |
| 16 | Search and catalogue show published items only. |
| 17 | Code shared through Git; build folders and the .mdf file excluded; the SQL script is the shared database. |

# 19. Decisions Log

| \# | Decision | Choice |
| --- | --- | --- |
| 1 | Framework | ASP.NET Web Forms + C# (from module slides) |
| 2 | Database access | SQL Server in App_Data, ADO.NET, SQL written directly (no Entity Framework) |
| 3 | Authentication | Forms Authentication |
| 4 | Scope | Full version + optional O1–O14; O15 notifications and O16 email dropped |
| 5 | Subjects and audience | Multi-subject; audience provisional (Section 21) |
| 6 | Simulation | Teacher-built branching scenario |
| 7 | Games | 4 templates: Matching, Memory, Word Scramble, Sort into Groups |
| 8 | Activity storage | One shared Activity table + one Attempt table |
| 9 | Teacher preview | Yes; nothing saved; works on drafts |
| 10 | Teacher accounts | Apply on Register page; admin approves |
| 11 | Admin role | Oversight, not authoring; no admin-created admins; roles fixed after creation |
| 12 | Courses and enrolment | One teacher per course; free one-click enrolment |
| 13 | Multimedia | Image, PDF, MP4 (≤25 MB), MP3 uploads + YouTube links |
| 14 | Text lessons | Plain text only |
| 15 | Quiz | Single-answer multiple choice, server-marked, teacher-set attempt limit (0 = unlimited), latest and best shown, 30 s grace |
| 16 | Self-assessment | 1–5 ratings, 3 fixed feedback levels |
| 17 | Discussion | One level of replies |
| 18 | Leaving a course | Past attempts kept |
| 19 | Blocked deletes | Subject in use; step with incoming choices; teacher owning courses; anything with attempts |
| 20 | Sessions | 30-minute timeout; no auto-login after register; no remember me |
| 21 | Optional features | Built in tiers A → B → C after core; cut order O10 → O14 → O11 → O9 |

# 20. Not Built: Future Enhancements

Use these in the report’s Future Enhancements section. Each was considered and left out on purpose.

| Feature | Reason left out |
| --- | --- |
| In-app notifications (O15) | Touches every module; high coordination cost |
| Email notifications (O16) | Needs an outside mail server; demo and password-leak risk |
| Live video classes | Real-time infrastructure out of scope |
| AI tutor or AI-generated quizzes | Out of scope for the module |
| Fully custom game or simulation designer | Would become a separate product |
| Multiplayer games | Real-time infrastructure |
| Badges and recommendations | Low value relative to effort |
| Mobile app | Web application is the assignment |

# 21. Open Items (resolve before coding)

| \# | Item | Action |
| --- | --- | --- |
| 1 | Primary audience | Confirm or change "pre-university and foundation students" before writing the proposal mission statement |
| 2 | Windows + Visual Studio | Confirm all four members can run Web Forms projects |
| 3 | Project type | Check lab files for a .csproj; everyone creates the same type |
