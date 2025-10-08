# 📑 Case Studies – Business Growth & Channel Performance

This section explores the overall growth of the business, efficiency improvements, channel trends, and product expansion from 2012 – 2015.

---

## 1. Volume Growth Over Time

**Business Question**

Show overall session and order volume trended by quarter since launch.

**Approach**

* Pulled quarterly sessions and orders from 2012 Q1 – 2015 Q1.
* Joined `website_sessions` and `orders` to capture conversions.

```sql
SELECT 
	YEAR(wbs.created_at) AS year,
	QUARTER(wbs.created_at) AS quarter, 
	COUNT(DISTINCT wbs.website_session_id) AS sessions, 
  COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions wbs
	LEFT JOIN orders o
		ON wbs.website_session_id = o.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;

```

**Insights**

* Sessions grew from **1,879 → 64,198** (≈ 60 × growth).
* Orders grew from **60 → 5,420** over three years.
* Demonstrates massive overall growth in traffic and order volume, confirming business maturity and scaling success.

---

## 2. Efficiency Improvements

**Business Question**

Show quarterly trends for session-to-order conversion rate, revenue per order, and revenue per session.

**Approach**

* Calculated three KPIs quarterly since launch:

  * Conversion Rate = Orders ÷ Sessions
  * Revenue per Order = SUM(price_usd) ÷ Orders
  * Revenue per Session = SUM(price_usd) ÷ Sessions


```sql
SELECT 
	YEAR(wbs.created_at) AS year,
	QUARTER(wbs.created_at) AS quarter, 
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT wbs.website_session_id) AS session_to_order_conv_rate, 
  SUM(price_usd)/COUNT(DISTINCT o.order_id) AS revenue_per_order, 
  SUM(price_usd)/COUNT(DISTINCT wbs.website_session_id) AS revenue_per_session
FROM website_sessions wbs
	LEFT JOIN orders o
		ON wbs.website_session_id = o.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;
```

**Insights**

* **Conversion rate** improved from 3.2 % → 8.4 %.
* **Revenue per order** rose from $49.99 → $62.79.
* **Revenue per session** jumped 5 × (from $1.59 → $5.30).
* These efficiency gains align with portfolio expansion and higher-value products.

---

## 3. Channel Growth

**Business Question**

Pull a quarterly view of orders from each acquisition channel.

**Approach**

* Segmented orders by source:

  * Gsearch (nonbrand)
  * Bsearch (nonbrand)
  * Brand search
  * Organic search
  * Direct type-in


```sql 
SELECT 
	YEAR(wbs.created_at) AS year,
	QUARTER(wbs.created_at) AS quarter, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in_orders
    
FROM website_sessions wbs
	LEFT JOIN orders o 
		ON wbs.website_session_id = o.website_session_id
GROUP BY 1,2
ORDER BY 1,2

;
```
**Insights**

* Orders increased across all channels, led by **Gsearch nonbrand**.
* Growth in **organic search and direct type-in** reflects stronger brand recognition and lower paid-acquisition dependence.

---

## 4. Channel Conversion Rate Trends

**Business Question**

Show quarterly conversion-rate trends by channel and note key improvement periods.

**Approach**

* Computed session-to-order conversion rate per channel.
* Compared trends from 2012 Q1 – 2015 Q1.

```sql
SELECT 
	YEAR(wbs.created_at) AS year,
	QUARTER(wbs.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN wbs.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN wbs.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN wbs.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN wbs.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN wbs.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions wbs
	LEFT JOIN orders o
		ON wbs.website_session_id = o.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;
```


**Insights**

* Conversion rates rose steadily for all channels.
* A **notable jump** occurred from 2012 Q4 → 2013 Q1 (~ +2 pp across channels), suggesting a successful optimization or site redesign.

---

## 5. Monthly Revenue & Margin Trends

**Business Question**

Pull monthly revenue and margin by product and note seasonality.

**Approach**

* Aggregated monthly totals of revenue and margin for each product (1–4).
* Included overall totals per month.


```sql 
SELECT
	YEAR(created_at) AS year, 
    MONTH(created_at) AS month, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY 1,2
ORDER BY 1,2
;
```

**Insights**

* Strong **seasonal peaks** in **Nov–Jan** each year, aligning with holiday demand.
* Confirms clear cyclical behaviour useful for planning promotions and inventory.

---

## 6. Products Page Conversion & Engagement

**Business Question**

How have clickthrough and conversion rates from the /products page evolved?

**Approach**

* Measured monthly sessions viewing `/products`.
* Calculated:

  * **Clickthrough rate** = sessions that clicked beyond /products ÷ sessions to /products.
  * **Products-to-order rate** = orders ÷ sessions to /products.
  
```sql

CREATE TEMPORARY TABLE products_pageviews
SELECT
	  website_session_id, 
    website_pageview_id, 
    created_at AS saw_product_page_at

FROM website_pageviews 
WHERE pageview_url = '/products'
;


SELECT 
  	YEAR(saw_product_page_at) AS year, 
    MONTH(saw_product_page_at) AS month,
    COUNT(DISTINCT pp.website_session_id) AS sessions_to_product_page, 
    COUNT(DISTINCT wps.website_session_id) AS clicked_to_next_page, 
    COUNT(DISTINCT wps.website_session_id)/COUNT(DISTINCT pp.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT pp.website_session_id) AS products_to_order_rt
FROM products_pageviews pp
	LEFT JOIN website_pageviews wps
		ON wps.website_session_id = pp.website_session_id -- same session
        AND wps.website_pageview_id > pp.website_pageview_id -- they had another page AFTER
	LEFT JOIN orders o
		ON o.website_session_id = pp.website_session_id
GROUP BY 1,2
;
```

**Insights**

* Clickthrough rate climbed **0.71 → 0.86** (steady improvement).
* Products-to-order conversion stabilised around 14 % in the last 6 months — a baseline for future optimisation.

---

## 7. Cross-Selling Analysis

**Business Question**

After adding a 4th product as a primary item (Dec 2014), how do cross-sales perform between products?

**Approach**

* Examined orders after Dec 5 2014.
* Counted cross-sold products per primary product and computed cross-sell rates.

```sql 
CREATE TEMPORARY TABLE primary_products
SELECT 
	  order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05' -- when the 4th product was added
;

SELECT
	  pp.*, 
    oi.product_id AS cross_sell_product_id
FROM primary_products pp
	LEFT JOIN order_items oi
		ON oi.order_id = pp.order_id
        AND oi.is_primary_item = 0; -- only bringing in cross-sells;




SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
    (
    SELECT
    	pp.*, 
        oi.product_id AS cross_sell_product_id
    FROM primary_products pp
    	LEFT JOIN order_items  oi
    		ON oi.order_id = pp.order_id
            AND oi.is_primary_item = 0 
    ) AS primary_w_cross_sell
GROUP BY 1;

```

**Insights**

* **Product 3 (Birthday Bear)** cross-sells strongly with **Product 4 (Mini Bear)** — **22 %** of Product 3 orders include Product 4.
* Cross-sell logic is working as intended and helping lift average basket size without hurting conversion.

