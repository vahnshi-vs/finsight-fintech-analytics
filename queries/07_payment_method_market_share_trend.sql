-- Business Question: How has the percentage market share of each payment method changed month by month?
-- Why This Matters: Shows how user preferences shift across rails over time.
-- Decision This Informs: Payment product strategy and merchant routing decisions.
-- Tables Used: fintech.fact_transactions, fintech.dim_time, fintech.dim_payment_method

WITH monthly_method_volume AS (
    SELECT
        t.year,
        t.month_number,
        t.month,
        pm.payment_method_name,
        COUNT(*) AS transaction_count
    FROM fintech.fact_transactions f
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    JOIN fintech.dim_payment_method pm
        ON f.payment_method_id = pm.payment_method_id
    GROUP BY
        t.year,
        t.month_number,
        t.month,
        pm.payment_method_name
)
SELECT
    year,
    month_number,
    month,
    payment_method_name,
    transaction_count,
    ROUND(100.0 * transaction_count / SUM(transaction_count) OVER (PARTITION BY year, month_number), 2) AS market_share_pct
FROM monthly_method_volume
ORDER BY
    year,
    month_number,
    payment_method_name;