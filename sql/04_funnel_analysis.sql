-- Onboarding funnel analysis
USE novatech_ab_testing;

-- 1. Overall user-level funnel
WITH funnel AS (
    SELECT
        e.user_id,
        e.experiment_group,
        MAX(CASE WHEN ev.event_name = 'onboarding_start' THEN 1 ELSE 0 END) AS onboarding_start,
        MAX(CASE WHEN ev.event_name = 'onboarding_complete' THEN 1 ELSE 0 END) AS onboarding_complete,
        MAX(CASE WHEN ev.event_name = 'core_action' THEN 1 ELSE 0 END) AS core_action
    FROM experiments_clean e
    LEFT JOIN events_clean ev
        ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group
)
SELECT
    experiment_group,
    COUNT(*) AS users,
    SUM(onboarding_start) AS onboarding_start_users,
    ROUND(100.0 * SUM(onboarding_start) / COUNT(*), 2) AS onboarding_start_rate,
    SUM(onboarding_complete) AS onboarding_complete_users,
    ROUND(100.0 * SUM(onboarding_complete) / COUNT(*), 2) AS onboarding_completion_rate,
    SUM(core_action) AS core_action_users,
    ROUND(100.0 * SUM(core_action) / COUNT(*), 2) AS core_action_rate
FROM funnel
GROUP BY experiment_group
ORDER BY experiment_group;

-- 2. Completion -> core action conversion
WITH stages AS (
    SELECT
        e.user_id,
        e.experiment_group,
        MAX(CASE WHEN ev.event_name = 'onboarding_complete' THEN 1 ELSE 0 END) AS completed,
        MAX(CASE WHEN ev.event_name = 'core_action' THEN 1 ELSE 0 END) AS core_action
    FROM experiments_clean e
    LEFT JOIN events_clean ev
        ON e.user_id = ev.user_id
    GROUP BY e.user_id, e.experiment_group
)
SELECT
    experiment_group,
    SUM(completed) AS completed_users,
    SUM(CASE WHEN completed = 1 AND core_action = 1 THEN 1 ELSE 0 END) AS completed_and_core_action,
    ROUND(
        100.0 * SUM(CASE WHEN completed = 1 AND core_action = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(completed), 0), 2
    ) AS completion_to_core_rate
FROM stages
GROUP BY experiment_group
ORDER BY experiment_group;
