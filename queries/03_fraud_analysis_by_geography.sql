-- Business Question: Where is fraud concentrated geographically and how does fraud rate vary by city tier?
-- Why This Matters: Helps identify high-risk markets and allocate fraud controls efficiently.
-- Decision This Informs: Geo-based fraud monitoring, risk controls, and escalation priorities.
-- Tables Used: fintech.fact_transactions, fintech.dim_geography

SELECT
    g.state_name,
    g.geography_tier,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN f.is_fraud = TRUE THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(100.0 * SUM(CASE WHEN f.is_fraud = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)::numeric, 2) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN f.is_fraud = TRUE THEN f.transaction_amount ELSE 0 END)::numeric, 2) AS fraud_amount
FROM fintech.fact_transactions f
JOIN fintech.dim_geography g
    ON f.geography_id = g.geography_id
GROUP BY
    g.state_name,
    g.geography_tier
ORDER BY
    fraud_rate_pct DESC,
    fraud_amount DESC;