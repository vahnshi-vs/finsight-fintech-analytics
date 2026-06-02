-- Business Question: What is the fraud rate and success rate of transactions in the top 5 percent by amount?
-- Why This Matters: Evaluates risk concentration among large-value transactions.
-- Decision This Informs: High-value transaction monitoring and approval controls.
-- Tables Used: fintech.fact_transactions

WITH threshold AS (
    SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY transaction_amount) AS p95_amount
    FROM fintech.fact_transactions
)
SELECT
    COUNT(*) AS high_value_transactions,
    ROUND(
        (AVG(CASE WHEN f.is_fraud = TRUE THEN 1.0 ELSE 0.0 END) * 100)::numeric,
        2
    ) AS fraud_rate_pct,
    ROUND(
        (AVG(CASE WHEN f.status = 'success' THEN 1.0 ELSE 0.0 END) * 100)::numeric,
        2
    ) AS success_rate_pct,
    ROUND(
        AVG(f.transaction_amount)::numeric,
        2
    ) AS avg_transaction_amount
FROM fintech.fact_transactions f
CROSS JOIN threshold t
WHERE f.transaction_amount >= t.p95_amount;