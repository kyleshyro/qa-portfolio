# SQL Queries for QA Data Validation

> These queries demonstrate real-world SQL skills used for data validation,
> defect root cause analysis, and source-to-target reconciliation.
> Based on patterns used during QA work at TD Securities.

---

## 1. RECORD COUNT VALIDATION

```sql
-- Compare record counts between source and target after data migration
-- Expected: both counts should match

SELECT 'SOURCE' AS system, COUNT(*) AS record_count
FROM source_table
WHERE status = 'PROCESSED'
AND created_date >= '2024-01-01'

UNION ALL

SELECT 'TARGET' AS system, COUNT(*) AS record_count
FROM target_table
WHERE status = 'PROCESSED'
AND created_date >= '2024-01-01';
```

---

## 2. FIND MISSING RECORDS (Source vs Target)

```sql
-- Identify records present in source but missing from target
-- Used to identify data loss during migration or integration

SELECT s.id, s.transaction_ref, s.amount, s.created_date
FROM source_table s
LEFT JOIN target_table t ON s.id = t.source_id
WHERE t.source_id IS NULL
AND s.status = 'ACTIVE'
ORDER BY s.created_date DESC;
```

---

## 3. TRANSFORMATION LOGIC VALIDATION

```sql
-- Validate that amount transformation is correct
-- Business rule: source stores amount in cents, target should store in dollars

SELECT
    s.id,
    s.amount_cents AS source_amount,
    t.amount_dollars AS target_amount,
    (s.amount_cents / 100.0) AS expected_amount,
    CASE
        WHEN t.amount_dollars = (s.amount_cents / 100.0) THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM source_table s
INNER JOIN target_table t ON s.id = t.source_id
WHERE s.created_date >= '2024-01-01'
ORDER BY validation_status DESC;
```

---

## 4. DUPLICATE RECORD DETECTION

```sql
-- Find duplicate records that should be unique
-- Used when a unique constraint is expected but data issues occur

SELECT
    transaction_ref,
    COUNT(*) AS occurrence_count
FROM target_table
GROUP BY transaction_ref
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;
```

---

## 5. STATUS FIELD VALIDATION

```sql
-- Validate that all records have valid status values
-- Business rule: status must be one of PENDING, PROCESSED, FAILED, CANCELLED

SELECT
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM target_table
WHERE created_date >= '2024-01-01'
GROUP BY status
ORDER BY count DESC;

-- Flag invalid statuses
SELECT id, transaction_ref, status, created_date
FROM target_table
WHERE status NOT IN ('PENDING', 'PROCESSED', 'FAILED', 'CANCELLED')
ORDER BY created_date DESC;
```

---

## 6. DATE AND TIMESTAMP VALIDATION

```sql
-- Validate processing timestamps are in expected order
-- Business rule: processed_date must always be >= created_date

SELECT
    id,
    created_date,
    processed_date,
    DATEDIFF(processed_date, created_date) AS processing_days
FROM target_table
WHERE processed_date < created_date  -- This should return 0 rows
ORDER BY created_date DESC;

-- Also check for null timestamps on completed records
SELECT id, transaction_ref, created_date, processed_date
FROM target_table
WHERE status = 'PROCESSED'
AND processed_date IS NULL;  -- Should return 0 rows
```

---

## 7. CROSS-SYSTEM RECONCILIATION

```sql
-- Full reconciliation between two systems
-- Validates counts, amounts, and status alignment

SELECT
    'COUNT_MATCH' AS check_type,
    CASE WHEN s.total = t.total THEN 'PASS' ELSE 'FAIL' END AS result,
    s.total AS source_count,
    t.total AS target_count
FROM
    (SELECT COUNT(*) AS total FROM source_table WHERE batch_id = 'BATCH_001') s,
    (SELECT COUNT(*) AS total FROM target_table WHERE batch_id = 'BATCH_001') t

UNION ALL

SELECT
    'AMOUNT_MATCH' AS check_type,
    CASE WHEN s.total = t.total THEN 'PASS' ELSE 'FAIL' END AS result,
    s.total AS source_total,
    t.total AS target_total
FROM
    (SELECT SUM(amount) AS total FROM source_table WHERE batch_id = 'BATCH_001') s,
    (SELECT SUM(amount) AS total FROM target_table WHERE batch_id = 'BATCH_001') t;
```

---

## 8. DEFECT ROOT CAUSE ANALYSIS QUERY

```sql
-- Isolate specific failing records for defect documentation
-- Used when investigating a reported production issue

SELECT
    t.id,
    t.transaction_ref,
    t.amount_dollars,
    t.status,
    t.processed_date,
    t.error_code,
    t.error_message,
    s.amount_cents,
    s.original_status
FROM target_table t
INNER JOIN source_table s ON t.source_id = s.id
WHERE t.status = 'FAILED'
AND t.processed_date >= '2024-01-15'
AND t.processed_date < '2024-01-16'  -- Isolate by date of reported issue
ORDER BY t.processed_date ASC;

-- Group by error type to identify patterns
SELECT
    error_code,
    error_message,
    COUNT(*) AS failure_count
FROM target_table
WHERE status = 'FAILED'
AND processed_date >= '2024-01-15'
GROUP BY error_code, error_message
ORDER BY failure_count DESC;
```
