-- Business Question: How much transaction value is lost through failed transactions by payment method and merchant category?
-- Why This Matters: Quantifies revenue leakage and highlights where recovery efforts should focus.
-- Decision This Informs: Failure reduction, retry logic, and merchant-specific remediation.
-- Tables Used: fintech.fact_transactions, fintech.dim_payment_method, fintech.dim_merchant

SELECT
    pm.payment_method_name,
    m.merchant_category,
    COUNT(*) AS failed_transactions,
    ROUND(SUM(f.transaction_amount)::numeric, 2) AS failed_transaction_value,
    ROUND(SUM(f.net_amount)::numeric, 2) AS failed_net_revenue_impact
FROM fintech.fact_transactions f
JOIN fintech.dim_payment_method pm
    ON f.payment_method_id = pm.payment_method_id
JOIN fintech.dim_merchant m
    ON f.merchant_id = m.merchant_id
WHERE f.status = 'failed'
GROUP BY
    pm.payment_method_name,
    m.merchant_category
ORDER BY
    failed_transaction_value DESC,
    failed_transactions DESC;