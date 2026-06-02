
CREATE TABLE fintech.fact_transactions (
    transaction_id bigint,
    date_key bigint,
    customer_id bigint,
    merchant_id bigint,
    payment_method_id bigint,
    geography_id bigint,
    transaction_amount double precision,
    fee_amount double precision,
    net_amount double precision,
    status text,
    is_fraud boolean,
    processing_time_seconds integer,
    transaction_hour integer,
    decline_category text,
    decline_reason text
);

