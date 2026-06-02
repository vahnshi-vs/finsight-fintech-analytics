%%writefile schema/views/vw_customer_segment_performance.sql
-- Business Question:
-- What percentage of total net revenue does each customer segment contribute?
-- Why This Matters:
-- Reveals which customer groups create the most value and where retention focus should go.
-- Decision This Informs:
-- Segment targeting, loyalty strategy, and growth prioritisation.
-- Tables Used:
-- fintech.fact_transactions, fintech.dim_customer

CREATE OR REPLACE VIEW fintech.vw_customer_segment_performance AS
WITH segment_base AS (
    SELECT
        c.customer_segment,
        COUNT(*) AS total_transactions,
        COUNT(DISTINCT f.customer_id) AS active_customers,
        SUM(f.transaction_amount) AS gross_amount,
        SUM(f.net_amount) AS net_revenue,
        AVG(f.transaction_amount) AS avg_transaction_amount,
        AVG(f.net_amount) AS avg_net_amount
    FROM fintech.fact_transactions f
    JOIN fintech.dim_customer c
        ON f.customer_id = c.customer_id
    GROUP BY
        c.customer_segment
),
segment_total AS (
    SELECT SUM(net_revenue) AS total_net_revenue
    FROM segment_base
)
SELECT
    s.customer_segment,
    s.total_transactions,
    s.active_customers,
    s.gross_amount,
    s.net_revenue,
    ROUND(
        (100.0 * s.net_revenue / NULLIF(t.total_net_revenue, 0))::numeric,
        2
    ) AS revenue_share_pct,
    ROUND(s.avg_transaction_amount::numeric, 2) AS avg_transaction_amount,
    ROUND(s.avg_net_amount::numeric, 2) AS avg_net_amount
FROM segment_base s
CROSS JOIN segment_total t
ORDER BY
    s.net_revenue DESC,
    s.total_transactions DESC;