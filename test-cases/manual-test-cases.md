# Manual Test Cases — Sample QA Work

> These test cases demonstrate my approach to structured, requirements-based testing.
> Format: Test Case ID | Description | Preconditions | Steps | Expected Result | Notes

---

## 🔐 TEST SUITE 1 — Login / Authentication Feature

---

### TC-001 | Valid Login — Happy Path

| Field | Detail |
|---|---|
| **Test Case ID** | TC-001 |
| **Feature** | User Authentication — Login |
| **Type** | Functional |
| **Priority** | High |
| **Preconditions** | User account exists and is active. Application is accessible. |

**Steps to Execute:**
1. Navigate to the login page
2. Enter a valid registered email address
3. Enter the correct password
4. Click the Login button

**Expected Result:**
- User is redirected to the dashboard
- Welcome message displays with user's name
- Session token is created (verifiable via browser DevTools → Application → Cookies)
- No error messages displayed

**Notes:** Verify session token expiry is set per system spec (e.g., 30 minutes of inactivity)

---

### TC-002 | Invalid Password — Negative Test

| Field | Detail |
|---|---|
| **Test Case ID** | TC-002 |
| **Feature** | User Authentication — Login |
| **Type** | Negative |
| **Priority** | High |
| **Preconditions** | User account exists and is active. |

**Steps to Execute:**
1. Navigate to the login page
2. Enter a valid registered email address
3. Enter an incorrect password
4. Click the Login button

**Expected Result:**
- User remains on the login page
- Error message displayed: "Invalid email or password"
- No session token created
- Password field is cleared

**Notes:** Error message must NOT specify whether email or password was wrong (security best practice)

---

### TC-003 | Empty Required Fields — Validation Test

| Field | Detail |
|---|---|
| **Test Case ID** | TC-003 |
| **Feature** | User Authentication — Login |
| **Type** | Negative / Validation |
| **Priority** | Medium |
| **Preconditions** | Application is accessible. |

**Steps to Execute:**
1. Navigate to the login page
2. Leave email field empty
3. Leave password field empty
4. Click the Login button

**Expected Result:**
- Form does not submit
- Validation message shown below email field: "Email is required"
- Validation message shown below password field: "Password is required"
- No API call made (verify in Network tab)

---

### TC-004 | SQL Injection Attempt — Security Test

| Field | Detail |
|---|---|
| **Test Case ID** | TC-004 |
| **Feature** | User Authentication — Security |
| **Type** | Security / Negative |
| **Priority** | Critical |
| **Preconditions** | Application is accessible. |

**Steps to Execute:**
1. Navigate to the login page
2. Enter `' OR '1'='1` in the email field
3. Enter any value in the password field
4. Click the Login button

**Expected Result:**
- Login fails — user is NOT authenticated
- Error message: "Invalid email or password"
- No database error exposed to the user
- Input is sanitized — no SQL execution occurs

**Notes:** Any successful login or database error message = Critical security defect. Escalate immediately.

---

### TC-005 | Boundary Value — Password Minimum Length

| Field | Detail |
|---|---|
| **Test Case ID** | TC-005 |
| **Feature** | User Authentication — Boundary |
| **Type** | Boundary Value |
| **Priority** | Medium |
| **Preconditions** | System minimum password length is 8 characters. |

**Steps to Execute:**
1. Attempt login with password exactly 8 characters
2. Attempt login with password 7 characters (one below minimum)
3. Attempt login with password 9 characters (one above minimum)

**Expected Result:**
- 8 characters → Login succeeds (if credentials valid)
- 7 characters → Validation error: "Password must be at least 8 characters"
- 9 characters → Login succeeds (if credentials valid)

---

## 🔄 TEST SUITE 2 — Regression Test Cases

---

### TC-010 | User Profile Update Does Not Break Login

| Field | Detail |
|---|---|
| **Test Case ID** | TC-010 |
| **Feature** | Regression — Profile Update → Login |
| **Type** | Regression |
| **Priority** | High |
| **Preconditions** | User is logged in. Profile update feature was recently released. |

**Steps to Execute:**
1. Log in with valid credentials
2. Navigate to Profile Settings
3. Update the display name and save
4. Log out
5. Log back in with original credentials

**Expected Result:**
- Profile update saves successfully
- User can log out and log back in without issues
- Updated display name appears after re-login
- No session or authentication errors introduced by the profile update

**Notes:** This regression test verifies that the profile update release did not break the authentication flow.

---

## 📊 TEST SUITE 3 — Data Validation Test Cases

---

### TC-020 | Record Count Validation After Data Import

| Field | Detail |
|---|---|
| **Test Case ID** | TC-020 |
| **Feature** | Data Validation — Import/Migration |
| **Type** | Data Validation |
| **Priority** | High |
| **Preconditions** | Source data file contains 500 records. Import process has completed. |

**Steps to Execute:**
1. Query source system: `SELECT COUNT(*) FROM source_table WHERE import_batch_id = 'BATCH_001'`
2. Query target system: `SELECT COUNT(*) FROM target_table WHERE import_batch_id = 'BATCH_001'`
3. Compare counts

**Expected Result:**
- Source count = 500
- Target count = 500
- Counts match exactly

**If counts don't match:**
- Identify missing records by comparing IDs: `SELECT id FROM source WHERE id NOT IN (SELECT id FROM target)`
- Log defect with batch ID, source count, target count, and list of missing IDs

---

### TC-021 | Calculated Field Validation — Amount Transformation

| Field | Detail |
|---|---|
| **Test Case ID** | TC-021 |
| **Feature** | Data Validation — Transformation Logic |
| **Type** | Data Validation |
| **Priority** | Critical |
| **Preconditions** | Business rule: Amount stored in source in cents, must be converted to dollars in target (divide by 100). |

**Steps to Execute:**
1. Query source: `SELECT id, amount_cents FROM source_table WHERE id = 'TXN_12345'`
2. Note source value (e.g., 10000 cents)
3. Query target: `SELECT id, amount_dollars FROM target_table WHERE id = 'TXN_12345'`
4. Verify transformation: amount_dollars should = amount_cents / 100

**Expected Result:**
- Source: 10000 cents
- Target: 100.00 dollars
- Values match the transformation rule

**Notes:** In financial systems, incorrect amount transformations = Critical severity. Test a statistically significant sample across different amount ranges.
