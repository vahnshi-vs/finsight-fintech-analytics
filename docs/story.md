\# FinSight: Why I Built This Project



FinSight started with a simple idea.



In digital payments, companies usually do not struggle because they lack data. They struggle because useful answers are buried inside too many transactions, too many failure cases, and too many disconnected business questions.



When I planned this project, I did not want to build a generic dashboard project with random charts and a clean title. I wanted to build something that felt closer to a real analytics problem, especially in an Indian fintech setting where transaction volume is high, payment behavior is uneven, and failed payments can mean very different things depending on the reason behind them.



That is what FinSight is built around.



\## The business context



FinSight is designed around a digital payments company that processes UPI, cards, wallets, and net banking transactions across India.



In that kind of business, the raw data is available, but answering simple questions is not always simple. A team may want to know why revenue changed, why one payment mode is failing more than another, which merchants are contributing the most value, where fraud is starting to concentrate, or whether customer segments are performing the way the business expects.



These questions matter because they are tied to real decisions. If a payment method is creating friction, that affects customer experience and conversion. If a merchant segment is weakening, that affects revenue planning. If fraud is rising in a specific pattern, waiting too long to notice it can become expensive.



\## What I wanted this project to do



The goal of FinSight was to turn that kind of messy business situation into a structured analytics project.



Instead of keeping the work at the level of raw tables, I wanted the project to show how a transaction dataset could be modeled, explored, and reported in a way that supports decision-making. That is why the project brings together a PostgreSQL warehouse structure, analytical SQL, Power BI reporting, and an AI-assisted query layer as part of the broader project direction.



The focus was not only on building tables. It was on building a system that makes business analysis easier to repeat, easier to explain, and easier to trust.



\## What makes FinSight more realistic



One thing I cared about from the beginning was making sure the project did not feel flat.



A lot of portfolio projects are technically fine, but the data inside them feels random. The charts work, but the business story does not. For FinSight, I wanted the patterns to feel believable enough that the analysis would look like something a real payments team might actually review.



That is why the project is centered on business themes such as revenue trends, payment method performance, customer segments, merchant behavior, geography patterns, fraud signals, and failed transactions.



The most important differentiator in the project is decline intelligence through `decline\_category` and `decline\_reason`. That part matters because not every failed transaction means the same thing. Some declines may point to technical friction and possible recovery opportunities. Others are business-side failures that need a different response. That distinction gives the analysis more depth and makes the project more useful than a basic transaction reporting dashboard.



\## The reporting problem behind it



At a practical level, FinSight is really about reducing reporting friction.



Business teams should not have to keep rebuilding the same analysis manually just to understand monthly movement, payment failures, fraud patterns, or merchant contribution. If the data model is designed properly, the same system should support repeated business questions much more efficiently.



That is the problem this project tries to address.



It is meant to support recurring analysis such as tracking revenue over time, comparing payment methods, studying customer and merchant performance, reviewing decline patterns, and identifying areas where losses or risk may be building quietly.



\## Why this project matters in my portfolio



This is an important project for me because it represents more than one tool or one task.



It brings together SQL, data modeling, business thinking, reporting, and AI-assisted analytics in one connected project. More importantly, it reflects the kind of work I want to be associated with as a beginner data analyst: work that is not only technical, but also useful, structured, and business-aware.



I also wanted this project to be strong enough for interview discussions. A good portfolio project should make it easier to explain not just what was built, but why it was built that way, what problems it tries to solve, and what trade-offs were involved.



\## What the project is meant to become



The long-term idea behind FinSight is straightforward.



It should allow important business questions to be answered in multiple ways: through analytical SQL, through Power BI dashboards, and through a guided natural language experience for users who are not comfortable writing queries directly.



That broader direction is part of what makes the project interesting to me. It is not just a collection of files. It is an attempt to build a more complete analytics workflow around a fintech use case.



FinSight is ultimately a project about making transaction data easier to understand, easier to question, and easier to use for decisions.

