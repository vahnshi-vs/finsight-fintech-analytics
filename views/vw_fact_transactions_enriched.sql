%%writefile schema/views/vw_fact_transactions_enriched.sql
-- Business Question:
-- How can analysts and BI tools query transactions with all key dimensions in one place?
-- Why This Matters:
-- Eliminates repeated JOIN logic and speeds up analysis and report building.
-- Decision This Informs:
-- All downstream questions about customers, merchants, payment methods, time, and geography.
-- Tables Used:
-- fintech.fact_transactions,
-- fintech.dim_time,
-- fintech.dim_customer,
-- fintech.dim_merchant,
-- fintech.dim_payment_method,
-- fintech.dim_geography

CREATE OR REPLACE VIEW fintech.vw_fact_transactions_enriched AS
SELECT
    -- Fact fields
    f.transaction_id,
    f.date_key,
    f.customer_id,
    f.merchant_id,
    f.payment_method_id,
    f.geography_id,
    f.transaction_amount,
    f.fee_amount,
    f.net_amount,
    f.status,
    f.is_fraud,
    f.processing_time_seconds,
    f.transaction_hour,
    f.decline_category,
    f.decline_reason,

    -- Time dimension
    t.full_date,
    t.year,
    t.month_number,
    t.month,
    t.week_number,
    t.day_of_week,
    t.is_weekend,
    t.is_public_holiday,
    t.year_month,

    -- Customer dimension
    c.customer_name,
    c.customer_segment,
    c.acquisition_channel,
    c.kyc_status,
    c.signup_date AS customer_signup_date,
    c.city AS customer_city,
    c.state AS customer_state,
    c.geography_tier AS customer_geography_tier,

    -- Merchant dimension
    m.merchant_name,
    m.merchant_category,
    m.merchant_tier,
    m.city AS merchant_city,
    m.state AS merchant_state,
    m.geography_tier AS merchant_geography_tier,

    -- Payment method dimension
    pm.payment_method_name,
    pm.payment_channel_type,
    pm.fee_percentage,

    -- Geography dimension (state-level)
    g.state_name AS geo_state_name,
    g.geography_tier AS geo_geography_tier
FROM fintech.fact_transactions f
JOIN fintech.dim_time t
    ON f.date_key = t.date_key
JOIN fintech.dim_customer c
    ON f.customer_id = c.customer_id
JOIN fintech.dim_merchant m
    ON f.merchant_id = m.merchant_id
JOIN fintech.dim_payment_method pm
    ON f.payment_method_id = pm.payment_method_id
JOIN fintech.dim_geography g
    ON f.geography_id = g.geography_id;