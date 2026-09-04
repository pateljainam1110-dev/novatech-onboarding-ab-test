-- Business impact calculations
USE novatech_ab_testing;

-- Estimated incremental activated users if the treatment rate
-- were applied to the control-sized population.
WITH activation_rates AS (
    SELECT
        e.experiment_group,
        AVG(
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM events_clean c
                    WHERE c.user_id = e.user_id
                      AND c.event_name = 'onboarding_complete'
                      AND c.event_timestamp >= u.signup_date
                      AND c.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
                )
                AND EXISTS (
                    SELECT 1
                    FROM events_clean a
                    WHERE a.user_id = e.user_id
                      AND a.event_name = 'core_action'
                      AND a.event_timestamp >= u.signup_date
                      AND a.event_timestamp <= DATE_ADD(u.signup_date, INTERVAL 7 DAY)
                )
                THEN 1.0 ELSE 0.0
            END
        ) AS activation_rate
    FROM experiments_clean e
    JOIN users_clean u ON e.user_id = u.user_id
    GROUP BY e.experiment_group
)
SELECT
    ROUND(
        (MAX(CASE WHEN experiment_group = 'Treatment' THEN activation_rate END)
        - MAX(CASE WHEN experiment_group = 'Control' THEN activation_rate END))
        * (SELECT COUNT(*) FROM experiments_clean WHERE experiment_group = 'Control')
    ) AS estimated_incremental_activated_users_on_control_population
FROM activation_rates;

-- Revenue uplift per user
WITH revenue AS (
    SELECT
        e.experiment_group,
        COUNT(DISTINCT e.user_id) AS users,
        COALESCE(SUM(CASE WHEN LOWER(t.payment_status) = 'success' THEN t.amount ELSE 0 END), 0) AS total_revenue
    FROM experiments_clean e
    LEFT JOIN transactions_clean t ON e.user_id = t.user_id
    GROUP BY e.experiment_group
)
SELECT
    ROUND(MAX(CASE WHEN experiment_group = 'Control' THEN total_revenue / users END), 2) AS control_revenue_per_user,
    ROUND(MAX(CASE WHEN experiment_group = 'Treatment' THEN total_revenue / users END), 2) AS treatment_revenue_per_user,
    ROUND(
        MAX(CASE WHEN experiment_group = 'Treatment' THEN total_revenue / users END)
        - MAX(CASE WHEN experiment_group = 'Control' THEN total_revenue / users END), 2
    ) AS revenue_uplift_per_user,
    ROUND(
        100.0 * (
            MAX(CASE WHEN experiment_group = 'Treatment' THEN total_revenue / users END)
            / NULLIF(MAX(CASE WHEN experiment_group = 'Control' THEN total_revenue / users END), 0)
            - 1
        ), 2
    ) AS relative_revenue_uplift_pct
FROM revenue;
