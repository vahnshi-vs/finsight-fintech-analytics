-- Business Question: Which payment method has the best success rate, highest average transaction value, and greatest revenue contribution?
-- Why This Matters: Shows which payment rails are strongest for volume, reliability, and monetization.
-- Decision This Informs: Payment method prioritization, optimization focus, and partner discussions.
-- Tables Used: fintech.fact_transactions, fintech.dim_payment_method

SELECT
    pm.payment_method_name,
    pm.payment_channel_type,
    COUNT(*) AS transaction_count,
    SUM(CASE WHEN f.status = 'success' THEN 1 ELSE 0 END) AS successful_transactions,
    ROUND(100.0 * SUM(CASE WHEN f.status = 'success' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)::numeric, 2) AS success_rate_pct,
    ROUND(AVG(f.transaction_amount)::numeric, 2) AS avg_transaction_amount,
    ROUND(SUM(f.net_amount)::numeric, 2) AS total_net_revenue,
    ROUND(AVG(pm.fee_percentage)::numeric, 2) AS avg_fee_percentage
FROM fintech.fact_transactions f
JOIN fintech.dim_payment_method pm
    ON f.payment_method_id = pm.payment_method_id
GROUP BY
    pm.payment_method_name,
    pm.payment_channel_type
ORDER BY
    success_rate_pct DESC,
    total_net_revenue DESC;