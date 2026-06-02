-- Business Question: What is month-over-month and year-over-year revenue growth?
-- Why This Matters: Measures acceleration, slowdown, and longer-term performance trends.
-- Decision This Informs: Leadership reporting, growth tracking, and planning cycles.
-- Tables Used: fintech.fact_transactions, fintech.dim_time

WITH monthly_revenue AS (
    SELECT
        t.year,
        t.month_number,
        t.month,
        DATE_TRUNC('month', t.full_date)::date AS month_start,
        SUM(f.net_amount) AS net_revenue
    FROM fintech.fact_transactions f
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    GROUP BY
        t.year,
        t.month_number,
        t.month,
        DATE_TRUNC('month', t.full_date)::date
)
SELECT
    year,
    month_number,
    month,
    net_revenue,
    LAG(net_revenue) OVER (ORDER BY month_start) AS previous_month_revenue,
    ROUND(
        (
            100.0 * (net_revenue - LAG(net_revenue) OVER (ORDER BY month_start))
            / NULLIF(LAG(net_revenue) OVER (ORDER BY month_start), 0)
        )::numeric,
        2
    ) AS mom_growth_pct,
    LAG(net_revenue, 12) OVER (ORDER BY month_start) AS previous_year_revenue,
    ROUND(
        (
            100.0 * (net_revenue - LAG(net_revenue, 12) OVER (ORDER BY month_start))
            / NULLIF(LAG(net_revenue, 12) OVER (ORDER BY month_start), 0)
        )::numeric,
        2
    ) AS yoy_growth_pct
FROM monthly_revenue
ORDER BY
    month_start;