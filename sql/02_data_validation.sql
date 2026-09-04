-- Data quality checks against the raw CSV data
USE novatech_ab_testing;

-- 1. Raw row counts
SELECT 'users_raw' AS table_name, COUNT(*) AS row_count FROM users_raw
UNION ALL
SELECT 'experiments_raw', COUNT(*) FROM experiments_raw
UNION ALL
SELECT 'events_raw', COUNT(*) FROM events_raw
UNION ALL
SELECT 'transactions_raw', COUNT(*) FROM transactions_raw;

-- 2. Duplicate user IDs
SELECT user_id, COUNT(*) AS duplicate_count
FROM users_raw
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 3. Missing user attributes
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN country IS NULL THEN 1 END) AS missing_country,
    COUNT(CASE WHEN device_type IS NULL THEN 1 END) AS missing_device,
    COUNT(CASE WHEN age_group IS NULL THEN 1 END) AS missing_age_group,
    COUNT(CASE WHEN acquisition_channel IS NULL THEN 1 END) AS missing_acquisition_channel
FROM users_raw;

-- 4. Experiment group distribution
SELECT experiment_group, COUNT(*) AS users
FROM experiments_raw
GROUP BY experiment_group;

-- 5. Duplicate experiment assignments
SELECT user_id, COUNT(*) AS assignment_count
FROM experiments_raw
GROUP BY user_id
HAVING COUNT(*) > 1;

-- 6. Assignment dates before signup
SELECT COUNT(*) AS invalid_assignment_records
FROM experiments_raw e
JOIN (
    SELECT DISTINCT user_id, signup_date
    FROM users_raw
) u ON e.user_id = u.user_id
WHERE e.assignment_date < u.signup_date;

-- 7. Duplicate event IDs
SELECT event_id, COUNT(*) AS duplicate_count
FROM events_raw
GROUP BY event_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 8. Orphan events
SELECT COUNT(*) AS orphan_events
FROM (
    SELECT DISTINCT event_id, user_id, event_name, event_timestamp, session_id, platform, event_hour
    FROM events_raw
) e
LEFT JOIN (
    SELECT DISTINCT user_id
    FROM users_raw
) u ON e.user_id = u.user_id
WHERE u.user_id IS NULL;

-- 9. Missing transaction amounts
SELECT COUNT(*) AS missing_amounts
FROM transactions_raw
WHERE amount IS NULL;

-- 10. Payment status distribution
SELECT payment_status, COUNT(*) AS transaction_rows
FROM transactions_raw
GROUP BY payment_status
ORDER BY transaction_rows DESC;

-- 11. Events before signup
SELECT COUNT(*) AS events_before_signup
FROM (
    SELECT DISTINCT event_id, user_id, event_name, event_timestamp, session_id, platform, event_hour
    FROM events_raw
) e
JOIN (
    SELECT DISTINCT user_id, signup_date
    FROM users_raw
) u ON e.user_id = u.user_id
WHERE e.event_timestamp < u.signup_date;

-- 12. Event distribution
SELECT event_name, COUNT(*) AS event_count
FROM events_raw
GROUP BY event_name
ORDER BY event_count DESC;
