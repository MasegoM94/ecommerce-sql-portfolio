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

### 19. Repeat Visitor Rate

* **Definition**: The percentage of users who return for more than one session.
* **Logic**: `Users with >1 session ÷ Total users`.
* **Why it matters**: Measures customer retention and loyalty at the traffic level, complementing conversion rate.

---

### 20. Average Days Between Sessions

* **Definition**: The average time between a user’s first and second session.
* **Logic**: For repeat users, calculate `DATEDIFF(second_session, first_session)`, then average across users.
* **Why it matters**: Helps understand customer return cycles, seasonality, and engagement frequency.

---

### 21. New vs. Repeat Conversion Rate

* **Definition**: Conversion rate segmented by new sessions vs repeat sessions.
* **Logic**:

  * New CVR = `Orders from new sessions ÷ New sessions`.
  * Repeat CVR = `Orders from repeat sessions ÷ Repeat sessions`.
* **Why it matters**: Shows whether repeat visits are more efficient in driving orders compared to first-time visits.

---

### 22. Revenue per Repeat Session

* **Definition**: The average revenue generated per repeat session.
* **Logic**: `Revenue from repeat sessions ÷ Repeat sessions`.
* **Why it matters**: Complements overall RPS by showing the incremental value of repeat traffic.

---

### 23. Repeat Channel Distribution

* **Definition**: The breakdown of repeat sessions by acquisition channel (e.g., direct, organic, paid brand, paid nonbrand).
* **Logic**: Count of repeat sessions per channel ÷ Total repeat sessions.
* **Why it matters**: Helps assess whether customers return organically or if repeat traffic still requires paid re-acquisition.

---

### 24. Channel Sessions

* **Definition**: The number of website sessions attributed to each acquisition channel (e.g., paid nonbrand, paid brand, organic, direct).
* **Logic**: Count of distinct `website_session_id`, grouped by `utm_source`, `utm_campaign`, and derived channel classification.
* **Why it matters**: Allows evaluation of traffic sources and helps measure dependence on specific acquisition channels.

---

### 25. Channel Conversion Rate

* **Definition**: The percentage of sessions within a given marketing channel that resulted in an order.
* **Logic**: `Orders from channel ÷ Sessions from channel`.
* **Why it matters**: Measures efficiency of traffic from each source and identifies the most effective channels for conversions.

---

### 26. Channel Revenue per Session

* **Definition**: The average revenue generated per website session within each channel.
* **Logic**: `SUM(price_usd) from orders attributed to channel ÷ total sessions from that channel`.
* **Why it matters**: Reflects both conversion and monetisation efficiency by traffic source.

---

### 27. Revenue Growth Rate

* **Definition**: The percentage change in total revenue between two consecutive periods (monthly or quarterly).
* **Logic**: `(Current period revenue – Previous period revenue) ÷ Previous period revenue`.
* **Why it matters**: Quantifies business growth momentum and signals the impact of marketing or product initiatives.

---

### 28. Margin Rate

* **Definition**: The percentage of total revenue retained as profit after deducting cost of goods sold (COGS).
* **Logic**: `(SUM(price_usd) – SUM(cogs_usd)) ÷ SUM(price_usd)`.
* **Why it matters**: Indicates profitability trends and product efficiency, especially important for tracking over time or across products.

---

### 29. Products Page Clickthrough Rate (CTR)

* **Definition**: The proportion of sessions that viewed the `/products` page and proceeded to a product detail page.
* **Logic**: `Sessions that navigated beyond /products ÷ Sessions that viewed /products`.
* **Why it matters**: Measures user engagement and interest in specific products, reflecting the effectiveness of merchandising.

---

### 30. Products Page Conversion Rate

* **Definition**: The percentage of `/products` page sessions that resulted in an order.
* **Logic**: `Orders from /products sessions ÷ Sessions that viewed /products`.
* **Why it matters**: Evaluates the end-to-end conversion success for users who browse the product listing page.

---

### 31. Cross-Sell Rate by Product

* **Definition**: The percentage of orders for a given primary product that included one or more additional products in the same transaction.
* **Logic**: `Orders with secondary (cross-sold) products ÷ Total orders for that primary product`.
* **Why it matters**: Quantifies how effectively the cross-sell feature increases basket size and total revenue per order.

---

### 32. Channel Order Volume

* **Definition**: The total number of orders attributed to each marketing channel within a given time frame.
* **Logic**: Count of distinct `order_id`, grouped by `utm_source` and `utm_campaign`.
* **Why it matters**: Shows how total sales contributions are distributed across acquisition sources, helping assess dependence and diversification.

---

### 33. Revenue per Session

* **Definition**: The average revenue generated per website session across all traffic sources.
* **Logic**: `SUM(price_usd) ÷ COUNT(DISTINCT website_session_id)`.
* **Why it matters**: Measures total monetization efficiency of traffic, reflecting improvements in conversion rate, AOV, and engagement.

---

### 34. Revenue per Order

* **Definition**: The average revenue generated per order.
* **Logic**: `SUM(price_usd) ÷ COUNT(DISTINCT order_id)`.
* **Why it matters**: Highlights shifts in product mix, upselling success, or pricing strategy over time.


