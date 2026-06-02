%%writefile schema/views/vw_monthly_kpi.sql
-- Business Question:
-- What is the total transaction volume and net revenue trend month by month?
-- Why This Matters:
-- Reveals seasonality (Diwali spikes, slowdowns) for forecasting and planning.
-- Decision This Informs:
-- Marketing spend timing, staffing, and infrastructure capacity planning.
-- Tables Used:
-- fintech.fact_transactions, fintech.dim_time

CREATE OR REPLACE VIEW fintech.vw_monthly_kpi AS
WITH monthly_base AS (
    SELECT
        t.year,
        t.month_number,
        DATE_TRUNC('month', t.full_date)::date AS month_start,
        COUNT(*) AS total_transactions,
        SUM(CASE WHEN f.status = 'success' THEN 1 ELSE 0 END) AS success_transactions,
        SUM(CASE WHEN f.status = 'failed' THEN 1 ELSE 0 END) AS failed_transactions,
        SUM(f.transaction_amount) AS gross_amount,
        SUM(f.net_amount) AS net_revenue
    FROM fintech.fact_transactions f
    JOIN fintech.dim_time t
        ON f.date_key = t.date_key
    GROUP BY
        t.year,
        t.month_number,
        DATE_TRUNC('month', t.full_date)::date
)
SELECT
    year,
    month_number,
    month_start,
    total_transactions,
    success_transactions,
    failed_transactions,
    gross_amount,
    net_revenue,
    ROUND(
        (100.0 * success_transactions / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS success_rate_pct,
    ROUND(
        (100.0 * failed_transactions / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS failure_rate_pct
FROM monthly_base;