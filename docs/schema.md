# 📑 Schema Documentation — *Maven Fuzzy Factory*

This project uses the **Maven Fuzzy Factory** eCommerce schema. The tables capture website traffic, user sessions, product catalog, orders, and refunds.

---

## **website\_sessions**

Tracks each website session (visit).

* `website_session_id` *(PK)* – Unique ID for each session.
* `created_at` *(datetime)* – Timestamp when the session began.
* `user_id` *(bigint)* – Identifier for the user.
* `is_repeat_session` *(smallint)* – 0 = first session, 1 = repeat.
* `utm_source` *(varchar)* – Marketing channel (e.g., gsearch, bsearch, direct).
* `utm_campaign` *(varchar)* – Campaign identifier (e.g., brand vs nonbrand).
* `utm_content` *(varchar)* – Variation of creative/ad content.
* `device_type` *(varchar)* – Device used (desktop, mobile, tablet).
* `http_referer` *(varchar)* – Referring site (e.g., google.com).

**Usage:**

* Analyze traffic sources and campaign performance.
* Segment sessions into new vs repeat.
* Device-level and channel-level analysis.

---

## **website\_pageviews**

Tracks each pageview within a session.

* `website_pageview_id` *(PK)* – Unique ID for each pageview.
* `created_at` *(datetime)* – Timestamp of the pageview.
* `website_session_id` *(FK)* – Session that generated the view.
* `pageview_url` *(varchar)* – URL of the page viewed.

**Usage:**

* Funnel analysis (landing → product page → billing → order).
* Testing landing page performance.
* Website navigation & drop-off points.

---

## **products**

Product catalog.

* `product_id` *(PK)* – Unique product ID.
* `created_at` *(datetime)* – When product was introduced.
* `product_name` *(varchar)* – Product name.

**Usage:**

* Product sales analysis.
* Portfolio expansion (impact of new products).
* Cross-sell analysis.

---

## **orders**

Completed orders placed on the website.

* `order_id` *(PK)* – Unique ID for the order.
* `created_at` *(datetime)* – When order was placed.
* `website_session_id` *(FK)* – Session that converted.
* `user_id` *(bigint)* – Identifier for the buyer.
* `primary_product_id` *(smallint)* – Main product purchased.
* `items_purchased` *(smallint)* – Total items in the order.
* `price_usd` *(decimal)* – Order revenue in USD.
* `cogs_usd` *(decimal)* – Cost of goods sold.

**Usage:**

* Revenue and margin tracking.
* Conversion analysis.
* Linking orders to marketing sessions.

---

## **order\_items**

Line items within each order.

* `order_item_id` *(PK)* – Unique ID for the item line.
* `created_at` *(datetime)* – When the item was added.
* `order_id` *(FK)* – Order containing the item.
* `product_id` *(FK)* – Product purchased.
* `is_primary_item` *(smallint)* – Flag if item is the order’s main product.
* `price_usd` *(decimal)* – Item revenue in USD.
* `cogs_usd` *(decimal)* – Item cost.

**Usage:**

* Product-level performance.
* Cross-sell analysis (secondary items).
* AOV (Average Order Value) breakdown.

---

## **order\_item\_refunds**

Refunds issued at the item level.

* `order_item_refund_id` *(PK)* – Unique refund ID.
* `created_at` *(datetime)* – When refund occurred.
* `order_item_id` *(FK)* – Refunded item.
* `order_id` *(FK)* – Related order.
* `refund_amount_usd` *(decimal)* – Refund value.

**Usage:**

* Refund rates by product.
* Net revenue calculation.
* Impact of refunds on margins.

---

## 🔗 Relationships (ERD-style)

* `website_sessions` → `website_pageviews` (1\:M).
* `website_sessions` → `orders` (1\:M).
* `orders` → `order_items` (1\:M).
* `order_items` → `order_item_refunds` (1\:M).
* `products` → `order_items` (1\:M).

