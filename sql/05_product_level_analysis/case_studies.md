# 📑 Case Studies – Product Analysis & Expansion

This section explores how Maven Fuzzy Factory analyzed product-level sales, launches, pathing, funnels, cross-sell features, portfolio expansion, and refund rates.

---

## 1️⃣ Product-Level Sales Analysis

**Business Question**
We’re about to launch a new product, and I’d like to do a deep dive on our current flagship product. Can you please pull monthly trends to date for number of sales, total revenue, and total margin generated for the business?

**Approach**

* Pulled monthly order data up to Jan 4, 2013.
* Aggregated sales, total revenue, and margin from the orders table.

```sql
SELECT 	YEAR(created_at) as yr 
		    ,MONTH(created_at) as mnth
        ,COUNT(DISTINCT order_id) num_sales
        ,SUM(price_usd) as total_revenue
        ,SUM(price_usd) - SUM(cogs_usd) as margin 
FROM ORDERS o 
WHERE created_at < '2013-01-04'
GROUP BY YEAR(created_at)
		    ,MONTH(created_at) 
;
```
**Insights**

* Clear **upward growth pattern** in sales, revenue, and margin leading into 2013.
* Provided a strong **baseline** against which new product performance could be measured.

---

## 2️⃣ Product Launch Sales Analysis

**Business Question**
We launched our second product on January 6th. Can you pull monthly order volume, overall conversion rates, revenue per session, and a breakdown of sales by product since April 1, 2012?

**Approach**

* Aggregated monthly sessions and orders from Apr 2012 – Apr 2013.
* Calculated conversion rate (orders ÷ sessions), revenue per session, and order splits by product.

```sql
SELECT 	year(wbs.created_at) as yr
		    , month(wbs.created_at) as mnth
        , count(distinct o.order_id) as num_orders
        , count(distinct wbs.website_session_id) as num_sessions
        , count(distinct o.order_id)/count(distinct wbs.website_session_id) as conv_rate
        , sum(o.price_usd) as revenue
        , sum(o.price_usd) /count(distinct wbs.website_session_id) as revenue_per_session
        , count(distinct CASE WHEN primary_product_id = 1 then o.order_id  ELSE NULL END) as product_one_orders
		    , count(distinct CASE WHEN primary_product_id = 2 then o.order_id  ELSE NULL END) as product_two_orders
FROM website_sessions WBS 
	LEFT JOIN orders O 
			ON o.website_session_id = wbs.website_session_id
WHERE 	wbs.created_at < '2013-04-05'
	  AND	wbs.created_at > '2012-04-01'
GROUP BY 1,2 
;

```

**Insights**

* **Conversion rate nearly tripled** (2.6% → 7.9%).
* **Revenue per session more than doubled** ($1.33 → $4.09).
* New product introduction clearly **boosted overall efficiency** and diversified sales mix.

---

## 3️⃣ Product Pathing Analysis

**Business Question**
With the new product launched, what paths are users taking from the `/products` page? Specifically, how do clickthrough rates compare pre- vs post-launch?

**Approach**

* Compared sessions hitting `/products` from Oct 2012 – Apr 2013.
* Segmented into pre-launch vs post-launch cohorts.
* Calculated next-page clickthrough rates to Mr. Fuzzy vs Love Bear.


