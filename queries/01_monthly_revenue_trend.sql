-- Business Question: What is the total transaction volume and net revenue trend month by month?
-- Why This Matters: Tracks growth, seasonality, and revenue momentum over time.
-- Decision This Informs: Monthly planning, business performance review, and forecasting.
-- Tables Used: fintech.fact_transactions, fintech.dim_time

SELECT
    t.year,
    t.month_number,
    t.month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(f.transaction_amount)::numeric, 2) AS total_transaction_amount,
    ROUND(SUM(f.net_amount)::numeric, 2) AS total_net_revenue
FROM fintech.fact_transactions f
JOIN fintech.dim_time t
    ON f.date_key = t.date_key
GROUP BY
    t.year,
    t.month_number,
    t.month
ORDER BY
    t.year,
    t.month_number;