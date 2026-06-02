-- Business Question: What is the lifetime value, transaction frequency, average transaction value, and recency for every customer and how do they rank?
-- Why This Matters: Identifies the highest-value customers and supports prioritization.
-- Decision This Informs: CRM focus, premium targeting, and retention outreach.
-- Tables Used: fintech.fact_transactions, fintech.dim_customer, fintech.dim_time

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(*) AS transaction_count,
        SUM(f.net_amount) AS total_ltv,
        AVG(f.transaction_amount) AS avg_transaction_value,
        MAX(t.full_date) AS last_transaction_date,
        CURRENT_DATE - MAX(t.full_date) AS recency_days
    FROM fintech.fact_transactions f
    JOIN fintech.dim_customer c
        ON f.customer_id = c.customer_id
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.customer_segment
)
SELECT
    customer_id,
    customer_name,
    customer_segment,
    transaction_count,
    ROUND(total_ltv::numeric, 2) AS total_ltv,
    ROUND(avg_transaction_value::numeric, 2) AS avg_transaction_value,
    last_transaction_date,
    recency_days,
    DENSE_RANK() OVER (ORDER BY total_ltv DESC) AS ltv_rank
FROM customer_metrics
ORDER BY
    total_ltv DESC,
    transaction_count DESC;