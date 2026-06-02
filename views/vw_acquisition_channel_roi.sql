%%writefile 
schema/views/vw_acquisition_channel_roi.sql
-- Business Question: Which acquisition channel delivers better long-term value comparing 6-month revenue per customer, retention rate, and transaction frequency?
-- Why This Matters: Helps the growth team decide which acquisition channels to invest in based on actual customer lifetime value and behavior, not just acquisition cost.
-- Decision This Informs: Marketing budget allocation across Organic, Referral, Paid-Google, Paid-Meta, and Email channels with ROI calculation.
-- Tables Used: fact_transactions, dim_customer, dim_time

CREATE OR REPLACE VIEW fintech.vw_acquisition_channel_roi AS

WITH customer_first_transaction AS (
    SELECT 
        ft.customer_id,
        MIN(dt.full_date) AS first_transaction_date,
        dc.acquisition_channel
    FROM fintech.fact_transactions ft
    INNER JOIN fintech.dim_time dt ON ft.date_key = dt.date_key
    INNER JOIN fintech.dim_customer dc ON ft.customer_id = dc.customer_id
    WHERE ft.status = 'success'
    GROUP BY ft.customer_id, dc.acquisition_channel
),

six_month_metrics AS (
    SELECT 
        cft.customer_id,
        cft.acquisition_channel,
        SUM(ft.net_amount) AS revenue_6m,
        COUNT(ft.transaction_id) AS transaction_count_6m,
        MAX(dt.full_date) AS last_transaction_date
    FROM customer_first_transaction cft
    INNER JOIN fintech.fact_transactions ft ON cft.customer_id = ft.customer_id
    INNER JOIN fintech.dim_time dt ON ft.date_key = dt.date_key
    WHERE ft.status = 'success'
      AND dt.full_date BETWEEN cft.first_transaction_date 
                           AND cft.first_transaction_date + INTERVAL '6 months'
    GROUP BY cft.customer_id, cft.acquisition_channel
),

channel_aggregates AS (
    SELECT 
        acquisition_channel,
        COUNT(DISTINCT customer_id) AS total_customers,
        AVG(revenue_6m) AS avg_revenue_per_customer_6m,
        AVG(transaction_count_6m) AS avg_transactions_per_customer_6m,
        COUNT(DISTINCT CASE 
            WHEN last_transaction_date >= (
                SELECT MIN(first_transaction_date) + INTERVAL '6 months' 
                FROM customer_first_transaction
            ) 
            THEN customer_id 
        END) AS retained_customers_6m
    FROM six_month_metrics
    GROUP BY acquisition_channel
),

costs AS (
    SELECT 
        acquisition_channel,
        CASE 
            WHEN acquisition_channel = 'Organic' THEN 20
            WHEN acquisition_channel = 'Referral' THEN 20
            WHEN acquisition_channel IN ('Paid-Google', 'Paid-Meta') THEN 150
            WHEN acquisition_channel = 'Email' THEN 50
            ELSE 100
        END AS cost_per_customer
    FROM (SELECT DISTINCT acquisition_channel FROM fintech.dim_customer) channels
)

SELECT 
    ca.acquisition_channel,
    ca.total_customers,
    ROUND(ca.avg_revenue_per_customer_6m::numeric, 2) AS six_month_revenue_per_customer,
    ROUND(ca.avg_transactions_per_customer_6m::numeric, 2) AS avg_transactions_per_customer,
    ROUND((ca.retained_customers_6m::numeric / NULLIF(ca.total_customers, 0)) * 100, 2) AS retention_rate_6m,
    c.cost_per_customer,
    ROUND((ca.avg_revenue_per_customer_6m::numeric / NULLIF(c.cost_per_customer, 0)), 2) AS revenue_per_rupee_spent
FROM channel_aggregates ca
INNER JOIN costs c ON ca.acquisition_channel = c.acquisition_channel
ORDER BY revenue_per_rupee_spent DESC;