```sql
With session_by_launch as (
						SELECT 	website_session_id
							   , case when created_at < '2013-01-06' then 'pre-launch' else 'post_launch' end time_period
						FROM website_pageviews
						WHERE created_at < '2013-04-06'
							AND	created_at > DATE_ADD('2013-01-06', INTERVAL -3 MONTH)
							AND pageview_url = '/products'
                            ),
launch_next_page as (
						SELECT 
								wpv.website_session_id 
								, sl.time_period
								, MAX(CASE WHEN  wpv.pageview_url = '/products' then 1 else 0 END) product_page
								, MAX(CASE WHEN  wpv.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 END) fuzzy_page
								, MAX(CASE WHEN  wpv.pageview_url = '/the-forever-love-bear' then 1 else 0 END) love_bear_page
						FROM website_pageviews wpv
						INNER JOIN session_by_launch sl
									ON	sl.website_session_id = wpv.website_session_id
									
						GROUP BY wpv.website_session_id
								, sl.time_period
                )
                
SELECT  time_period
		    ,COUNT(DISTINCT website_session_id) as count_sessions
        ,COUNT(DISTINCT CASE WHEN fuzzy_page = 1 or love_bear_page = 1 then website_session_id  ELSE NULL END) as next_page
		    ,COUNT(DISTINCT CASE WHEN fuzzy_page = 1 or love_bear_page = 1 then website_session_id  ELSE NULL END)/COUNT(distinct website_session_id)  as pct_next_page
        ,COUNT(DISTINCT CASE WHEN fuzzy_page = 1 then website_session_id  ELSE NULL END) as mr_fuzzy_next_page
		    ,COUNT(DISTINCT CASE WHEN fuzzy_page = 1 then website_session_id  ELSE NULL END)/COUNT(distinct website_session_id)  as pct_next_page_mr_fuzzy
		    ,COUNT(DISTINCT CASE WHEN love_bear_page = 1 then website_session_id  ELSE NULL END) as love_bear_next_page
		    ,COUNT(DISTINCT CASE WHEN love_bear_page = 1 then website_session_id  ELSE NULL END)/COUNT(distinct website_session_id)  as pct_next_page_love_bear
FROM launch_next_page
GROUP BY time_period
ORDER BY 1 DESC
;
```

**Insights**

* **Mr. Fuzzy CTR fell** from 72.3% → 62.1%.
* **Overall product clickthrough rose** from 72.3% → 76.6%.
* The Love Bear drove incremental engagement, suggesting broader interest and stronger product portfolio appeal.

---

## 4️⃣ Product Conversion Funnels

**Business Question**
Since January 6th, how do conversion funnels compare for Mr. Fuzzy vs the Love Bear?

**Approach**

* Tracked sessions from product pages (Jan 6 – Apr 10, 2013).
* Calculated funnel progression rates: product → cart → shipping → billing → order.

```sql

CREATE TEMPORARY TABLE product_sessions AS (
						SELECT 	website_session_id
							  	, website_pageview_id
							  	, CASE WHEN pageview_url = '/the-original-mr-fuzzy'  THEN 'mrfuzzy' 
									     	WHEN pageview_url =  '/the-forever-love-bear' THEN 'lovebear' 
                                        ELSE NULL END 
                                        AS page_seen
						FROM website_pageviews
						WHERE created_at < '2013-04-10'
							AND	created_at > '2013-01-06'
							AND pageview_url  in ('/the-original-mr-fuzzy',  '/the-forever-love-bear')
						);
                        
SELECT   page_seen
	    	,COUNT(DISTINCT wpv.website_session_id) as sessions
		    ,SUM(CASE WHEN pageview_url = '/cart' then 1 else 0 END) to_cart
        ,SUM(CASE WHEN pageview_url = '/shipping' then 1 else 0 END )to_shipping
        ,SUM(CASE WHEN pageview_url in ('/billing','/billing-2') then 1 else 0 END) to_billing
        ,SUM(CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 else 0 END) to_thank_you 
        
FROM website_pageviews wpv
	INNER JOIN product_sessions ps
			ON ps.website_session_id = wpv.website_session_id
            
GROUP BY page_seen
;
SELECT  page_seen
		    ,COUNT(DISTINCT wpv.website_session_id) as sessions
	    	,SUM(CASE WHEN pageview_url = '/cart' then 1 else 0 END)/COUNT(DISTINCT wpv.website_session_id) to_cart_rt
        ,SUM(CASE WHEN pageview_url = '/shipping' then 1 else 0 END )/SUM(CASE WHEN pageview_url = '/cart' then 1 else 0 END) to_shipping_rt
        ,SUM(CASE WHEN pageview_url in ('/billing','/billing-2') then 1 else 0 END)/SUM(CASE WHEN pageview_url = '/shipping' then 1 else 0 END ) to_billing_rt
        ,SUM(CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 else 0 END)/SUM(CASE WHEN pageview_url in ('/billing','/billing-2') then 1 else 0 END) to_thank_you_rt
        
FROM website_pageviews wpv
	INNER JOIN product_sessions ps
			ON ps.website_session_id = wpv.website_session_id

GROUP BY page_seen;

```

