# FinSight Limitations

## Why this file exists

FinSight is designed as a serious portfolio project, but it is still a portfolio project.

This file exists to document the boundaries of the project honestly. A good analytics project should not only show what was built well. It should also make clear what has been simplified, what is still prototype-level, and what would need more work in a production setting.

## Current limitations

### 1. The data is synthetic

The project uses generated data shaped to reflect realistic fintech behavior, but it is not real production data.

That means the project is useful for demonstrating warehouse design, SQL analysis, reporting, and business reasoning, but it does not include the full messiness of live transaction systems, real operational exceptions, or institution-specific edge cases.

### 2. The warehouse scope is intentionally limited

FinSight focuses on a clean analytics model using the `fintech` schema and the core tables `dim_customer`, `dim_geography`, `dim_merchant`, `dim_payment_method`, `dim_time`, and `fact_transactions`.

This is enough for a strong analytics portfolio project, but it is still a simplified warehouse compared with a real fintech environment. A real production system would likely include more entities related to settlements, reversals, disputes, device signals, reconciliation, audit records, operational logs, and pipeline monitoring.

### 3. The project is business-realistic, but not company-specific

The project is designed around a believable Indian digital payments use case, but it is not modeled on the internal systems of any one real company.

That means the business logic is representative rather than institution-specific. The project is meant to show analytical thinking and domain awareness, not to reproduce a real company’s internal data environment.

### 4. The Power BI layer is a portfolio reporting layer

The Power BI report is built to show analytical storytelling, dashboard design, and business reporting structure.

It should not be confused with a fully governed enterprise BI setup. A production BI environment would require stronger controls around refresh strategy, semantic governance, workspace management, security, user access, and deployment standards.

### 5. The AI layer should be treated as a practical prototype

The Streamlit and Gemini query interface adds a strong differentiator to the project, but it should still be described honestly.

It is best treated as a prototype-style natural language analytics layer rather than a production-ready assistant. In practice, model usage limits, prompt behavior, SQL generation consistency, and validation depth all affect how reliable such a layer can be in a real environment.

### 6. Safe-query handling can still be improved

The project direction includes SQL validation before execution, which is the correct design approach.

Even so, a stronger production version would need tighter control over query generation, stricter read-only enforcement, better guardrails for ambiguous prompts, stronger logging, and more defensive handling of unexpected model output.

### 7. Performance evidence is meaningful, but limited by project scale

The project includes schema design, views, and index-related verification, but the size of the data is still portfolio-scale.

This means performance checks are useful as evidence of database awareness, but they should not be treated as the same thing as large-scale performance engineering under heavy concurrency or very large transactional workloads.

### 8. The project is portfolio-ready, not production-ready

FinSight is strong as an end-to-end analytics portfolio project.

At the same time, it is not intended to claim full production readiness. A production-grade system would still need stronger testing, deployment controls, monitoring, access management, backup design, and operational ownership.

## Why these limitations do not weaken the project

These limitations are normal and acceptable for the scope of this project.

For a beginner data analyst portfolio, FinSight still demonstrates strong fundamentals across PostgreSQL, SQL analysis, Power BI reporting, business thinking, and AI-assisted exploration. Stating the limitations clearly makes the project more credible and more professional.

## Closing note

A portfolio project becomes stronger when it is honest about its scope.

FinSight does not need to pretend to be a full enterprise fintech platform. It only needs to show sound structure, useful analysis, clear business reasoning, and an understanding of where the boundaries are.