-- Business Question: Which merchant categories show strongest seasonal patterns and in which months do they peak?
-- Why This Matters: Reveals category-level seasonality for planning and forecasting.
-- Decision This Informs: Merchant campaigns, inventory planning, and seasonal reporting.
-- Tables Used: fintech.fact_transactions, fintech.dim_merchant, fintech.dim_time

WITH category_monthly_volume AS (
    SELECT
        m.merchant_category,
        t.month_number,
        t.month,
        COUNT(*) AS transaction_count
    FROM fintech.fact_transactions f
    JOIN fintech.dim_merchant m
        ON f.merchant_id = m.merchant_id
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    GROUP BY
        m.merchant_category,
        t.month_number,
        t.month
),
ranked AS (
    SELECT
        merchant_category,
        month_number,
        month,
        transaction_count,
        RANK() OVER (
            PARTITION BY merchant_category
            ORDER BY transaction_count DESC, month_number
        ) AS month_rank
    FROM category_monthly_volume
)
SELECT
    merchant_category,
    month_number,
    month,
    transaction_count
FROM ranked
WHERE month_rank = 1
ORDER BY
    merchant_category;