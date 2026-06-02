-- Business Question: At what hours of the day does fraud concentrate?
-- Why This Matters: Identifies the highest-risk time windows for monitoring and controls.
-- Decision This Informs: Fraud surveillance schedules and alerting thresholds.
-- Tables Used: fintech.fact_transactions

SELECT
    f.transaction_hour,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN f.is_fraud = TRUE THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        (100.0 * SUM(CASE WHEN f.is_fraud = TRUE THEN 1 ELSE 0 END)
         / NULLIF(COUNT(*), 0))::numeric,
        2
    ) AS fraud_rate_pct,
    ROUND(
        SUM(CASE WHEN f.is_fraud = TRUE THEN f.transaction_amount ELSE 0 END)::numeric,
        2
    ) AS fraud_amount
FROM fintech.fact_transactions f
GROUP BY
    f.transaction_hour
ORDER BY
    f.transaction_hour;