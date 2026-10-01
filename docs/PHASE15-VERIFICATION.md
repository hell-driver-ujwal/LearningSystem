# Phase 15 verification — 2026-10-01

Custom Phase 15 implementation is built. External end-to-end verification is partial; no successful real provider COMPLETE callback is claimed. Phase 14 / Tier C is DEFERRED — not completed (O10/O14 unchecked). Phase 16 Final Audit was not started.

## Build and upgrade

- MSBuild, LearningSystem.slnx, Debug: succeeded, no warnings/errors reported. Final build after the small layout adjustment also succeeded.
- Executed Database/Phase15PaymentUpgrade.sql once against the existing LocalDB MDF through its normal connection. Successful: 24 application tables. Existing data was preserved. No destructive CreateDatabase.sql rebuild, detach/reset, machine configuration or security change.
- Schema additions: Course.IsPaid BIT NOT NULL DEFAULT 0; Course.PriceNPR DECIMAL(10,2) NOT NULL DEFAULT 0; CK_Course_Price enforces free=0/paid>0. Payment has the exact ten columns/types/defaults in CONTRACTS.md, identity PK, UUID UNIQUE, positive amount/provider/status CHECKs and NO ACTION learner/course foreign keys. Existing Enrolment composite uniqueness remains unchanged.

## Checks actually performed

Temporary learner/course/payment fixtures were created for the requested smoke checks and removed transactionally afterward, including their quiz/game attempts. Existing demo records/uploads were not removed.

- Student/Learner, Teacher and Admin portal logins reached their correct dashboards.
- Correct student password at Teacher portal was rejected without incrementing FailedLoginCount.
- With a fixture set to four prior failures, one bad password produced the fifth-attempt temporary lock. Forced-password fixture login redirected to ChangePassword.
- A learner enrolled in an existing free course, creating one Enrolment and no Payment.
- Teacher CourseEdit saved NPR 1,500.00 for a paid fixture. Direct CourseDetails Enrol redirected to Checkout without creating Enrolment.
- Checkout created one Pending row with the database amount and a GUID-format UUID. The generated signature matched an independent HMAC calculation over the mandatory ordered fields.
- Malformed success response left Payment Pending.
- Current learner saw their payment; a second learner did not. Another learner's paymentId went to Access Denied. Admin saw the transaction UUID; Teacher access to Admin/Payments was denied.
- Representative existing learner quiz Start → Submit → QuizResult and game Start → Submit → saved attempt/history succeeded.
- Local idempotency/recovery check used an explicitly synthetic previously-verified Complete payment fixture. Two correctly signed callbacks restored exactly one Enrolment and did not create another Payment. This proves the already-Complete branch, not a live provider transition from Pending to Complete.
- Local browser portal and checkout pages rendered. Signed test form reached the official eSewa sandbox over HTTPS; sandbox displayed EPAYTEST and the correct NPR 100.00. Evidence: phase15-sandbox.png.

## External limitation

The eSewa sandbox login requires reCAPTCHA and displays “This site is exceeding reCAPTCHA Enterprise free quota.” Automation stopped at that page; CAPTCHA was not bypassed and no sandbox login/payment was completed. There was no real-money payment. The server status COMPLETE response, first atomic Pending→Complete transaction, and repeated callbacks after a real sandbox success remain manual. No substitute mock is presented as successful provider verification. No repeated external payment attempts or security changes were made.

The ignored local App_Data/PaymentSettings.config contains the public UAT sandbox key from eSewa's official documentation for this workstation. Tracked Web.config keeps the key empty; no production secrets were used or committed. Test-only local fixture records were removed, so start a fresh checkout for manual verification.

## Files created

Each new ASPX below has its matching .aspx.cs and .aspx.designer.cs, all included in LearningSystem.csproj:
- Account/StudentLogin.aspx
- Account/TeacherLogin.aspx
- Account/AdminLogin.aspx
- Learner/Checkout.aspx
- Learner/MyPayments.aspx
- Admin/Payments.aspx
- Payment/EsewaSuccess.aspx
- Payment/EsewaFailure.aspx

Shared helpers: Helpers/PortalLoginHelper.cs, Helpers/EsewaHelper.cs, Helpers/PaymentHelper.cs.

Database/Phase15PaymentUpgrade.sql; docs/PHASE15-CUSTOM-SCOPE.md; docs/PHASE15-PAYMENT-SETUP.md; docs/PHASE15-VERIFICATION.md; docs/phase15-portals.png; docs/phase15-sandbox.png. Local-only ignored App_Data/PaymentSettings.config is not included for publication.

## Existing files changed

AGENTS.md; docs/CONTRACTS.md; docs/DECISIONS.md; docs/PROGRESS.md; Database/CreateDatabase.sql; Database/README.md; .gitignore; LearningSystem.csproj; Web.config; Helpers/AccountSecurityHelper.cs; Helpers/CourseHelper.cs; Helpers/DeleteHelper.cs; Account/Login.aspx and both companion files; Teacher/CourseEdit.aspx and both companion files; CourseDetails.aspx.cs; Courses.aspx.cs; Default.aspx.cs; Site.Master and both companion files; SiteMap.aspx.cs; Styles/site.css.

BLUEPRINT.md was not modified. Auth remains shared; Student is presentation terminology only. Payment history blocks referenced course/user deletion; unpublish/deactivate instead. Shared progress and existing learning behavior were unchanged.

## Manual checks remaining

1. Configure the sandbox secret locally as described in PHASE15-PAYMENT-SETUP.md. Sign in with each matching portal; also try the wrong portal, a locked/non-active account and forced-change account. Confirm permitted ReturnUrl restoration and denial of other-role destinations.
2. Create a normal course with published content. Save Free and Paid prices; reject zero/negative/over-precision paid prices. Confirm existing enrolments survive price changes and public cards show Free/NPR.
3. As a student, start a paid checkout. Complete the sandbox CAPTCHA/test-wallet flow yourself using the current test-account details linked from the official guide. Confirm the signed return is validated, provider status is COMPLETE, Payment has VerifiedDate/reference and exactly one Enrolment exists.
4. Repeat the same signed success callback. Confirm no duplicate payment/enrolment. Leave the paid course, re-enrol and confirm no second charge and retained learning progress. Refresh pending checkout after a price change: its signed amount must remain the stored transaction snapshot.
5. Alter the signed callback amount/status/signature or use a different student account: no access should be granted. Try a canceled/failed checkout; it must never enrol. If status verification is unavailable, the purchase must remain non-complete.
6. Check MyPayments isolation, Admin status filtering/paging and Teacher denial. Admin must have no manual Complete/refund action. Inspect phone/tablet portal and checkout layout; no full visual matrix was run.

Stop condition reached for this phase: implementation builds and local representative checks pass; external verification limitation is recorded. Do not start Phase 16 from this report.

