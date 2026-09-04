-- Segment-level activation analysis
USE novatech_ab_testing;

-- The activation definition is:
-- onboarding_complete AND core_action within 7 days of signup.

-- 1. Device
WITH user_activation AS (
    SELECT
        e.user_id,
        e.experiment_group,
        COALESCE(u.device_type, 'Unknown') AS device_type,
        u.signup_date,
        MAX(CASE
            WHEN ev.event_name = 'onboarding_complete'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS completed_7d,
        MAX(CASE
            WHEN ev.event_name = 'core_action'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS core_7d
    FROM experiments_clean e
    JOIN users_clean u ON e.user_id = u.user_id
    LEFT JOIN events_clean ev ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group, u.device_type, u.signup_date
)
SELECT
    device_type,
    experiment_group,
    COUNT(*) AS users,
    SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END) AS activated_users,
    ROUND(
        100.0 * SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS activation_rate
FROM user_activation
GROUP BY device_type, experiment_group
ORDER BY device_type, experiment_group;

-- 2. Country
WITH user_activation AS (
    SELECT
        e.user_id,
        e.experiment_group,
        COALESCE(u.country, 'Unknown') AS country,
        u.signup_date,
        MAX(CASE
            WHEN ev.event_name = 'onboarding_complete'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS completed_7d,
        MAX(CASE
            WHEN ev.event_name = 'core_action'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS core_7d
    FROM experiments_clean e
    JOIN users_clean u ON e.user_id = u.user_id
    LEFT JOIN events_clean ev ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group, u.country, u.signup_date
)
SELECT
    country,
    experiment_group,
    COUNT(*) AS users,
    SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END) AS activated_users,
    ROUND(
        100.0 * SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS activation_rate
FROM user_activation
GROUP BY country, experiment_group
ORDER BY country, experiment_group;

-- 3. Acquisition channel
WITH user_activation AS (
    SELECT
        e.user_id,
        e.experiment_group,
        u.acquisition_channel,
        u.signup_date,
        MAX(CASE
            WHEN ev.event_name = 'onboarding_complete'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS completed_7d,
        MAX(CASE
            WHEN ev.event_name = 'core_action'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS core_7d
    FROM experiments_clean e
    JOIN users_clean u ON e.user_id = u.user_id
    LEFT JOIN events_clean ev ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group, u.acquisition_channel, u.signup_date
)
SELECT
    acquisition_channel,
    experiment_group,
    COUNT(*) AS users,
    SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END) AS activated_users,
    ROUND(
        100.0 * SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS activation_rate
FROM user_activation
GROUP BY acquisition_channel, experiment_group
ORDER BY acquisition_channel, experiment_group;

-- 4. Age group
WITH user_activation AS (
    SELECT
        e.user_id,
        e.experiment_group,
        u.age_group,
        u.signup_date,
        MAX(CASE
            WHEN ev.event_name = 'onboarding_complete'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS completed_7d,
        MAX(CASE
            WHEN ev.event_name = 'core_action'
             AND ev.event_timestamp >= u.signup_date
             AND ev.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS core_7d
    FROM experiments_clean e
    JOIN users_clean u ON e.user_id = u.user_id
    LEFT JOIN events_clean ev ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group, u.age_group, u.signup_date
)
SELECT
    age_group,
    experiment_group,
    COUNT(*) AS users,
    SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END) AS activated_users,
    ROUND(
        100.0 * SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS activation_rate
FROM user_activation
GROUP BY age_group, experiment_group
ORDER BY age_group, experiment_group;