**Insights**

* Love Bear **outperformed Mr. Fuzzy** on product → cart CTR (54.9% vs 43.5%).
* Later funnel stages were **comparable** across both products.
* Confirms Love Bear is not just popular but also **efficient at driving conversions**.

---

## 5️⃣ Cross-Sell Analysis

**Business Question**
On Sept 25, 2013, we added cross-sell functionality on the cart page. What impact did this have on user behavior and revenue?

**Approach**

* Compared one month before vs after Sept 25, 2013.
* Measured CTR from `/cart` → `/shipping`, average products per order, AOV, and revenue per cart session.

```sql

WITH CART_SESSIONS_TIME_PERIOD AS (
            SELECT DISTINCT website_session_id
										      , CASE WHEN created_at <= '2013-09-25' THEN 'A.PRE-CROSS SALE'
											           WHEN created_at > '2013-09-25' THEN 'B.POST-CROSS SALE'
											          ELSE NULL END 
												        AS TIME_PERIOD
										FROM website_pageviews 
										WHERE 	created_at < DATE_ADD('2013-09-25', INTERVAL 1 MONTH) 
										AND 	created_at > DATE_ADD('2013-09-25', INTERVAL -1 MONTH) 
										AND 	pageview_url = '/cart'
							) 
	,CART_SESSIONS_CLICKED_SHIPPING AS 
    (
    SELECT DISTINCT wps.website_session_id
    FROM website_pageviews wps
    WHERE wps.website_session_id in (SELECT DISTINCT website_session_id FROM CART_SESSIONS_TIME_PERIOD)
    AND 	pageview_url = '/shipping' 
    
    )

SELECT  TIME_PERIOD 
	    	, COUNT(DISTINCT CS.website_session_id) AS CART_SESSIONS
        , COUNT(DISTINCT ws.website_session_id) AS CLICKTHROUGHS 
        , COUNT(DISTINCT ws.website_session_id) /COUNT(DISTINCT CS.website_session_id) AS CLICK_THROUGH_RATE
        , AVG(O.ITEMS_PURCHASED) AS AVERAGE_PRODUCTS_PER_ORDER
        , AVG(O.PRICE_USD) AS AVERAGE_O_VALUE
		, SUM(PRICE_USD) /COUNT(DISTINCT CS.website_session_id) AS REVENUE_PER_CART_SESSION
FROM CART_SESSIONS_TIME_PERIOD CS
	LEFT JOIN ORDERS O
			ON 	O.website_session_id = CS.website_session_id
	LEFT JOIN CART_SESSIONS_CLICKED_SHIPPING ws
			ON ws.website_session_id = CS.website_session_id
GROUP BY TIME_PERIOD;


```

**Insights**

* **CTR held steady** (67.2% → 68.4%).
* **Average products per order, AOV, and revenue per cart session all increased slightly**.
* Confirms the cross-sell feature improved monetisation without hurting funnel progression.

---

## 6️⃣ Portfolio Expansion Analysis

**Business Question**
On Dec 12, 2013, we launched the Birthday Bear. What was its impact on product mix, order value, and revenue?

**Approach**

* Compared one month before vs after Dec 12, 2013.
* Calculated conversion rate, average products per order, AOV, and revenue per session.

