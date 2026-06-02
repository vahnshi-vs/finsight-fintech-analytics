# FinSight Insights Report

## Project context

FinSight is a fintech transaction analytics project built around an Indian digital payments business use case. The project uses a PostgreSQL warehouse in the `fintech` schema, supported by analytical SQL, Power BI reporting, and an AI-assisted query layer.

The analysis is centered on six core tables:

- `fintech.dim_customer`
- `fintech.dim_geography`
- `fintech.dim_merchant`
- `fintech.dim_payment_method`
- `fintech.dim_time`
- `fintech.fact_transactions`

The project also uses analytical views including:

- `fintech.vw_acquisition_channel_roi`
- `fintech.vw_customer_cohort_retention`
- `fintech.vw_customer_ltv`
- `fintech.vw_customer_segment_performance`
- `fintech.vw_fact_transactions_enriched`
- `fintech.vw_fraud_geographic_summary`
- `fintech.vw_merchant_category_seasonality`
- `fintech.vw_monthly_kpi`
- `fintech.vw_payment_method_performance`
- `fintech.vw_upi_decline_analysis`

This report captures the key business insights that FinSight is designed to surface.

## Key business findings

### 1. Revenue trends are more useful when seen as a pattern, not as a single number

In a payments business, one revenue figure on its own does not say much. The more useful view is how transaction value, fee generation, and net revenue change over time.

That is why the project includes time-based analysis through `dim_time` and monthly aggregation through `vw_monthly_kpi`. Looking at revenue as a trend makes it easier to identify whether business movement is stable, seasonal, slowing, or improving.

### 2. Payment method performance is not just about volume

A payment method can have strong usage and still create business problems. It may have weaker success behavior, higher friction, lower fee quality, or more failure concentration.

This is why FinSight treats payment method analysis as a performance question, not just a market share question. Using `dim_payment_method` and `vw_payment_method_performance`, the project supports analysis of which channels appear healthy and which may be adding hidden operational cost.

### 3. Decline intelligence is the strongest analytical feature in the project

The most distinctive part of FinSight is the way failed transactions are treated. Instead of keeping all failed payments in one bucket, the project uses `decline_category` and `decline_reason` from `fact_transactions` to make decline analysis more meaningful.

This is important because not every failed transaction means the same thing. Some failures suggest technical friction and possible recovery opportunity, while others point to business-side or user-side causes that need a different response.

That difference makes the analysis more useful for real decision-making and gives the project a stronger business identity than a standard transaction dashboard.

### 4. Fraud becomes more actionable when combined with geography and transaction behavior

Fraud analysis is weak when it is reduced to a single percentage. It becomes much more useful when it is studied with other dimensions such as geography, transaction timing, and transaction patterns.

FinSight supports this through `is_fraud` in `fact_transactions` and through `vw_fraud_geographic_summary`. This allows the project to move from basic fraud reporting into more operational questions such as where fraud appears more concentrated and what patterns are more likely to be associated with it.

### 5. Customer value is more important than customer count

A high number of customers does not automatically mean strong business quality. Some customer segments contribute more value, stay active for longer, or behave differently across payment patterns.

That is why the project includes customer-focused analysis through `dim_customer`, `vw_customer_segment_performance`, `vw_customer_ltv`, and `vw_customer_cohort_retention`. This supports a more realistic view of customer performance by looking at segment contribution, long-term value, and retention behavior instead of just signup or volume counts.

### 6. Merchant analysis should go beyond leaderboard thinking

A simple top-merchants chart is useful, but limited. Merchant analysis becomes more meaningful when it is studied alongside category, tier, seasonality, and transaction quality.

Using `dim_merchant`, `vw_merchant_category_seasonality`, and `vw_fact_transactions_enriched`, FinSight makes it easier to look at merchant behavior in a way that is closer to business review logic. This helps show not only which merchants are large, but which merchant groups appear stronger, weaker, more seasonal, or potentially more risky.

### 7. Geography adds real business depth to the project

The presence of `dim_geography` gives the project more business realism. Geography matters because transaction quality, fraud concentration, and payment behavior are rarely distributed evenly.

State-level and geography-tier analysis make the project feel closer to a real operating environment. This is especially useful in an Indian fintech context, where regional variation can matter for both growth and risk.

## Why these insights matter

The purpose of FinSight is not just to display charts or write SQL queries. The real purpose is to show how a structured analytics workflow can answer recurring business questions more clearly and more consistently.

The project demonstrates that one warehouse model can support multiple types of analysis: executive KPI tracking, payment method review, fraud investigation, decline analysis, customer contribution analysis, and merchant performance monitoring.

That is what makes the project strong from a portfolio perspective. It connects technical work to business use.

## Closing note

FinSight is strongest when it is viewed as a decision-support analytics project rather than only as a dashboard project.

The project shows how transaction data can be structured into a repeatable analysis workflow using PostgreSQL, analytical SQL, Power BI, and an AI-assisted interface. The biggest strength of the project is that it treats fintech analytics as a business problem that needs interpretation, not just visualization.