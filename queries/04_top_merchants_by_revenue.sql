-- Business Question: Which are the top 20 merchants by net revenue and what categories and tiers do they belong to?
-- Why This Matters: Identifies the highest-value merchants driving platform revenue.
-- Decision This Informs: Merchant account focus, partnership planning, and retention strategy.
-- Tables Used: fintech.fact_transactions, fintech.dim_merchant

SELECT
    m.merchant_name,
    m.merchant_category,
    m.merchant_tier,
    m.city,
    m.state,
    ROUND(SUM(f.net_amount)::numeric, 2) AS total_net_revenue,
    COUNT(*) AS transaction_count
FROM fintech.fact_transactions f
JOIN fintech.dim_merchant m
    ON f.merchant_id = m.merchant_id
GROUP BY
    m.merchant_name,
    m.merchant_category,
    m.merchant_tier,
    m.city,
    m.state
ORDER BY
    total_net_revenue DESC
LIMIT 20;