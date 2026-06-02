CREATE TABLE fintech.dim_customer (
    customer_id bigint,
    customer_name text,
    customer_segment text,
    acquisition_channel text,
    kyc_status text,
    signup_date timestamp without time zone,
    city text,
    state text,
    geography_tier text
);
