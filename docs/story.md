FinSight is a fintech transaction analytics warehouse built for the head of growth at a mid-size Indian digital payments company. The problem it solves is the manual Monday morning work of pulling data from multiple spreadsheets to answer the same business questions again and again.

This project gives the team a PostgreSQL star schema warehouse, a Power BI executive dashboard, and a Gemini-powered natural language query app. The business impact is faster reporting, less manual work, and easy access to data for non-technical decision makers.

A unique feature of FinSight is UPI decline analysis. It separates technical declines such as bank timeout or gateway error from business declines such as wrong PIN, insufficient funds, or user cancellation. This helps the head of growth understand whether a drop in transactions is caused by a product, bank, or customer issue.

FinSight also includes guardrails for AI-generated answers. The Gemini layer does not directly invent business numbers. It generates SQL, the SQL is validated, the query runs against PostgreSQL, and only then is the result summarized in plain English. This reduces hallucination risk and makes the system more enterprise-ready.

The one problem this project solves is repetitive manual reporting.
The person it solves it for is the growth head of a mid-size Indian payments company.
Success means that person can open the dashboard on Monday morning and get trustworthy answers instantly without waiting for the data team.