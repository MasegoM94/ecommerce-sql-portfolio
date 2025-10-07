# Metrics Catalog

This catalog defines the **business metrics** implemented in the Ecommerce SQL Portfolio Project. Each definition is written in plain English.
---

## A) Traffic & Acquisition

### Sessions 

* **Definition**: The number of website visits.
* **Logic**: Count of distinct `website_session_id`.
* **Why it matters**: Shows the actual website traffic volume.

### Organic Search Sessions 

* **Definition**: Sessions that arrived via an organic search engine result (unpaid).
* **Logic**: Count distinct sessions where `utm_source IS NULL` and `http_referer IS NOT NULL`.
* **Why it matters**: Indicates SEO health and discoverability.

### Direct Type-In Sessions 

* **Definition**: Sessions that began by typing the URL directly or via bookmarks.
* **Logic**: Count distinct sessions where `utm_source IS NULL` and `http_referer IS NULL`.
* **Why it matters**: A proxy for brand strength and loyalty.

### Channel Sessions 

* **Definition**: The number of website sessions attributed to each acquisition channel (e.g., paid nonbrand, paid brand, organic, direct).
* **Logic**: Count distinct `website_session_id`, grouped by `utm_source`, `utm_campaign`, and/or derived channel.
* **Why it matters**: Evaluates traffic sources and dependence on specific channels.

---

## B) Conversion & Funnel

### Session-to-Order Conversion Rate (CVR) 

* **Definition**: The percentage of sessions that resulted in an order.
* **Logic**: `Orders ÷ Sessions`.
* **Why it matters**: Measures efficiency of turning traffic into paying customers.

### Bounced Sessions 

* **Definition**: Sessions where a user viewed only one page before leaving the site.
* **Logic**: Count of sessions with exactly one pageview.
* **Why it matters**: Signals landing page or traffic quality issues.

### Bounce Rate 

* **Definition**: The percentage of sessions that bounced compared to total sessions.
* **Logic**: `Bounced Sessions ÷ Total Sessions`.
* **Why it matters**: High-level view of landing and top-of-funnel effectiveness.

### Click-Through Rate (CTR) — Funnel 

* **Definition**: The proportion of sessions that progressed from one page (or funnel step) to the next.
* **Logic**: `Sessions that reached next page ÷ Sessions that saw prior page`.
* **Why it matters**: Pinpoints drop-offs in the funnel.

### Revenue per Billing-Page Session 

* **Definition**: Average revenue generated per session that reached a billing page.
* **Logic**: `Total revenue ÷ sessions that viewed billing`.
* **Why it matters**: Key for checkout optimisation and billing A/B tests.

### Products Page Clickthrough Rate (CTR) 

* **Definition**: Share of `/products` sessions that clicked through to a product detail page.
* **Logic**: `Sessions beyond /products ÷ Sessions to /products`.
* **Why it matters**: Measures merchandising and PLP effectiveness.

### Products Page Conversion Rate 

* **Definition**: Share of `/products` sessions that resulted in an order.
* **Logic**: `Orders from /products sessions ÷ Sessions to /products`.
* **Why it matters**: Evaluates PLP → purchase efficiency.

---

## C) Monetisation

### Revenue 

* **Definition**: Money the business brings in from customer orders.
* **Logic**: `SUM(price_usd)` from the orders table.
* **Why it matters**: Fundamental sales performance metric.

### Average Order Value (AOV) (alias of **Revenue per Order **)*

* **Definition**: The average amount spent per order.
* **Logic**: `Revenue ÷ Orders`.
* **Why it matters**: Captures spend per purchase; affected by pricing/promotions/cross-sell.

### Revenue per Session (RPS)

* **Definition**: Average revenue generated per website session.
* **Logic**: `Total revenue ÷ Total sessions`.
* **Why it matters**: Monetisation efficiency of traffic (ties CVR × AOV).

### Revenue per Cart Session (RPCS)

