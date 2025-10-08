# 📦 Ecommerce SQL Portfolio

*A Product Analytics case study series*

A complete **SQL-driven analytics portfolio** exploring real e-commerce product and growth questions.
Built in **MySQL / MySQL Workbench**, this repo shows how a **Product Data Scientist / Analyst** translates web sessions, funnels and orders into **channel, conversion, monetisation and retention** insights.

> Repo root with `docs/` and `sql/` folders, plus MIT licence. ([GitHub][1])

---

## 🧭 Overview

This project turns raw clickstream and transactional data into decisions:

* **Acquisition**: channel mix, brand vs non-brand, device splits
* **Conversion**: bounce, CTR, CVR, billing/lander tests
* **Monetisation**: AOV, RPS, margin, cross-sell
* **Product**: pathing, funnels, expansion, refunds
* **Retention**: new vs repeat behaviour and value
* **Growth**: volume and efficiency trends; seasonality & business patterns

---

## 🎯 Objective

Demonstrate the ability to:

* Define and implement **business-critical metrics** in SQL
* Structure analyses around **clear product/business questions**
* Present **insights + recommendations** with stakeholder-friendly narratives

---

## 🧱 Data Model (summary)

* **website_sessions** — visit-level data (UTM, device, timestamps)
* **website_pageviews** — page-level behaviour across funnels
* **orders / order_items** — transactions, product mix, pricing & COGS
* **products** — catalogue
* **order_item_refunds** — quality/refund performance

Full schema lives in `docs/` (see `schema.md`). ([GitHub][1])

---

## 📊 Metrics Framework

Plain-English KPI definitions used across the case studies:
[`docs/metrics_catalog.md`](docs/metrics_catalog.md)

---

## 🧠 Case Study Index


1. **Traffic & Channel Portfolio**

   * Analysis of session trends by traffic source — including traffic splits (paid vs organic vs direct), brand vs non-brand campaigns, and device mix.
   * Using SQL to trace how traffic acquisition evolves and to reveal which channels should be prioritised.

   * [`sql/01_traffic_analysis/case_studies.md`](sql/01_traffic_analysis/case_studies.md)
   
2. **Website & Funnel Performance**

   * Analysis of pageview behavior, bounce metrics, and landing page effectiveness.
   * Shows how user engagement on the site correlates to conversion, and highlights key page-level performance levers businesses should monitor.

   * [`sql/02_website_performance/case_studies.md`](sql/02_website_performance/case_studies.md)
   
3. **Channel Performance & Bid Strategy**

   * Examine comparative traffic and conversion by source (gsearch, bsearch), including brand vs nonbrand splits and device-level trends.
   * Use SQL to uncover which channels deliver efficient volume and where bid allocation should be refined.

   * [`sql/03_channel_analysis/case_studies.md`](sql/03_channel_analysis/case_studies.md)
   
4. **Traffic & Order Patterns Over Time**

   * Analyse seasonal, weekly, and hourly trends in sessions and orders—identifying recurring patterns, peaks, and dips.
   * Demonstrates how businesses can plan capacity, staffing, and campaigns around predictable behavior cycles.

   * [`sql/04_business_patterns_and_seasonality/case_studies.md`](sql/04_business_patterns_and_seasonality/case_studies.md)
   
5. **Product & Portfolio Analytics**

   * Deep dive into product-level performance: revenue, margin, pathing, cross-sell behaviour, and refund dynamics.
   * Demonstrates how SQL can uncover product ROI, upsell potential, and risk in the catalogue.

   * [`sql/05_product_level_analysis/case_studies.md`](sql/05_product_level_analysis/case_studies.md)
   
6. **User Behaviour & Retention**

   * Compare conversion, revenue, and channel attribution for new vs repeat sessions.
   * Analyse how returning users convert and where they come back from.
   * Highlights how user-level metrics strengthen retention narratives and inform growth tactics.

   * [`sql/06_user_level_analysis/case_studies.md`](sql/06_user_level_analysis/case_studies.md)
   
   
**Mid-Course Growth & Search Analysis**

   * Monthly/session trends for sessions and orders by Google Search (brand vs nonbrand), and device splits within nonbrand.
   * Demonstrates how traffic segmentation and device analysis can test assumptions about campaign efficacy mid-project.

   * [`sql/midcourse_project/case_studies.md`](sql/midcourse_project/case_studies.md)
   
**Comprehensive Growth Narrative & Strategic Insights**

   * This conclusive case study weaves together earlier analyses into a holistic growth story — pulling together traffic, conversion, product mix, and revenue uplift experiments (lander, billing tests) to forecast future opportunity.
   * Demonstrates how to build a data narrative: from queries to insights to strategic recommendations.

   * [`sql/final_project/case_studies.md`](sql/final_project/case_studies.md)

---

## 🗂 Repository Map

```
ecommerce-sql-portfolio/
├─ README.md
├─ LICENSE                # MIT
├─ .gitignore
├─ docs/                  # schema, metrics, case studies
│  ├─ schema.md
│  ├─ metrics_catalog.md
└─ sql/                   # numbered SQL scripts by topic
│  └─ 01_traffic_analysis/     
│  └─ 02_website_performance/   
│  └─ 03_channel_analysis/  
│  └─ 04_business_patterns_and_seasonality/  
│  └─ 05_product_level_analysis/  
│  └─ 06_user_level_analysis/  
│  └─ final_project/  
│  └─ midcourse_project/  


```

Folders present at the root: `docs/`, `sql/` (see repo view). ([GitHub][1])

---

## ⚙️ How to Run

1. **Clone**

```bash
git clone https://github.com/MasegoM94/ecommerce-sql-portfolio.git
```

2. **Open** in MySQL Workbench and create the schema/tables (see `docs/schema.md`) with your own fictitious data.
3. **Execute** SQL files in `/sql/` following the numbering published.
4. **Read** the linked case studies in `/sql/` for narrative, metrics and takeaways.

> Note: the original dataset is **not** shared (course IP). Case studies include context and, where appropriate, small output excerpts.

---

## 🧩 Tools & Techniques

* **SQL**: CTEs, window functions, date bucketing, joins, conditional logic
* **Attribution & Funnels**: UTM segmentation, pageflow analysis, CTR/CVR
* **Monetisation**: AOV, RPS, Margin; cross-sell and basket analysis
* **Product & Retention**: pathing, refunds, new vs repeat behaviour

---

## 📌 Roadmap

* Cohort retention extensions
* Optional synthetic data for reproducibility
* Simple dashboards for summary views

---

## 📝 Licence

MIT — see [`LICENSE`](LICENSE). ([GitHub][1])

---

This portfolio extends and deepens the work I began in the **Maven Analytics “Advanced SQL / MySQL for Analytics & Business Intelligence” course**.  
I’ve reused and expanded the original dataset and case prompts to build out richer product, retention, and channel stories.

...

[1]: https://github.com/MasegoM94/ecommerce-sql-portfolio/tree/main "GitHub - MasegoM94/ecommerce-sql-portfolio: Journey through understanding Maven Fuzzy Factory data"
