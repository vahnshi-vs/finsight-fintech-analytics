%%writefile schema/views/vw_fraud_geographic_summary.sql
-- Business Question:
-- Where is fraud concentrated geographically and how does fraud rate vary by city tier?
-- Why This Matters:
-- Identifies fraud hotspots so risk teams can focus controls where losses are highest.
-- Decision This Informs:
-- Geo-level fraud monitoring, controls, and escalation priority.
-- Tables Used:
-- fintech.fact_transactions, fintech.dim_customer, fintech.dim_geography

CREATE OR REPLACE VIEW fintech.vw_fraud_geographic_summary AS
WITH geo_base AS (
    SELECT
        g.state_name,
        g.geography_tier,
        COUNT(*) AS total_transactions,
        SUM(CASE WHEN f.is_fraud = TRUE THEN 1 ELSE 0 END) AS fraud_transactions,
        SUM(f.transaction_amount) AS gross_amount,
        SUM(CASE WHEN f.is_fraud = TRUE THEN f.transaction_amount ELSE 0 END) AS fraud_amount
    FROM fintech.fact_transactions f
    JOIN fintech.dim_geography g
        ON f.geography_id = g.geography_id
    GROUP BY
        g.state_name,
        g.geography_tier
)
SELECT
    state_name,
    geography_tier,
    total_transactions,
    fraud_transactions,
    gross_amount,
    fraud_amount,
    ROUND(
        (100.0 * fraud_transactions / NULLIF(total_transactions, 0))::numeric,
        2
    ) AS fraud_rate_pct,
    ROUND(
        (100.0 * fraud_amount / NULLIF(gross_amount, 0))::numeric,
        2
    ) AS fraud_amount_share_pct
FROM geo_base
ORDER BY
    fraud_rate_pct DESC,
    fraud_amount DESC,
    total_transactions DESC;