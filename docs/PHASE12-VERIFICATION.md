# Phase 12 — Optional Tier A verification

Completed 30 September 2026. Q34 recorded as resolved in CONTRACTS.md, DECISIONS.md and QUESTIONS.md. Phase 13 not started.

## Implementation / feature IDs

- CHT-01/02: local canvas/JavaScript horizontal bar charts; Teacher Results groups existing filtered Quiz/Game attempts into five score bands per activity; Admin Dashboard reuses existing users-by-role and courses-by-subject tables. HTML data tables provide an accessible alternative. No confidence/outcome conversion or external libraries.
- LCK-01/02/03: transactional account-row failure count, five failures/15-minute UTC lock, rounded-up remaining minutes, automatic expiry and successful-login reset; admin unlock for non-admin rows with server predicates. Admin lock is temporary, never permanent.
- FPC-01/02: admin create/reset sets flag. Global database check on every authenticated application request catches existing sessions and Media.ashx; Q34 exceptions only. Correct current password, valid different new password and active account required; password and flag change in one UPDATE. Forced Cancel becomes Log out.
- MAP-01: public/current-role entry links and working footer Site Map link. ID-specific pages are reached via authorized courses, not fabricated links.
- CAP-01: Register session arithmetic CAPTCHA, RFV/integer/custom server validators, approved renewal/preservation/consumption rules. Contact integration remains Phase 13.
- SSL-01: fixed configured local-demo origin https://localhost:44393/, HTTP path/query redirect, secure Forms Authentication and session cookies. Existing IIS Express configuration/certificate used successfully; no machine security changes.

## Files created

- Helpers/AccountSecurityHelper.cs
- Helpers/CaptchaHelper.cs
- Helpers/ChartHelper.cs
- Scripts/charts.js
- SiteMap.aspx, SiteMap.aspx.cs, SiteMap.aspx.designer.cs
- docs/PHASE12-VERIFICATION.md, docs/phase12-charts.png

## Files changed

- Global.asax.cs, Web.config, LearningSystem.csproj, Styles/site.css
- Account/Login.aspx.cs
- Account/Register.aspx, Register.aspx.cs, Register.aspx.designer.cs
- Member/ChangePassword.aspx.cs
- Admin/UserEdit.aspx.cs, Users.aspx, Users.aspx.cs
- Admin/Dashboard.aspx, Dashboard.aspx.cs, Dashboard.aspx.designer.cs
- Teacher/Results.aspx, Results.aspx.cs, Results.aspx.designer.cs
- docs/CONTRACTS.md, DECISIONS.md, QUESTIONS.md, PROGRESS.md, EVIDENCE.md

No database/schema changes. Existing FailedLoginCount, LockedUntil and MustChangePassword columns used. No database rebuild or separate test application/database.

## Build

Visual Studio 18 MSBuild: LearningSystem.slnx /t:Build /p:Configuration=Debug /v:minimal /nologo. Succeeded, exit 0, no reported warnings/errors. One build after main implementation; only documentation/evidence inclusion followed.

## Minimal checks actually performed

1. Account-lock HTTP smoke using one uniquely named temporary learner: five wrong passwords saved count=5 and displayed lock message. Expired that fixture's LockedUntil timestamp to check expiry without waiting 15 minutes. Correct login then reset count=0. Did not run an exhaustive timing/concurrency matrix.
2. Same fixture's flagged login redirected to ChangePassword. Media.ashx redirected too. Correct current/different new password succeeded, redirected to Profile and cleared flag in the database. Setting the flag again while authenticated redirected the next dashboard request, confirming no stale session-only enforcement. Fixture deleted after test; no learning/content records created or altered.
3. Browser login as existing demo admin: both charts rendered visually with counts matching the already-displayed tables (users 1 Admin/8 Learner/6 Teacher; courses 1 Business/2 IT/2 Science). Screenshot saved as phase12-charts.png. Teacher chart code shares rendering and reuses the ownership-filtered data; not a second runtime chart matrix.
4. Visitor SiteMap showed only public/account links; Register displayed the arithmetic prompt/input without expected answer. HTTPS loaded with the existing certificate. HTTP /SiteMap.aspx?phase12=1 returned 302 to https://localhost:44393/SiteMap.aspx?phase12=1. HTTP test verified authentication and session cookies Secure. CAPTCHA lifecycle checked in code; no additional registration matrix.

IIS Express started once with existing project-local applicationhost.config and stopped after checks. No trust/certificate installation, security relaxation or machine-wide IIS changes.

## Manual follow-up steps

- Use disposable accounts: five incorrect logins should lock; correct password while locked should remain blocked. After 15 minutes login should work; Admin Users Unlock should clear both fields. Admin rows must reject crafted Unlock requests.
- Admin create/reset a disposable user's temporary password. Sign in, try dashboard/public pages and a protected media URL: all must redirect until changed. Wrong current password or unchanged new password must leave flag set. Repeat reset while the user is already signed in; the next request must be constrained.
- Register: submit missing/wrong/noninteger CAPTCHA, then unrelated invalid registration data with a correct answer. Confirm rejected submissions, renewal for bad CAPTCHA, preservation for unrelated errors and consumption after successful registration. Open a new Register tab to replace the session challenge.
- Teacher Results: choose an owned Quiz/Game activity and compare bands with saved scores; change course/activity filters. Another teacher's IDs must remain denied. SA/Scenario must show confidence/outcomes without fabricated scores. Open Chart data and inspect at phone width/with JavaScript disabled.
- Check SiteMap as learner/teacher/admin: only own-role entry links, no Phase 13 links. Use the footer link.
- Open the HTTP project address with a query string; confirm HTTPS destination preserves it. Use this machine's existing binding only. Other deployments must explicitly configure HttpsOrigin and their own supported HTTPS hosting.

## Limitations

The runtime smoke intentionally covers representative flows, not every failure branch. Actual 15-minute waiting and manual Unlock were left for the team; automatic expiry was checked by expiring only the synthetic fixture. No known blocking Tier A issue remains. Prior missing real public media/contact content remains a separate existing core-content limitation. Tier B/C functionality remains deferred.