-- Raw/staging tables
-- IMPORTANT: These tables intentionally have no PRIMARY KEY/FK constraints.
-- The source CSVs contain known duplicate rows/event IDs that must be audited
-- before creating clean analysis tables.

USE novatech_ab_testing;

DROP TABLE IF EXISTS transactions_raw;
DROP TABLE IF EXISTS events_raw;
DROP TABLE IF EXISTS experiments_raw;
DROP TABLE IF EXISTS users_raw;

CREATE TABLE users_raw (
    user_id VARCHAR(20),
    signup_date DATE,
    country VARCHAR(50),
    device_type VARCHAR(20),
    age_group VARCHAR(20),
    acquisition_channel VARCHAR(30)
);

CREATE TABLE experiments_raw (
    user_id VARCHAR(20),
    experiment_name VARCHAR(50),
    experiment_group VARCHAR(20),
    assignment_date DATE,
    variant_version VARCHAR(10)
);

CREATE TABLE events_raw (
    event_id VARCHAR(20),
    user_id VARCHAR(20),
    event_name VARCHAR(50),
    event_timestamp DATETIME,
    session_id VARCHAR(50),
    platform VARCHAR(20),
    event_hour INT
);

CREATE TABLE transactions_raw (
    transaction_id VARCHAR(20),
    user_id VARCHAR(20),
    transaction_date DATE,
    amount DECIMAL(10,2),
    product_type VARCHAR(50),
    payment_status VARCHAR(20)
);
