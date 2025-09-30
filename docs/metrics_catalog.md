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

### 7.Click-Through Rate (CTR) — Funnel

* **Definition**: The proportion of sessions that progressed from one page (or funnel step) to the next.
* **Logic**:  `Number of sessions that reached the next page \  number of sessions that saw the prior page.`
* **Why it matters**: Highlights how effectively users move through the funnel, and pinpoints where drop-offs occur. Useful for evaluating tests like lander changes or billing page redesigns.


### 8.Organic Search Sessions

* **Definition**: Sessions that arrived via an organic search engine result (unpaid), not tagged with a UTM source.
* **Logic**: Count distinct sessions where the traffic has **no `utm_source`** and **has a non-null `http_referer`**, within the chosen cohort and time window.
* **Why it matters**: Indicates SEO health and discoverability. Growth here reduces paid acquisition dependence and often improves blended CAC.

---

### 9.Direct Type-In Sessions

* **Definition**: Sessions that began by typing the URL directly or via bookmarks (i.e., no referring site and no UTM tags).
* **Logic**: Count distinct sessions where **`utm_source` is null** and **`http_referer` is null**, within the chosen cohort and time window.
* **Why it matters**: A proxy for brand strength and loyalty—users come intentionally without an external prompt.

---

### 10.Session-to-Order Conversion Rate (CVR)

* **Definition**: The share of sessions that resulted in at least one order in the same session.
* **Logic**: **Distinct orders ÷ distinct sessions** over the same cohort and time window, with orders attributed to the session that created them.
* **Why it matters**: Core efficiency metric for the full funnel. Rising CVR signals better traffic quality, UX, and pricing/promo alignment.

---

### 11.Revenue per Billing-Page Session

* **Definition**: Average revenue generated per session that reached a billing page (any billing variant).
* **Logic**: **Total revenue from orders ÷ distinct sessions that viewed a billing page** (e.g., `/billing` or `/billing-2`) within the selected window. Count each session once.
* **Why it matters**: Directly measures the effectiveness of the billing step and is ideal for **A/B tests** (e.g., old vs. new billing page). A higher value reflects fewer drop-offs and stronger checkout completion among sessions that reach billing.

---

