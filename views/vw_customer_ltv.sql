
%%writefile
sql/views/vw_customer_ltv.sql
-- Business Question: What is the lifetime value, transaction frequency, average transaction value, and recency for every customer and how do they rank?
-- Why This Matters: Identifies high-value customers for retention programs and helps segment customers by engagement and spending patterns.
-- Decision This Informs: Customer retention strategy, VIP programs, re-engagement campaigns for dormant customers, and personalized offers based on LTV tiers.
-- Tables Used: fact_transactions, dim_customer, dim_time

CREATE OR REPLACE VIEW fintech.vw_customer_ltv AS

WITH customer_metrics AS (
    SELECT 
        ft.customer_id,
        dc.customer_segment,
        dc.acquisition_channel,
        dc.geography_tier,
        SUM(ft.net_amount) AS total_revenue,
        COUNT(ft.transaction_id) AS transaction_count,
        AVG(ft.net_amount) AS avg_transaction_value,
        MIN(dt.full_date) AS first_transaction_date,
        MAX(dt.full_date) AS last_transaction_date,
        CURRENT_DATE - MAX(dt.full_date) AS days_since_last_transaction
    FROM fintech.fact_transactions ft
    INNER JOIN fintech.dim_customer dc ON ft.customer_id = dc.customer_id
    INNER JOIN fintech.dim_time dt ON ft.date_key = dt.date_key
    WHERE ft.status = 'success'
    GROUP BY ft.customer_id, dc.customer_segment, dc.acquisition_channel, dc.geography_tier
)

SELECT 
    customer_id,
    customer_segment,
    acquisition_channel,
    geography_tier,
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    transaction_count,
    ROUND(avg_transaction_value::numeric, 2) AS avg_transaction_value,
    first_transaction_date,
    last_transaction_date,
    days_since_last_transaction,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    CASE 
        WHEN total_revenue >= 50000 THEN 'High Value'
        WHEN total_revenue >= 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS ltv_segment
FROM customer_metrics
ORDER BY total_revenue DESC;