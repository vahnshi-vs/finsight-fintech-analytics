%%writefile schema/views/vw_upi_decline_analysis.sql
-- Business Question:
-- What percentage of UPI failure revenue loss is technically recoverable versus business-driven,
-- and which decline reasons and hours show the highest concentration?
-- Why This Matters:
-- Quantifies recoverable revenue and pinpoints where to fix UPI reliability.
-- Decision This Informs:
-- Retry strategies, bank/gateway discussions, and product changes for UPI flows.
-- Tables Used:
-- fintech.fact_transactions, fintech.dim_payment_method

CREATE OR REPLACE VIEW fintech.vw_upi_decline_analysis AS
WITH upi_failed AS (
    SELECT
        f.transaction_hour,
        f.decline_category,
        f.decline_reason,
        SUM(f.transaction_amount) AS failed_amount
    FROM fintech.fact_transactions f
    JOIN fintech.dim_payment_method pm
        ON f.payment_method_id = pm.payment_method_id
    WHERE pm.payment_method_name = 'UPI'
      AND f.status = 'failed'
    GROUP BY
        f.transaction_hour,
        f.decline_category,
        f.decline_reason
),
category_totals AS (
    SELECT
        decline_category,
        SUM(failed_amount) AS category_failed_amount
    FROM upi_failed
    GROUP BY
        decline_category
),
overall_total AS (
    SELECT
        SUM(failed_amount) AS total_failed_amount
    FROM upi_failed
)
SELECT
    u.transaction_hour,
    u.decline_category,
    u.decline_reason,
    ROUND(u.failed_amount::numeric, 2) AS failed_amount,
    ROUND(
        (100.0 * u.failed_amount / NULLIF(o.total_failed_amount, 0))::numeric,
        2
    ) AS share_of_upi_failed_amount_pct,
    ROUND(
        (100.0 * c.category_failed_amount / NULLIF(o.total_failed_amount, 0))::numeric,
        2
    ) AS category_share_of_upi_failed_amount_pct,
    ROUND(
        (
            100.0 * SUM(
                CASE WHEN u.decline_category = 'technical'
                     THEN u.failed_amount
                     ELSE 0
                END
            ) OVER ()
            / NULLIF(o.total_failed_amount, 0)
        )::numeric,
        2
    ) AS technical_recoverable_share_pct
FROM upi_failed u
JOIN category_totals c
    ON u.decline_category = c.decline_category
CROSS JOIN overall_total o
ORDER BY
    u.decline_category,
    u.failed_amount DESC,
    u.transaction_hour;