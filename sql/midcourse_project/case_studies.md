# 📑 Case Studies – Channel Growth & Funnel Optimization


## 1. Gsearch Monthly Trends

**Business Question**
Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for Gsearch sessions and orders so that we can showcase the growth?

**Approach**
Aggregate monthly sessions and revenue from all sessions where `utm_source = 'gsearch'` up to 27 Nov 2012.

```sql
SELECT  YEAR(wbs.created_at) as year_session
		, MONTH(wbs.created_at) as month_session
        , COUNT(DISTINCT wbs.website_session_id) as num_of_sessions
        , SUM(o.price_usd) as sales
        , SUM(o.cogs_usd) as costs
        , SUM(o.price_usd) - SUM(o.cogs_usd) as revenue
FROM website_sessions wbs
            LEFT JOIN orders o
						    ON  o.website_session_id = wbs.website_session_id
WHERE wbs.utm_source = 'gsearch'
	AND wbs.created_at < '2012-11-27' -- date of request 
GROUP BY  YEAR(wbs.created_at) 
		      ,MONTH(wbs.created_at)
```

**Insights**

* Sessions grew from **~1,860 in the first month to 8,889 in November**, while revenue rose from **$1,830 to $11,376**.
* A sharp jump in October–November suggests **holiday shopping or early Black Friday activity** as a key growth driver.

---

## 2. Gsearch Brand vs Nonbrand

**Business Question**
Split Gsearch traffic into brand and nonbrand campaigns to see if brand awareness is growing.

**Approach**
Count monthly sessions and orders by `utm_campaign` (brand vs nonbrand).

```sql
SELECT
	YEAR(wbs.created_at) AS year_session, 
    MONTH(wbs.created_at) AS month_session, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN wbs.website_session_id ELSE NULL END) AS nonbrand_sessions, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN wbs.website_session_id ELSE NULL END) AS brand_sessions, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders
FROM website_sessions wbs
	LEFT JOIN orders o
		ON o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2012-11-27' -- date of request 
	AND wbs.utm_source = 'gsearch'
GROUP BY YEAR(wbs.created_at)
		    ,MONTH(wbs.created_at);
```
**Insights**

* **Nonbrand** remains the majority of sessions, but **brand traffic is steadily rising** (from 8 to 383 sessions; orders from 0 to 17 over the period).
* Indicates increasing **brand recognition** and more efficient marketing mix.

---

## 3. Gsearch Nonbrand by Device Type

**Business Question**
How do nonbrand Gsearch sessions and orders break down by device type?

**Approach**
Monthly sessions and orders split by `device_type` (desktop vs mobile) for `utm_source = 'gsearch'` and `utm_campaign = 'nonbrand'`.

```sql
SELECT
	YEAR(wbs.created_at) AS year_session, 
    MONTH(wbs.created_at) AS month_session, 
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN wbs.website_session_id ELSE NULL END) AS desktop_sessions, 
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN o.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN wbs.website_session_id ELSE NULL END) AS mobile_sessions, 
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN o.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions wbs
	LEFT JOIN orders o
		ON o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2012-11-27'
	AND wbs.utm_source = 'gsearch'
    AND wbs.utm_campaign = 'nonbrand'
GROUP BY YEAR(wbs.created_at) 
		,MONTH(wbs.created_at);
```

**Insights**

* **Desktop dominates both sessions and orders**.
* Mobile traffic is **growing steadily**, but contributes relatively few orders (peak of only 33 mobile orders in November).
* Suggests potential UX improvements or mobile-focused conversion strategies.

---

## 4. Channel Portfolio Analysis

**Business Question**
How do monthly sessions from Gsearch compare with other channels, and is the business diversifying traffic sources?

**Approach**
Monthly distinct sessions segmented into **Gsearch paid**, **Bsearch paid**, **organic**, and **direct type-in**.


```sql 
-- first, finding the various utm sources and referers to see the traffic we're getting
SELECT DISTINCT 
	utm_source,
    utm_campaign, 
    http_referer
FROM website_sessions wbs
WHERE created_at < '2012-11-27'
;


SELECT
	YEAR(wbs.created_at) AS year_session, 
    MONTH(wbs.created_at) AS month_session, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN wbs.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN wbs.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN wbs.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN wbs.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions wbs
WHERE wbs.created_at < '2012-11-27'
GROUP BY YEAR(wbs.created_at) 
		     ,MONTH(wbs.created_at)

```

**Insights**

* Gsearch paid remains the **largest traffic source**, followed by Bsearch.
* **Organic search and direct visits are climbing rapidly** (organic from 8 to 536 sessions; direct from 9 to 485), a positive signal of **organic brand growth** and lower reliance on paid traffic.

---

## 5. Session-to-Order Conversion Rate

**Business Question**
Show how website efficiency (session-to-order conversion) improved during the first eight months.

**Approach**
Monthly conversion rate = orders ÷ sessions across the entire site.