```sql
WITH SESSIONS_TIME_PERIOD AS (
                SELECT DISTINCT website_session_id
												      , CASE WHEN created_at <= '2013-12-12' THEN 'A.PRE_BITRTHDAY_BEAR'
													           WHEN created_at > '2013-12-12' THEN 'B.POST_BITRTHDAY_BEAR'
														        ELSE NULL END 
												    	AS TIME_PERIOD
										FROM website_pageviews 
										WHERE 	created_at < DATE_ADD('2013-12-12', INTERVAL 1 MONTH) 
										AND 	created_at > DATE_ADD('2013-12-12', INTERVAL -1 MONTH) 
										
							) 

SELECT  TIME_PERIOD 
        , COUNT(DISTINCT O.ORDER_ID)/COUNT(DISTINCT CS.website_session_id) AS CLICK_THROUGH_RATE
        , AVG(O.ITEMS_PURCHASED) AS AVERAGE_PRODUCTS_PER_ORDER
        , AVG(O.PRICE_USD) AS AVERAGE_O_VALUE
		    , SUM(PRICE_USD) /COUNT(DISTINCT CS.website_session_id) AS REVENUE_PER_SESSION
FROM SESSIONS_TIME_PERIOD CS
	LEFT JOIN ORDERS O
			ON 	O.website_session_id = CS.website_session_id
GROUP BY TIME_PERIOD
ORDER BY 1 ;


```

**Insights**

* Analysis confirmed a **positive lift** across KPIs after launch (CTR went from 6.09% to 7.04%).
* Birthday Bear helped expand product mix and contributed to higher session monetization.

---

## 7️⃣ Product Refund Rates

**Business Question**
Mr. Fuzzy experienced supplier issues in 2013–2014. Can we confirm refund rates improved after supplier changes?

**Approach**

* Pulled monthly order and refund rates by product up to Oct 15, 2014.
* Compared Mr. Fuzzy against other products.

```sql

SELECT  YEAR(OI.CREATED_AT) as YR
	    , MONTH(OI.CREATED_AT) as MNTH
      , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 1 THEN OI.ORDER_ID ELSE NULL END) AS P1_ORDERS
      , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 1 THEN OIR.ORDER_ID ELSE NULL END)/COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 1 THEN OI.ORDER_ID ELSE NULL END)  AS P1_REFUND_RATE
      , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 2 THEN OI.ORDER_ID ELSE NULL END) AS P2_ORDERS
      , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 2 THEN OIR.ORDER_ID ELSE NULL END)/COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 2 THEN OI.ORDER_ID ELSE NULL END)  AS P2_REFUND_RATE
    , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 3 THEN OI.ORDER_ID ELSE NULL END) AS P3_ORDERS
    , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 3 THEN OIR.ORDER_ID ELSE NULL END)/COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 3 THEN OI.ORDER_ID ELSE NULL END)  AS P3_REFUND_RATE
    , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 4 THEN OI.ORDER_ID ELSE NULL END) AS P4_ORDERS
    , COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 4 THEN OIR.ORDER_ID ELSE NULL END)/COUNT(DISTINCT CASE WHEN OI.PRODUCT_ID = 4 THEN OI.ORDER_ID ELSE NULL END)  AS P4_REFUND_RATE
FROM ORDER_ITEMS OI
	LEFT JOIN order_item_refunds OIR
			ON OIR.order_item_id = OI.order_item_id
WHERE OI.CREATED_AT < '2014-10-15'
GROUP BY 1,2 
            
;

```

**Insights**

* Refund rates **improved after Sept 2013 supplier changes**, but spiked again in Aug–Sep 2014 (13–14%).
* After switching suppliers on Sept 16, 2014, refund rates stabilized and improved.
* Other products remained healthy, confirming issue was isolated to Mr. Fuzzy.

