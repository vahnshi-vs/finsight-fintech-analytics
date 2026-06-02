%%writefile schema/views/vw_merchant_category_seasonality.sql
-- Business Question:
-- Which merchant categories show the strongest seasonal patterns and in which months do they peak?
-- Why This Matters:
-- Reveals when each merchant category needs more attention from sales, support, and operations.
-- Decision This Informs:
-- Seasonal planning, category-specific campaigns, and merchant relationship strategy.
-- Tables Used:
-- fintech.fact_transactions, fintech.dim_merchant, fintech.dim_time

CREATE OR REPLACE VIEW fintech.vw_merchant_category_seasonality AS
WITH monthly_category AS (
    SELECT
        m.merchant_category,
        t.year,
        t.month_number,
        t.month,
        DATE_TRUNC('month', t.full_date)::date AS month_start,
        COUNT(*) AS total_transactions,
        SUM(f.transaction_amount) AS gross_amount,
        SUM(f.net_amount) AS net_revenue
    FROM fintech.fact_transactions f
    JOIN fintech.dim_merchant m
        ON f.merchant_id = m.merchant_id
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    GROUP BY
        m.merchant_category,
        t.year,
        t.month_number,
        t.month,
        DATE_TRUNC('month', t.full_date)::date
),
category_ranked AS (
    SELECT
        merchant_category,
        year,
        month_number,
        month,
        month_start,
        total_transactions,
        gross_amount,
        net_revenue,
        RANK() OVER (
            PARTITION BY merchant_category
            ORDER BY total_transactions DESC, month_start
        ) AS month_rank_within_category
    FROM monthly_category
)
SELECT
    merchant_category,
    year,
    month_number,
    month,
    month_start,
    total_transactions,
    gross_amount,
    net_revenue,
    month_rank_within_category,
    ROUND(
        (gross_amount / NULLIF(SUM(gross_amount) OVER (PARTITION BY merchant_category), 0))::numeric,
        2
    ) AS category_month_volume_share_pct
FROM category_ranked
ORDER BY
    merchant_category,
    month_rank_within_category,
    month_start;