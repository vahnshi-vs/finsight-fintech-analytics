
CREATE TABLE fintech.dim_time (
    date_key bigint,
    full_date timestamp without time zone,
    day_of_week text,
    week_number bigint,
    month_number integer,
    quarter integer,
    year integer,
    is_weekend boolean,
    is_public_holiday boolean,
    year_month bigint,
    month bigint
);

