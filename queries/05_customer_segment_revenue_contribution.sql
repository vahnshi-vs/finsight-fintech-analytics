-- Business Question: What percentage of total net revenue does each customer segment contribute?
-- Why This Matters: Reveals which customer groups create disproportionate value.
-- Decision This Informs: Retention, upsell, and segmentation strategy.
-- Tables Used: fintech.fact_transactions, fintech.dim_customer

WITH segment_revenue AS (
    SELECT
        c.customer_segment,
        SUM(f.net_amount) AS segment_net_revenue
    FROM fintech.fact_transactions f
    JOIN fintech.dim_customer c
        ON f.customer_id = c.customer_id
    GROUP BY
        c.customer_segment
),
total_revenue AS (
    SELECT SUM(net_amount) AS overall_net_revenue
    FROM fintech.fact_transactions
)
SELECT
    s.customer_segment,
    ROUND(s.segment_net_revenue::numeric, 2) AS segment_net_revenue,
    ROUND(
        (100.0 * s.segment_net_revenue / NULLIF(t.overall_net_revenue, 0))::numeric,
        2
    ) AS revenue_share_pct
FROM segment_revenue s
CROSS JOIN total_revenue t
ORDER BY
    revenue_share_pct DESC;