# 📊 Metrics Catalog

This catalog defines the **business metrics** implemented in the Ecommerce SQL Portfolio. Each definition is written in plain English.

---

## 1. Orders

* **Definition**: The total number of customer orders as per the orders table.
* **Logic**: Count of distinct `order_id`.
* **Why it matters**: Core measure of sales activity.

---

## 2. Sessions

* **Definition**: The number of website session or visits
* **Logic**: Count of distinct `website_session_id`.
* **Why it matters**: Shows the actual website traffic.

---


## 3. Session to Order Conversion Rate

* **Definition**: The percentage of sessions that resulted in an order.
* **Logic**: `Orders / Sessions`.
* **Why it matters**: Measures the efficiency of turning website traffic into paying customers.

---

## 4.Average Order Value (AOV)

* **Definition**: The average amount spent per order.
* **Logic**: `Net Revenue / Orders`.
* **Why it matters**: Helps assess customer spending behavior and the impact of pricing or promotions.


---

### 5.Bounced Sessions

* **Definition**: Sessions where a user viewed only one page before leaving the site.
* **Logic**: Count of sessions that have exactly one pageview within the defined cohort and time window.
* **Why it matters**: Identifies visitors who leave immediately without engaging further, often signaling landing page or traffic quality issues.

---

### 6.Bounce Rate

* **Definition**: The percentage of sessions that bounced compared to the total sessions in the same cohort and time window.
* **Logic**:  `Number of bounced sessions \ total sessions `.
* **Why it matters**: Provides a high-level view of landing page and traffic effectiveness. A high bounce rate may indicate mismatched targeting or poor first impressions.

---

### Click-Through Rate (CTR) — Funnel

* **Definition**: The proportion of sessions that progressed from one page (or funnel step) to the next.
* **Logic**:  `Number of sessions that reached the next page \  number of sessions that saw the prior page.`
* **Why it matters**: Highlights how effectively users move through the funnel, and pinpoints where drop-offs occur. Useful for evaluating tests like lander changes or billing page redesigns.


## 📌 Notes
