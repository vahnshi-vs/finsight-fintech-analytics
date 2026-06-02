-- Business Question: What percentage of UPI failure revenue loss is technically recoverable through retry mechanisms versus requiring business intervention, and which specific decline reasons and hours of day show the highest concentration of technical failures?
-- Why This Matters: Separates recoverable failure losses from non-recoverable losses and prioritizes fixes.
-- Decision This Informs: Retry strategy, bank/gateway escalation, and UPI failure recovery planning.
-- Tables Used: fintech.fact_transactions, fintech.dim_payment_method, fintech.dim_time

WITH upi_failures AS (
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
    FROM upi_failures
    GROUP BY
        decline_category
),
overall_total AS (
    SELECT SUM(failed_amount) AS total_failed_amount
    FROM upi_failures
)
SELECT
    u.transaction_hour,
    u.decline_category,
    u.decline_reason,
    ROUND(u.failed_amount::numeric, 2) AS failed_amount,
    ROUND(
        (100.0 * c.category_failed_amount / NULLIF(o.total_failed_amount, 0))::numeric,
        2
    ) AS category_share_pct_of_upi_failed_amount,
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
FROM upi_failures u
JOIN category_totals c
    ON u.decline_category = c.decline_category
CROSS JOIN overall_total o
ORDER BY
    u.decline_category,
    u.failed_amount DESC,
    u.transaction_hour;