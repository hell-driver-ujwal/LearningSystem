# Phase 15 payment setup

This application supports **eSewa Sandbox — Test Payment** only. Do not use production credentials, accounts, endpoints or real money.

Official integration and test account source: https://developer.esewa.com.np/pages/Epay (ePay V2 HMAC, response signature, status enquiry and Credentials & URLs). Consult this source for the current public sandbox secret and test wallet/password/token; no production credential belongs in this repository.

Web.config contains EsewaProductCode (EPAYTEST), EsewaFormUrl (rc-epay sandbox form), EsewaStatusUrl (rc sandbox status) and the existing HttpsOrigin (https://localhost:44393/). EsewaSecretKey is deliberately empty. Create ignored local App_Data/PaymentSettings.config:

```xml
<appSettings>
  <add key="EsewaSecretKey" value="YOUR_SANDBOX_SECRET_XML_ESCAPED" />
</appSettings>
```

XML-escape ampersands in the secret. This file is not published or committed automatically; configure it on each demo workstation. Only sandbox hosts/product are accepted. HttpsOrigin is the explicitly configured application base URL, never a browser Host header. Use the existing trusted IIS Express binding/certificate; do not change machine trust or disable security. Another deployment needs its own configured HTTPS base URL.

First apply Database/Phase15PaymentUpgrade.sql to the current database using the existing app connection (see Database/README.md). Do not run the destructive rebuild to upgrade existing work.

Teacher: edit a course, choose Paid, enter NPR price and publish through the existing content checks. Student: sign in, open course, choose Buy / Enrol with eSewa, then Begin test payment. A Pending row stores the database price snapshot. The next page presents a separate signed POST form to the sandbox, with zero charges. Use only the official test wallet. Return to this application's signed success URL in the same signed-in learner browser. If login expired, sign in as that learner and retry the original return URL. Do not share the response URL.

The application verifies the response HMAC and payment identity/amount, then independently requests server status. Only COMPLETE updates Payment and inserts Enrolment in one transaction. Repeating the signed callback cannot duplicate enrolment. If unavailable, keep the return URL and retry later; no access is granted. Failure returns never enrol. Payment history is not a manual verification tool. Admin cannot mark a payment paid. A retained verified purchase allows re-enrolment without another charge.

No sandbox secret configured means payment initiation/verification is blocked with a safe message. Configuration, certificate or network failure is a runtime limitation, not a reason to use production or weaken machine settings.

Verification on 2026-10-01 reached the official sandbox login with the correct signed amount, but its reCAPTCHA displayed an Enterprise quota warning. The full test-wallet payment, signed success and server COMPLETE verification therefore remain manual; see PHASE15-VERIFICATION.md. This workstation has an ignored local override with the public UAT secret; other workstations must configure their own local file from the official test documentation.
