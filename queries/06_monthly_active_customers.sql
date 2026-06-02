-- Business Question: How many unique customers made at least one successful transaction in each calendar month?
-- Why This Matters: Measures active user base and usage retention over time.
-- Decision This Informs: Growth tracking, cohort health, and engagement planning.
-- Tables Used: fintech.fact_transactions, fintech.dim_time

SELECT
    t.year,
    t.month_number,
    t.month,
    COUNT(DISTINCT f.customer_id) AS active_customers
FROM fintech.fact_transactions f
JOIN fintech.dim_time t
    ON f.date_key = t.date_key
WHERE f.status = 'success'
GROUP BY
    t.year,
    t.month_number,
    t.month
ORDER BY
    t.year,
    t.month_number;