-- Experiment-level analysis
USE novatech_ab_testing;

-- 1. Primary 7-day activation
WITH user_activation AS (
    SELECT
        e.user_id,
        e.experiment_group,
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
    GROUP BY e.user_id, e.experiment_group, u.signup_date
)
SELECT
    experiment_group,
    COUNT(*) AS eligible_users,
    SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END) AS activated_users,
    ROUND(
        100.0 * SUM(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS activation_rate
FROM user_activation
GROUP BY experiment_group
ORDER BY experiment_group;

-- 2. Absolute and relative activation lift
WITH rates AS (
    SELECT
        experiment_group,
        AVG(CASE WHEN completed_7d = 1 AND core_7d = 1 THEN 1.0 ELSE 0.0 END) AS activation_rate
    FROM (
        SELECT
            e.user_id,
            e.experiment_group,
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
        GROUP BY e.user_id, e.experiment_group, u.signup_date
    ) a
    GROUP BY experiment_group
)
SELECT
    MAX(CASE WHEN experiment_group = 'Control' THEN activation_rate END) AS control_activation_rate,
    MAX(CASE WHEN experiment_group = 'Treatment' THEN activation_rate END) AS treatment_activation_rate,
    ROUND(100.0 * (
        MAX(CASE WHEN experiment_group = 'Treatment' THEN activation_rate END)
        - MAX(CASE WHEN experiment_group = 'Control' THEN activation_rate END)
    ), 2) AS absolute_lift_pp,
    ROUND(100.0 * (
        MAX(CASE WHEN experiment_group = 'Treatment' THEN activation_rate END)
        / NULLIF(MAX(CASE WHEN experiment_group = 'Control' THEN activation_rate END), 0)
        - 1
    ), 2) AS relative_lift_pct
FROM rates;

-- 3. Paid conversion
SELECT
    e.experiment_group,
    COUNT(DISTINCT e.user_id) AS users,
    COUNT(DISTINCT CASE
        WHEN LOWER(t.payment_status) = 'success' THEN t.user_id
    END) AS paid_users,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN LOWER(t.payment_status) = 'success' THEN t.user_id
        END) / COUNT(DISTINCT e.user_id), 2
    ) AS paid_conversion_rate
FROM experiments_clean e
LEFT JOIN transactions_clean t
    ON e.user_id = t.user_id
GROUP BY e.experiment_group
ORDER BY e.experiment_group;

-- 4. Total revenue and revenue per user
SELECT
    e.experiment_group,
    COUNT(DISTINCT e.user_id) AS users,
    ROUND(
        COALESCE(SUM(CASE
            WHEN LOWER(t.payment_status) = 'success' THEN t.amount
            ELSE 0
        END), 0), 2
    ) AS total_revenue,
    ROUND(
        COALESCE(SUM(CASE
            WHEN LOWER(t.payment_status) = 'success' THEN t.amount
            ELSE 0
        END), 0) / COUNT(DISTINCT e.user_id), 2
    ) AS revenue_per_user
FROM experiments_clean e
LEFT JOIN transactions_clean t
    ON e.user_id = t.user_id
GROUP BY e.experiment_group
ORDER BY e.experiment_group;

-- 5. Revenue by product type
SELECT
    e.experiment_group,
    t.product_type,
    COUNT(DISTINCT t.transaction_id) AS successful_transactions,
    ROUND(SUM(t.amount), 2) AS revenue
FROM experiments_clean e
JOIN transactions_clean t
    ON e.user_id = t.user_id
WHERE LOWER(t.payment_status) = 'success'
GROUP BY e.experiment_group, t.product_type
ORDER BY e.experiment_group, revenue DESC;
