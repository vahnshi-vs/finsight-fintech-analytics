\# FinSight Data Dictionary



\## Overview



This document describes the main data structures used in the FinSight project.



FinSight is built on a PostgreSQL warehouse in the `finsight\_analytics` database under the `fintech` schema. The model follows a star-schema design centered on transaction analytics and supports SQL analysis, Power BI reporting, and an AI-assisted query layer.



The core warehouse consists of five dimension tables and one fact table:



\- `fintech.dim\_customer`

\- `fintech.dim\_geography`

\- `fintech.dim\_merchant`

\- `fintech.dim\_payment\_method`

\- `fintech.dim\_time`

\- `fintech.fact\_transactions`



This data dictionary is written to make the project easier to understand for reviewers, recruiters, and anyone exploring the repository.



\---



\## Table: `fintech.dim\_customer`



\*\*Purpose\*\*  

Stores customer-level descriptive information used for segmentation, acquisition analysis, and customer-based reporting.



| Column Name | Data Type | Description |

|---|---|---|

| `customer\_id` | BIGINT | Unique identifier for each customer. |

| `customer\_name` | TEXT | Customer full name used in synthetic sample data. |

| `customer\_segment` | TEXT | Customer category such as Regular or Premium. |

| `acquisition\_channel` | TEXT | Channel through which the customer was acquired. |

| `kyc\_status` | TEXT | KYC verification status of the customer. |

| `signup\_date` | TIMESTAMP | Customer signup date and time. |

| `city` | TEXT | Customer city. |

| `state` | TEXT | Customer state. |

| `geography\_tier` | TEXT | Geography tier classification associated with the customer location. |



\---



\## Table: `fintech.dim\_geography`



\*\*Purpose\*\*  

Stores state-level geography information used for regional analysis and geography-tier reporting.



| Column Name | Data Type | Description |

|---|---|---|

| `geography\_id` | BIGINT | Unique identifier for each geography record. |

| `state\_name` | TEXT | Name of the state used for regional reporting. |

| `geography\_tier` | TEXT | Geography tier classification such as Tier 1, Tier 2, or Tier 3. |



\---



\## Table: `fintech.dim\_merchant`



\*\*Purpose\*\*  

Stores merchant attributes used for merchant performance, category analysis, and tier-based reporting.



| Column Name | Data Type | Description |

|---|---|---|

| `merchant\_id` | BIGINT | Unique identifier for each merchant. |

| `merchant\_name` | TEXT | Merchant name used in synthetic sample data. |

| `merchant\_category` | TEXT | Business category of the merchant. |

| `merchant\_tier` | TEXT | Merchant size or importance grouping such as Small, Medium, or Large. |

| `city` | TEXT | Merchant city. |

| `state` | TEXT | Merchant state. |

| `geography\_tier` | TEXT | Geography tier classification associated with the merchant location. |



\---



\## Table: `fintech.dim\_payment\_method`



\*\*Purpose\*\*  

Stores payment method metadata used for payment mix analysis, fee analysis, and channel performance reporting.



| Column Name | Data Type | Description |

|---|---|---|

| `payment\_method\_id` | BIGINT | Unique identifier for each payment method. |

| `payment\_method\_name` | TEXT | Payment method name such as UPI, Card, Wallet, or Net Banking. |

| `payment\_channel\_type` | TEXT | Higher-level payment channel grouping. |

| `fee\_percentage` | DOUBLE PRECISION | Fee percentage associated with the payment method. |



\---



\## Table: `fintech.dim\_time`



\*\*Purpose\*\*  

Stores calendar-related attributes used for time intelligence, monthly KPI analysis, and period-based reporting.



| Column Name | Data Type | Description |

|---|---|---|

| `date\_key` | BIGINT | Surrogate date key in `YYYYMMDD` style. |

| `full\_date` | TIMESTAMP | Full timestamp representation of the calendar date. |

| `day\_of\_week` | TEXT | Name of the weekday. |

| `week\_number` | BIGINT | Week number of the year. |

