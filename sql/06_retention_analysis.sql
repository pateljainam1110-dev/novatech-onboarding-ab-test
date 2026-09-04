-- Point-in-time retention analysis
-- Retention activity excludes signup/onboarding events.
USE novatech_ab_testing;

WITH retention AS (
    SELECT
        e.user_id,
        e.experiment_group,
        u.signup_date,

        MAX(CASE
            WHEN ev.event_name IN ('core_action','feature_view','session_start','subscription_start')
             AND DATE(ev.event_timestamp) = DATE_ADD(u.signup_date, INTERVAL 1 DAY)
            THEN 1 ELSE 0 END) AS d1_retained,

        MAX(CASE
            WHEN ev.event_name IN ('core_action','feature_view','session_start','subscription_start')
             AND DATE(ev.event_timestamp) = DATE_ADD(u.signup_date, INTERVAL 7 DAY)
            THEN 1 ELSE 0 END) AS d7_retained,

        MAX(CASE
            WHEN ev.event_name IN ('core_action','feature_view','session_start','subscription_start')
             AND DATE(ev.event_timestamp) = DATE_ADD(u.signup_date, INTERVAL 30 DAY)
            THEN 1 ELSE 0 END) AS d30_retained

    FROM experiments_clean e
    JOIN users_clean u ON e.user_id = u.user_id
    LEFT JOIN events_clean ev ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group, u.signup_date
)
SELECT
    experiment_group,
    COUNT(*) AS users,
    SUM(d1_retained) AS d1_retained_users,
    ROUND(100.0 * SUM(d1_retained) / COUNT(*), 2) AS d1_retention,
    SUM(d7_retained) AS d7_retained_users,
    ROUND(100.0 * SUM(d7_retained) / COUNT(*), 2) AS d7_retention,
    SUM(d30_retained) AS d30_retained_users,
    ROUND(100.0 * SUM(d30_retained) / COUNT(*), 2) AS d30_retention
FROM retention
GROUP BY experiment_group
ORDER BY experiment_group;