```sql
SELECT YEAR(ws.created_at) as year
       , MONTH(ws.created_at) as month 
       , COUNT(DISTINCT ws.website_session_id) as number_of_sessions
       , COUNT(DISTINCT o.order_id) as number_of_orders
       , COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as session_to_order_cvr
FROM website_sessions ws
		LEFT JOIN 	orders o
				ON	ws.website_session_id = o.website_session_id 
WHERE ws.created_at < '2012-11-27'
GROUP BY YEAR(ws.created_at) 
       , MONTH(ws.created_at) 
;
```
**Insights**

* Conversion rate rose steadily from **3.2 % to 4.4 %**, reflecting **better funnel performance** and the impact of landing page and billing tests.

---

## 6. Gsearch Lander Test – Revenue Impact

**Business Question**
Estimate the incremental revenue earned after switching Gsearch nonbrand traffic from the homepage to the new `/lander-1` page.

**Approach**
Compare conversion rates during the test window (19 Jun – 28 Jul) and apply the lift to all nonbrand sessions since the test.

```sql
SELECT
	MIN(website_pageview_id) AS first_lander_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- for this step, we'll find the first pageview id 

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id, 
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews wpv
	INNER JOIN website_sessions ws
		ON ws.website_session_id = wpv.website_session_id
		AND ws.created_at < '2012-07-28' -- prescribed by the assignment
		AND wpv.website_pageview_id >= 23504 -- first page_view fpr gsearch lander test
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 
	wpv.website_session_id;

-- next, we'll bring in the landing page to each session, like last time, but restricting to home or lander-1 this time
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT 
	ftpv.website_session_id, 
    wpv.pageview_url AS landing_page
FROM first_test_pageviews ftpv
	LEFT JOIN website_pageviews wpv
		ON wpv.website_pageview_id = ftpv.min_pageview_id
WHERE wpv.pageview_url IN ('/home','/lander-1'); 

-- then we make a table to bring in orders
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nb.website_session_id, 
    nb.landing_page, 
    o.order_id AS order_id

FROM nonbrand_test_sessions_w_landing_pages nb
LEFT JOIN orders o
	ON o.website_session_id = nb.website_session_id
;

-- to find the difference between conversion rates 
SELECT
	landing_page, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders nbo
GROUP BY 1; 

-- .0319 for /home, vs .0406 for /lander-1 
-- .0087 additional orders per session

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home
SELECT 
	MAX(ws.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview 
FROM website_sessions ws
	LEFT JOIN website_pageviews wpv
		ON wpv.website_session_id = ws.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND ws.created_at < '2012-11-27'
;
-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- last /home session
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
;

```
**Insights**

* **/lander-1 conversion rate: 4.06 % vs 3.19 %** for the old homepage—a **0.87 pp lift**.
* With ~22,972 sessions since the test, this equates to **≈200 incremental orders (~50 extra per month)**, a substantial revenue gain from a single page change.

---

## 7. Funnel Conversion Analysis

**Business Question**
Compare full conversion funnels for sessions starting on `/home` vs `/lander-1` during the test period (19 Jun – 28 Jul).

**Approach**
Track progression through key pages: landing → products → Mr Fuzzy product page → cart → shipping → billing → thank-you.

```sql 

SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url, 
    -- website_pageviews.created_at AS pageview_created_at, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;


CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
	website_session_id, 
    MAX(homepage) AS saw_homepage, 
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS product_made_it, 
    MAX(mrfuzzy_page) AS mrfuzzy_made_it, 
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url, 
    -- website_pageviews.created_at AS pageview_created_at, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level

GROUP BY 
	website_session_id
;


SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagged 
GROUP BY 1
;

-- then this as final output - click rates

SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE NULL
	END AS segment, 
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flagged
GROUP BY 1
;
```


**Insights**

* `/lander-1` improved **landing-to-product click-through to 47.7 %** vs **42.9 %** for the homepage.
* Later funnel steps (products → cart → shipping) had **similar conversion rates** for both cohorts, proving the lift came **from the entry page**.

---

## 8. Billing Page Test Impact

**Business Question**
Quantify the revenue lift from testing the new billing page (`/billing-2`) between 10 Sep – 10 Nov.

**Approach**
Compare revenue per billing-page session and project monthly impact.

```sql 
SELECT
	billing_version_seen, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
 FROM( 
SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1
;
-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- LIFT: $8.51 per billing page view

SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month

-- 1,194 billing sessions past month
-- LIFT: $8.51 per billing session
-- VALUE OF BILLING TEST: $10,160 over the past month
```

**Insights**

* Revenue per billing page view increased from **$22.83 to $31.34**, a lift of **$8.51 per session**.
* With **1,194 billing sessions in the following month**, the test generated **≈$10,160 incremental revenue** in just one month.
* Clear recommendation: **roll out `/billing-2` sitewide**.

---

### Overall Narrative

Across these eight analyses, we demonstrated a **data-driven growth story**:

* Rapid **Gsearch-driven acquisition**, now complemented by rising **organic and direct traffic**.
* Systematic **experimentation**—new lander and billing pages—that produced measurable **conversion and revenue lifts**.
* Continuous monitoring of **device mix** and **conversion rates** to guide future UX and marketing investments.