| `month\_number` | INTEGER | Numeric month value. |

| `quarter` | INTEGER | Quarter value from 1 to 4. |

| `year` | INTEGER | Calendar year. |

| `is\_weekend` | BOOLEAN | Indicates whether the date falls on a weekend. |

| `is\_public\_holiday` | BOOLEAN | Indicates whether the date is marked as a public holiday. |

| `year\_month` | BIGINT | Combined year-month key used for monthly grouping. |

| `month` | BIGINT | Month value stored as a numeric field. |



\*\*Important note\*\*  

For Power BI time-intelligence use cases, the date table should be marked correctly using the appropriate date field in the model.



\---



\## Table: `fintech.fact\_transactions`



\*\*Purpose\*\*  

Stores the transaction-level fact data used for revenue analysis, payment method analysis, fraud tracking, decline analysis, and operational reporting.



| Column Name | Data Type | Description |

|---|---|---|

| `transaction\_id` | BIGINT | Unique identifier for each transaction. |

| `date\_key` | BIGINT | Foreign key linking to `fintech.dim\_time`. |

| `customer\_id` | BIGINT | Foreign key linking to `fintech.dim\_customer`. |

| `merchant\_id` | BIGINT | Foreign key linking to `fintech.dim\_merchant`. |

| `payment\_method\_id` | BIGINT | Foreign key linking to `fintech.dim\_payment\_method`. |

| `geography\_id` | BIGINT | Foreign key linking to `fintech.dim\_geography`. |

| `transaction\_amount` | DOUBLE PRECISION | Gross transaction amount. |

| `fee\_amount` | DOUBLE PRECISION | Fee earned from the transaction. |

| `net\_amount` | DOUBLE PRECISION | Net amount retained after fee logic. |

| `status` | TEXT | Transaction outcome status. |

| `is\_fraud` | BOOLEAN | Indicates whether the transaction is flagged as fraud. |

| `processing\_time\_seconds` | INTEGER | Transaction processing time in seconds. |

| `transaction\_hour` | INTEGER | Hour of day in which the transaction occurred. |

| `decline\_category` | TEXT | Higher-level grouping of failed transaction type. |

| `decline\_reason` | TEXT | Detailed reason for the failed transaction. |



\---



\## Relationship summary



The FinSight warehouse follows a star-schema structure where `fintech.fact\_transactions` is the central fact table and the dimension tables connect to it through the following keys:



\- `fact\_transactions.date\_key` → `dim\_time.date\_key`

\- `fact\_transactions.customer\_id` → `dim\_customer.customer\_id`

\- `fact\_transactions.merchant\_id` → `dim\_merchant.merchant\_id`

\- `fact\_transactions.payment\_method\_id` → `dim\_payment\_method.payment\_method\_id`

\- `fact\_transactions.geography\_id` → `dim\_geography.geography\_id`



This structure supports reporting across time, customer, merchant, payment method, and geography dimensions.



\---



\## Analytical views included in the project



The project also includes the following analytical views inside the `fintech` schema:



\- `fintech.vw\_acquisition\_channel\_roi`

\- `fintech.vw\_customer\_cohort\_retention`

\- `fintech.vw\_customer\_ltv`

\- `fintech.vw\_customer\_segment\_performance`

\- `fintech.vw\_fact\_transactions\_enriched`

\- `fintech.vw\_fraud\_geographic\_summary`

\- `fintech.vw\_merchant\_category\_seasonality`

\- `fintech.vw\_monthly\_kpi`

\- `fintech.vw\_payment\_method\_performance`

\- `fintech.vw\_upi\_decline\_analysis`



These views are used to simplify repeated business analysis and support both SQL and BI reporting layers.



\---



\## Closing note



This data dictionary is intended to make the FinSight project easier to review and understand.



It documents the warehouse structure clearly, keeps the naming aligned with the actual PostgreSQL schema, and supports the project’s goal of presenting a realistic and well-organized fintech analytics portfolio project.

