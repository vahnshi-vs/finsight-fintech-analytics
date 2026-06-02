-- Business Question: Which merchants were active last month but made zero transactions this month?
-- Why This Matters: Surfaces merchant churn early so teams can intervene quickly.
-- Decision This Informs: Merchant retention outreach and account management.
-- Tables Used: fintech.fact_transactions, fintech.dim_time, fintech.dim_merchant

WITH monthly_activity AS (
    SELECT DISTINCT
        t.year,
        t.month_number,
        t.month,
        f.merchant_id
    FROM fintech.fact_transactions f
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
),
month_ordered AS (
    SELECT DISTINCT
        year,
        month_number,
        month,
        (year * 100 + month_number) AS year_month_key,
        merchant_id
    FROM monthly_activity
),
current_month AS (
    SELECT DISTINCT merchant_id
    FROM month_ordered
    WHERE year_month_key = (SELECT MAX(year_month_key) FROM month_ordered)
),
previous_month AS (
    SELECT DISTINCT merchant_id
    FROM month_ordered
    WHERE year_month_key = (
        SELECT MAX(year_month_key)
        FROM month_ordered
        WHERE year_month_key < (SELECT MAX(year_month_key) FROM month_ordered)
    )
)
SELECT
    m.merchant_name,
    m.merchant_category,
    m.merchant_tier,
    m.city,
    m.state
FROM previous_month p
JOIN fintech.dim_merchant m
    ON p.merchant_id = m.merchant_id
LEFT JOIN current_month c
    ON p.merchant_id = c.merchant_id
WHERE c.merchant_id IS NULL
ORDER BY
    m.merchant_name;