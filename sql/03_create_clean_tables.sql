-- Create cleaned analysis tables from the raw data
-- Cleaning decisions match the Python analysis:
-- users: remove exact duplicates; fill missing country/device as Unknown.
-- experiments: exclude assignment records occurring before signup.
-- events: remove exact duplicate rows.
-- transactions: retain missing amounts for auditability.

USE novatech_ab_testing;

DROP TABLE IF EXISTS transactions_clean;
DROP TABLE IF EXISTS events_clean;
DROP TABLE IF EXISTS experiments_clean;
DROP TABLE IF EXISTS users_clean;

CREATE TABLE users_clean (
    user_id VARCHAR(20) PRIMARY KEY,
    signup_date DATE,
    country VARCHAR(50),
    device_type VARCHAR(20),
    age_group VARCHAR(20),
    acquisition_channel VARCHAR(30)
);

INSERT INTO users_clean
SELECT
    user_id,
    signup_date,
    COALESCE(country, 'Unknown'),
    COALESCE(device_type, 'Unknown'),
    age_group,
    acquisition_channel
FROM users_raw
GROUP BY
    user_id, signup_date, country, device_type, age_group, acquisition_channel;

CREATE TABLE experiments_clean (
    user_id VARCHAR(20) PRIMARY KEY,
    experiment_name VARCHAR(50),
    experiment_group VARCHAR(20),
    assignment_date DATE,
    variant_version VARCHAR(10),
    FOREIGN KEY (user_id) REFERENCES users_clean(user_id)
);

INSERT INTO experiments_clean
SELECT
    e.user_id,
    e.experiment_name,
    e.experiment_group,
    e.assignment_date,
    e.variant_version
FROM experiments_raw e
JOIN users_clean u
    ON e.user_id = u.user_id
WHERE e.assignment_date >= u.signup_date;

CREATE TABLE events_clean (
    event_id VARCHAR(20) PRIMARY KEY,
    user_id VARCHAR(20),
    event_name VARCHAR(50),
    event_timestamp DATETIME,
    session_id VARCHAR(50),
    platform VARCHAR(20),
    event_hour INT,
    FOREIGN KEY (user_id) REFERENCES users_clean(user_id)
);

INSERT INTO events_clean
SELECT DISTINCT
    event_id,
    user_id,
    event_name,
    event_timestamp,
    session_id,
    platform,
    event_hour
FROM events_raw;

CREATE TABLE transactions_clean (
    transaction_id VARCHAR(20) PRIMARY KEY,
    user_id VARCHAR(20),
    transaction_date DATE,
    amount DECIMAL(10,2),
    product_type VARCHAR(50),
    payment_status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users_clean(user_id)
);

INSERT INTO transactions_clean
SELECT
    transaction_id,
    user_id,
    transaction_date,
    amount,
    product_type,
    payment_status
FROM transactions_raw;

-- Final cleaned row-count check
SELECT 'users_clean' AS table_name, COUNT(*) AS row_count FROM users_clean
UNION ALL
SELECT 'experiments_clean', COUNT(*) FROM experiments_clean
UNION ALL
SELECT 'events_clean', COUNT(*) FROM events_clean
UNION ALL
SELECT 'transactions_clean', COUNT(*) FROM transactions_clean;
