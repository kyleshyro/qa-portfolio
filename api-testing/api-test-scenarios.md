# API Testing — Postman Test Scenarios

> These scenarios demonstrate my API testing approach using Postman.
> Based on patterns used testing 40-60 REST endpoints at TD Securities.

---

## 🧪 TEST APPROACH

For every API endpoint I test:

1. **Positive scenario** — valid request returns expected response
2. **Negative scenarios** — invalid inputs return correct error codes
3. **Schema validation** — response structure matches contract
4. **Backend validation** — SQL query confirms database updated correctly

---

## 📋 TEST SCENARIOS

---

### Endpoint: POST /api/auth/login

**Test 1 — Valid Credentials (Positive)**

```
Method: POST
URL: {{base_url}}/api/auth/login
Headers: Content-Type: application/json

Body:
{
  "email": "testuser@example.com",
  "password": "ValidPass123!"
}

Expected:
- Status: 200 OK
- Body contains: { "token": "<string>", "user": { "id": "<string>", "email": "<string>" } }
- Token is not null or empty
- Response time < 2000ms
```

**Test 2 — Invalid Password (Negative)**

```
Method: POST
URL: {{base_url}}/api/auth/login

Body:
{
  "email": "testuser@example.com",
  "password": "WrongPassword"
}

Expected:
- Status: 401 Unauthorized
- Body: { "error": "Invalid email or password" }
- No token returned
```

**Test 3 — Missing Required Field (Negative)**

```
Method: POST
URL: {{base_url}}/api/auth/login

Body:
{
  "email": "testuser@example.com"
  // password field missing
}

Expected:
- Status: 400 Bad Request
- Body contains validation error for missing password field
```

---

### Endpoint: GET /api/users/{id}

**Test 1 — Valid User ID (Positive)**

```
Method: GET
URL: {{base_url}}/api/users/{{user_id}}
Headers: Authorization: Bearer {{auth_token}}

Expected:
- Status: 200 OK
- Body contains: id, email, name, createdAt fields
- All fields are correct data types (id = string, email = string, etc.)
- createdAt is valid ISO 8601 date format
```

**Test 2 — User Not Found (Negative)**

```
Method: GET
URL: {{base_url}}/api/users/nonexistent-id-999
Headers: Authorization: Bearer {{auth_token}}

Expected:
- Status: 404 Not Found
- Body: { "error": "User not found" }
```

**Test 3 — Missing Auth Token (Negative)**

```
Method: GET
URL: {{base_url}}/api/users/{{user_id}}
// No Authorization header

Expected:
- Status: 401 Unauthorized
- Body: { "error": "Authentication required" }
```

---

### Endpoint: POST /api/transactions

**Test 1 — Valid Transaction (Positive)**

```
Method: POST
URL: {{base_url}}/api/transactions
Headers:
  Authorization: Bearer {{auth_token}}
  Content-Type: application/json

Body:
{
  "amount": 100.00,
  "currency": "USD",
  "description": "Test transaction",
  "recipient_id": "{{recipient_id}}"
}

Expected:
- Status: 201 Created
- Body contains: transaction_id, status: "PENDING", amount: 100.00
- Backend SQL validation: SELECT * FROM transactions WHERE id = '<returned_id>'
  → Record exists with correct amount and status
```

**Test 2 — Negative Amount (Negative)**

```
Method: POST
URL: {{base_url}}/api/transactions

Body:
{
  "amount": -50.00,
  "currency": "USD",
  "description": "Invalid amount test"
}

Expected:
- Status: 400 Bad Request
- Body: validation error for negative amount
- No record created in database (verify with SQL)
```

---

## 📊 HTTP STATUS Code Reference

| Code | Meaning | When to expect it |
|---|---|---|
| 200 | OK | Successful GET, PUT |
| 201 | Created | Successful POST — new resource created |
| 400 | Bad Request | Invalid input, missing required fields |
| 401 | Unauthorized | Missing or invalid auth token |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource attempt |
| 500 | Server Error | Unexpected server-side issue |

---

## ✅ Postman Test Script Example (JavaScript)

```javascript
// Add to Postman Tests tab for automated assertions

// Verify status code
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Verify response time
pm.test("Response time is less than 2000ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(2000);
});

// Verify token exists in response
pm.test("Token is present in response", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData.token).to.not.be.null;
    pm.expect(jsonData.token).to.not.be.empty;
});

// Save token as environment variable for next requests
const jsonData = pm.response.json();
pm.environment.set("auth_token", jsonData.token);
```
