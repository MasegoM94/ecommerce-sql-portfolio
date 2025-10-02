# 📊 Metrics Catalog

This catalog defines the **business metrics** implemented in the Ecommerce SQL Portfolio. Each definition is written in plain English.

---

## 1. Orders

* **Definition**: The total number of customer orders as per the orders table.
* **Logic**: Count of distinct `order_id`.
* **Why it matters**: Core measure of sales activity.

---

## 2. Sessions

* **Definition**: The number of website visits.
* **Logic**: Count of distinct `website_session_id`.
* **Why it matters**: Shows the actual website traffic volume.

---

## 3. Session to Order Conversion Rate

* **Definition**: The percentage of sessions that resulted in an order.
* **Logic**: `Orders ÷ Sessions`.
* **Why it matters**: Measures efficiency of turning website traffic into paying customers.

---

## 4. Average Order Value (AOV)

* **Definition**: The average amount spent per order.
* **Logic**: `Revenue ÷ Orders`.
* **Why it matters**: Helps assess customer spending behavior and the impact of pricing or promotions.

---

## 5. Bounced Sessions

* **Definition**: Sessions where a user viewed only one page before leaving the site.
* **Logic**: Count of sessions with exactly one pageview.
* **Why it matters**: Identifies visitors who leave immediately, often signaling landing page or traffic quality issues.

---

## 6. Bounce Rate

* **Definition**: The percentage of sessions that bounced compared to total sessions.
* **Logic**: `Bounced Sessions ÷ Total Sessions`.
* **Why it matters**: Provides a high-level view of landing page and traffic effectiveness.

---

## 7. Click-Through Rate (CTR) — Funnel

* **Definition**: The proportion of sessions that progressed from one page (or funnel step) to the next.
* **Logic**: `Sessions that reached next page ÷ Sessions that saw prior page`.
* **Why it matters**: Highlights how effectively users move through the funnel and pinpoints drop-off points.

---

## 8. Organic Search Sessions

* **Definition**: Sessions that arrived via an organic search engine result (unpaid).
* **Logic**: Count distinct sessions where `utm_source IS NULL` and `http_referer IS NOT NULL`.
* **Why it matters**: Indicates SEO health and discoverability.

---

## 9. Direct Type-In Sessions

* **Definition**: Sessions that began by typing the URL directly or via bookmarks.
* **Logic**: Count distinct sessions where `utm_source IS NULL` and `http_referer IS NULL`.
* **Why it matters**: A proxy for brand strength and loyalty.

---

## 10. Session-to-Order Conversion Rate (CVR)

* **Definition**: The share of sessions that resulted in at least one order in the same session.
* **Logic**: Distinct orders ÷ distinct sessions.
* **Why it matters**: Core efficiency metric. Rising CVR signals better traffic quality, UX, and pricing/promo alignment.

---

## 11. Revenue per Billing-Page Session

* **Definition**: Average revenue generated per session that reached a billing page.
* **Logic**: `Total revenue ÷ sessions that viewed billing`.
* **Why it matters**: Key metric for checkout funnel optimization and billing-page A/B tests.

---

## 12. Revenue

* **Definition**: Money the business brings in from customer orders.
* **Logic**: `SUM(price_usd)` from the orders table.
* **Why it matters**: Fundamental measure of sales performance.

---

## 13. Margin

* **Definition**: Revenue less the cost of goods sold (COGS).
* **Logic**: `SUM(price_usd) – SUM(cogs_usd)`.
* **Why it matters**: Shows profitability after accounting for product costs.

---

## 14. Cross-Sell Rate

* **Definition**: The percentage of orders that include at least one additional (non-primary) product.
* **Logic**: `Orders with >1 product ÷ Total Orders`.
* **Why it matters**: Indicates the effectiveness of cross-sell features in increasing basket size and order value.

---

## 15. Average Products per Order

* **Definition**: The average number of items included in each order.
* **Logic**: `Total items purchased ÷ Total orders`.
* **Why it matters**: Useful for assessing the impact of portfolio expansion or cross-sell strategies.

---

## 16. Refund Rate

* **Definition**: The percentage of products refunded relative to total products sold.
* **Logic**: `Refunded items ÷ Total items sold`.
* **Why it matters**: Key quality control metric; high refund rates may indicate supplier, fulfillment, or product issues.

---

## 17. Revenue per Session (RPS)

* **Definition**: Average revenue generated per website session.
* **Logic**: `Total revenue ÷ Total sessions`.
* **Why it matters**: Normalizes revenue by traffic volume, allowing you to measure how effectively each session is monetized. This is especially useful for evaluating product launches, landing page tests, or channel differences.

---

## 18. Revenue per Cart Session (RPCS)

* **Definition**: Average revenue generated per session that reached the cart page.
* **Logic**: `Total revenue ÷ sessions that viewed /cart`.
* **Why it matters**: Focuses specifically on monetization potential of users who showed purchase intent. Useful for assessing the impact of cross-sell features or changes to the cart page design.

---
