%%writefile schema/views/vw_customer_cohort_retention.sql
-- Business Question: For each monthly cohort of new customers, what percentage are still making transactions at months 1, 3, 6, and 12?
-- Why This Matters: Shows customer stickiness and long-term retention health of the product.
-- Decision This Informs: Customer retention investment, loyalty program triggers, and churn intervention timing.
-- Tables Used: fact_transactions, dim_time

CREATE VIEW fintech.vw_customer_cohort_retention AS

WITH first_transaction AS (
    SELECT 
        ft.customer_id,
        DATE_TRUNC('month', MIN(dt.full_date))::date AS cohort_month
    FROM fintech.fact_transactions ft
    INNER JOIN fintech.dim_time dt ON ft.date_key = dt.date_key
    WHERE ft.status = 'success'
    GROUP BY ft.customer_id
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_transaction
    GROUP BY cohort_month
),
retention AS (
    SELECT 
        f.cohort_month,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', dt.full_date) = (f.cohort_month + INTERVAL '1 month')::date 
            THEN ft.customer_id END) AS retained_m1,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', dt.full_date) = (f.cohort_month + INTERVAL '3 months')::date 
            THEN ft.customer_id END) AS retained_m3,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', dt.full_date) = (f.cohort_month + INTERVAL '6 months')::date 
            THEN ft.customer_id END) AS retained_m6,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', dt.full_date) = (f.cohort_month + INTERVAL '12 months')::date 
            THEN ft.customer_id END) AS retained_m12
    FROM first_transaction f
    INNER JOIN fintech.fact_transactions ft ON f.customer_id = ft.customer_id
    INNER JOIN fintech.dim_time dt ON ft.date_key = dt.date_key
    WHERE ft.status = 'success'
    GROUP BY f.cohort_month
)
SELECT 
    TO_CHAR(r.cohort_month, 'YYYY-MM') AS cohort_month,
    cs.cohort_size,
    ROUND((retained_m1::numeric / NULLIF(cs.cohort_size, 0)) * 100, 0) AS retention_m1_pct,
    ROUND((retained_m3::numeric / NULLIF(cs.cohort_size, 0)) * 100, 0) AS retention_m3_pct,
    ROUND((retained_m6::numeric / NULLIF(cs.cohort_size, 0)) * 100, 0) AS retention_m6_pct,
    ROUND((retained_m12::numeric / NULLIF(cs.cohort_size, 0)) * 100, 0) AS retention_m12_pct
FROM retention r
INNER JOIN cohort_sizes cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month;