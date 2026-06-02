-- Business Question: For each monthly cohort of new customers, what percentage are still making transactions at months 1, 3, 6, and 12 after their first transaction?
-- Why This Matters: Shows whether customers return over time and how durable acquisition is.
-- Decision This Informs: Retention strategy, lifecycle marketing, and cohort quality evaluation.
-- Tables Used: fintech.fact_transactions, fintech.dim_customer, fintech.dim_time

WITH first_transaction AS (
    SELECT
        f.customer_id,
        DATE_TRUNC('month', MIN(t.full_date))::date AS cohort_month
    FROM fintech.fact_transactions f
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    GROUP BY
        f.customer_id
),
customer_activity AS (
    SELECT
        ft.customer_id,
        ft.cohort_month,
        DATE_TRUNC('month', t.full_date)::date AS activity_month,
        (EXTRACT(YEAR FROM DATE_TRUNC('month', t.full_date)) - EXTRACT(YEAR FROM ft.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM DATE_TRUNC('month', t.full_date)) - EXTRACT(MONTH FROM ft.cohort_month)) AS months_since_first_transaction
    FROM first_transaction ft
    JOIN fintech.fact_transactions f
        ON ft.customer_id = f.customer_id
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_transaction
    GROUP BY
        cohort_month
),
retention_counts AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT CASE WHEN months_since_first_transaction = 1 THEN customer_id END) AS month_1_retained,
        COUNT(DISTINCT CASE WHEN months_since_first_transaction = 3 THEN customer_id END) AS month_3_retained,
        COUNT(DISTINCT CASE WHEN months_since_first_transaction = 6 THEN customer_id END) AS month_6_retained,
        COUNT(DISTINCT CASE WHEN months_since_first_transaction = 12 THEN customer_id END) AS month_12_retained
    FROM customer_activity
    GROUP BY
        cohort_month
)
SELECT
    c.cohort_month,
    c.cohort_size,
    ROUND(100.0 * r.month_1_retained / NULLIF(c.cohort_size, 0), 2) AS month_1_retention_pct,
    ROUND(100.0 * r.month_3_retained / NULLIF(c.cohort_size, 0), 2) AS month_3_retention_pct,
    ROUND(100.0 * r.month_6_retained / NULLIF(c.cohort_size, 0), 2) AS month_6_retention_pct,
    ROUND(100.0 * r.month_12_retained / NULLIF(c.cohort_size, 0), 2) AS month_12_retention_pct
FROM cohort_sizes c
LEFT JOIN retention_counts r
    ON c.cohort_month = r.cohort_month
ORDER BY
    c.cohort_month;