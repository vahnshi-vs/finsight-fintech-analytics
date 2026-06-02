-- Business Question: Which acquisition channel delivers better long-term value comparing 6-month revenue per customer, retention rate, and transaction frequency?
-- Why This Matters: Compares acquisition quality against cost to find the best growth channel.
-- Decision This Informs: Marketing budget allocation and channel strategy.
-- Tables Used: fintech.fact_transactions, fintech.dim_customer, fintech.dim_time

WITH customer_6m_metrics AS (
    SELECT
        c.acquisition_channel,
        c.customer_id,
        COUNT(*) AS transaction_count,
        SUM(f.net_amount) AS revenue_6m,
        COUNT(DISTINCT DATE_TRUNC('month', t.full_date)) AS active_months_6m,
        MAX(t.full_date) AS last_transaction_date
    FROM fintech.fact_transactions f
    JOIN fintech.dim_customer c
        ON f.customer_id = c.customer_id
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    WHERE t.full_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY
        c.acquisition_channel,
        c.customer_id
),
channel_summary AS (
    SELECT
        acquisition_channel,
        COUNT(*) AS customers,
        SUM(transaction_count) AS total_transactions,
        SUM(revenue_6m) AS total_revenue_6m,
        AVG(transaction_count) AS avg_transactions_per_customer,
        AVG(revenue_6m) AS avg_revenue_per_customer,
        AVG(
            CASE
                WHEN last_transaction_date >= CURRENT_DATE - INTERVAL '30 days'
                THEN 1.0 ELSE 0.0
            END
        ) * 100 AS retention_rate_pct
    FROM customer_6m_metrics
    GROUP BY
        acquisition_channel
)
SELECT
    acquisition_channel,
    customers,
    total_transactions,
    ROUND(total_revenue_6m::numeric, 2) AS total_revenue_6m,
    ROUND(avg_transactions_per_customer::numeric, 2) AS avg_transactions_per_customer,
    ROUND(avg_revenue_per_customer::numeric, 2) AS avg_revenue_per_customer,
    ROUND(retention_rate_pct::numeric, 2) AS retention_rate_pct,
    CASE
        WHEN acquisition_channel IN ('Paid-Google', 'Paid-Meta') THEN 150
        ELSE 20
    END AS assumed_acquisition_cost_per_customer,
    ROUND(
        (
            avg_revenue_per_customer
            / CASE
                  WHEN acquisition_channel IN ('Paid-Google', 'Paid-Meta') THEN 150
                  ELSE 20
              END
        )::numeric,
        2
    ) AS revenue_per_rupee_spent
FROM channel_summary
ORDER BY
    revenue_per_rupee_spent DESC,
    avg_revenue_per_customer DESC;