* **Definition**: Average revenue per session that reached `/cart`.
* **Logic**: `Total revenue ÷ sessions that viewed /cart`.
* **Why it matters**: Focuses on users showing purchase intent; great for cart UX & cross-sell tests.

### Channel Revenue per Session 

* **Definition**: Average revenue per session for each channel.
* **Logic**: `Revenue from channel ÷ Sessions from channel`.
* **Why it matters**: Channel-level monetisation efficiency.

---

## D) Profitability

### Margin 

* **Definition**: Revenue less the cost of goods sold (COGS).
* **Logic**: `SUM(price_usd) – SUM(cogs_usd)`.
* **Why it matters**: Profit after product costs.

### Margin Rate

* **Definition**: Percentage of revenue retained after COGS.
* **Logic**: `(Revenue – COGS) ÷ Revenue`.
* **Why it matters**: Tracks profitability trends and product efficiency.

---

## E) Channel Performance

### Channel Conversion Rate 

* **Definition**: Percentage of sessions within a channel that resulted in an order.
* **Logic**: `Orders from channel ÷ Sessions from channel`.
* **Why it matters**: Channel efficiency for conversions.

### Channel Order Volume 

* **Definition**: Total number of orders attributed to each channel in a period.
* **Logic**: Count distinct `order_id`, grouped by channel.
* **Why it matters**: Shows sales contribution by source.

### Revenue Growth Rate 

* **Definition**: Percentage change in total revenue between two consecutive periods.
* **Logic**: `(Current period revenue – Previous period revenue) ÷ Previous period revenue`.
* **Why it matters**: Quantifies growth momentum and impact of initiatives.

---

## F) Product & Basket

### Cross-Sell Rate 

* **Definition**: Percentage of orders that include at least one additional (non-primary) product.
* **Logic**: `Orders with >1 product ÷ Total orders`.
* **Why it matters**: Indicates cross-sell effectiveness and basket lift.

### Average Products per Order 

* **Definition**: Average number of items in each order.
* **Logic**: `Total items purchased ÷ Total orders`.
* **Why it matters**: Useful for cross-sell/portfolio impacts.

### Cross-Sell Rate by Product 

* **Definition**: Percentage of orders for a given primary product that include additional products.
* **Logic**: `Orders with cross-sold item(s) ÷ Total orders for that primary product`.
* **Why it matters**: Product-level cross-sell performance.

### Refund Rate 

* **Definition**: Percentage of products refunded relative to total products sold.
* **Logic**: `Refunded items ÷ Total items sold`.
* **Why it matters**: Quality control; flags supplier or product issues.

---

## G) Retention & Repeat Behavior

### Repeat Visitor Rate 

* **Definition**: Percentage of users who return for more than one session.
* **Logic**: `Users with >1 session ÷ Total users`.
* **Why it matters**: Retention/loyalty at the traffic level.

### Average Days Between Sessions 

* **Definition**: Average time between a user’s first and second session.
* **Logic**: For repeat users, compute `DATEDIFF(second_session, first_session)` then average.
* **Why it matters**: Return cycle/engagement frequency.

### New vs Repeat Conversion Rate 

* **Definition**: CVR segmented by new sessions vs repeat sessions.
* **Logic**:

  * New CVR = `Orders from new sessions ÷ New sessions`
  * Repeat CVR = `Orders from repeat sessions ÷ Repeat sessions`
* **Why it matters**: Shows uplift in value from returning visitors.

### Revenue per Repeat Session 

* **Definition**: Average revenue generated per repeat session.
* **Logic**: `Revenue from repeat sessions ÷ Repeat sessions`.
* **Why it matters**: Complements overall RPS with a retention lens.

### Repeat Channel Distribution 

* **Definition**: Breakdown of repeat sessions by acquisition channel.
* **Logic**: `Repeat sessions per channel ÷ Total repeat sessions`.
* **Why it matters**: Reveals whether repeat traffic returns organically or via paid re-acquisition.

---

