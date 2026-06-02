%%writefile schema/views/vw_payment_method_performance.sql
-- Business Question:
-- Which payment methods drive volume, revenue, and have the best success and fraud performance?
-- Why This Matters:
-- Helps decide where to prioritise UX, risk controls, and commercial partnerships.
-- Decision This Informs:
-- Optimising payment mix, negotiating provider terms, and focusing reliability efforts.
-- Tables Used:
-- fintech.fact_transactions, fintech.dim_payment_method

CREATE OR REPLACE VIEW fintech.vw_payment_method_performance AS
WITH method_base AS (
    SELECT
        pm.payment_method_id,
        pm.payment_method_name,
        pm.payment_channel_type,
        pm.fee_percentage,
        COUNT(*) AS total_transactions,
        SUM(CASE WHEN f.status = 'success' THEN 1 ELSE 0 END) AS success_transactions,
        SUM(CASE WHEN f.status = 'failed' THEN 1 ELSE 0 END) AS failed_transactions,
        SUM(CASE WHEN f.is_fraud = TRUE THEN 1 ELSE 0 END) AS fraud_transactions,
        SUM(f.transaction_amount) AS gross_amount,
        SUM(f.net_amount) AS net_revenue
    FROM fintech.fact_transactions f
    JOIN fintech.dim_payment_method pm
        ON f.payment_method_id = pm.payment_method_id
    GROUP BY
        pm.payment_method_id,
        pm.payment_method_name,
        pm.payment_channel_type,
        pm.fee_percentage
)
SELECT
    payment_method_id,
    payment_method_name,
    payment_channel_type,
    fee_percentage,
    total_transactions,
    success_transactions,
    failed_transactions,
    fraud_transactions,
    gross_amount,
    net_revenue,
    ROUND(
        (100.0 * success_transactions / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS success_rate_pct,
    ROUND(
        (100.0 * failed_transactions / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS failure_rate_pct,
    ROUND(
        (100.0 * fraud_transactions / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS fraud_rate_pct,
    ROUND(
        (gross_amount / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS avg_transaction_amount,
    ROUND(
        (net_revenue / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS avg_net_revenue_per_tx
FROM method_base;