# 📑 Case Studies - Analysing website performance

## 1. Identifying Top Website Pages

**Business Question**

Which website pages are most viewed by our visitors, ranked by session volume?

**Approach**

Count distinct sessions per `pageview_url` across all traffic, up to June 9, 2012.

```sql
SELECT pageview_url
, COUNT(DISTINCT website_session_id) as sessions 
FROM  website_pageviews
WHERE created_at <= '2012-06-09' -- date of request 
GROUP BY pageview_url
ORDER BY sessions desc
;
```

**Insights**

* The **homepage** was the most visited page, which is expected since it serves as the primary entry point.
* The **thank-you page** (post-order confirmation) was naturally the least visited, reflecting its place at the end of the funnel.
* This gave us a baseline map of site engagement, showing where visitors concentrate their attention.

---

## 2. Identifying Top Entry Pages

**Business Question**

Where are users first landing on the site? Which pages serve as entry points?

**Approach**

Extract the minimum pageview ID per session and map it back to the corresponding landing page.

```sql
/*first identify what are the pages of entry for each website session*/
WITH first_page_data as (
						SELECT 	website_session_id
								,MIN(website_pageview_id) as min_pvs_id
						FROM  website_pageviews
						WHERE created_at < '2012-06-12' -- date of request 
						GROUP BY 
								website_session_id
      )
/* join the first page table with website_pageviews table to retrieve the landing page of the first visited page per session and find the count of sessions by landing page*/ 
SELECT 
		wp.pageview_url as landing_page
		,COUNT(DISTINCT fp.website_session_id) as num_of_sessions
FROM first_page_data fp
LEFT JOIN website_pageviews wp
		ON fp.min_pvs_id = wp.website_pageview_id
GROUP BY wp.pageview_url 
ORDER BY num_of_sessions desc
;
```

**Insights**

* At this stage, **100% of sessions landed on `/home`**, making it the only entry point.
* This confirmed that all traffic was being funneled to the homepage, which set the stage for later landing page experiments.

---

## 3. Calculating Bounce Rate for Homepage

**Business Question**

How is the homepage performing as a landing page? Specifically, what are sessions, bounced sessions, and bounce rate?

**Approach**

For each session landing on `/home`, count pageviews and classify sessions with only one pageview as bounces.


```sql 

WITH min_pgvw_id AS (
					SELECT 	website_session_id
							,MIN(website_pageview_id) as min_pageview_id 
							,COUNT(website_pageview_id) as count_pg_visits
					FROM website_pageviews
					WHERE 	created_at < '2012-06-14' -- date of request 
					GROUP BY website_session_id
					)
        
SELECT 	COUNT(DISTINCT  mp.website_session_id) as number_of_sessions_home_landing
		    ,SUM(CASE WHEN count_pg_visits = 1 then 1 else 0 end) as no_bounced_sessions
		    ,SUM(CASE WHEN count_pg_visits = 1 then 1 else 0 end) / COUNT(DISTINCT  mp.website_session_id) as bounce_rate 
FROM min_pgvw_id mp
LEFT JOIN 	website_pageviews wp
		ON 	mp.min_pageview_id = wp.website_pageview_id /*join to the website_pageviews tables on the first page id number as well as the if that page's page url is indeed the home page */ 
        AND wp.pageview_url = '/home';

```

**Insights**

* **11,048 sessions** landed on the homepage.
* **6,538 sessions bounced**, yielding a bounce rate of **\~59%**.
* This is a very high bounce rate, suggesting the homepage was not effective at engaging users beyond the first click.

---

## 4. Analysing Landing Page Test (Home vs Lander-1)

**Business Question**

Does the new landing page `/lander-1` perform better than the homepage for gsearch nonbrand traffic?

**Approach**

Pull sessions starting from `/home` or `/lander-1` after `/lander-1` went live (June 19), calculate bounce rate for each group.

```sql
/*identify the first time the '/lander-1' page was receiving traffic*/ 

SELECT * 
FROM website_pageviews
WHERE pageview_url = '/lander-1'
ORDER BY created_at ASC
LIMIT 1; -- first showing 2012-06-19 00:35:54 with id 23504  

/* find each website session with nonbrand paid traffic i.e. gsearch and nonbrand 
, get the minimum pageview id and the number of page visits per session*/ 
WITH min_pgvw_id AS (
					SELECT 	wp.website_session_id
							,MIN(wp.website_pageview_id) as min_pageview_id 
							,COUNT(wp.website_pageview_id) as count_pg_visits
					FROM website_pageviews wp
					INNER JOIN website_sessions ws 
							on wp.website_session_id = ws.website_session_id
								AND ws.created_at < '2012-07-28'
								AND ws.utm_source = 'gsearch'
								AND ws.utm_campaign = 'nonbrand'
								AND wp.website_pageview_id > 23504 -- first session with the lander page activated
					GROUP BY website_session_id
		)

/*by landing url i.e. first page viewed, get the number of sessions , 
the number of bounced sessions and the bounce rate for each landing page*/ 

SELECT  wp.pageview_url AS landing_url 
		,COUNT(DISTINCT  mp.website_session_id) as number_of_sessions_home_landing
		,SUM(CASE WHEN count_pg_visits = 1 then 1 else 0 end) as no_bounced_sessions
		,SUM(CASE WHEN count_pg_visits = 1 then 1 else 0 end) / COUNT(DISTINCT  mp.website_session_id) as bounce_rate 
FROM min_pgvw_id mp
LEFT JOIN 	website_pageviews wp
		ON 	mp.min_pageview_id = wp.website_pageview_id /*join by 1st page view id */ 
WHERE wp.pageview_url in ('/home','/lander-1')
GROUP BY 
 		wp.pageview_url;
```

**Insights**

* `/lander-1` had a **lower bounce rate (53.2%)** compared to the homepage (58.3%).
* `/lander-1` also attracted more sessions during the test period.
* Recommendation: **pursue `/lander-1` as the default lander**, since it clearly improves engagement.

---

## 5. Landing Page Trend Analysis

**Business Question**

Can we confirm traffic routing between `/home` and `/lander-1` since June 1, and how has bounce rate trended weekly?

**Approach**

Track weekly sessions by landing page (home vs lander-1), and calculate bounce rates over time.

```sql

-- Pull pageviews joined to sessions for gsearch/nonbrand in date window.
WITH filtered_sessions AS (        
					SELECT 	wp.website_session_id
							, wp.website_pageview_id
                            , wp.created_at
                            , wp.pageview_url
					FROM website_pageviews wp
					INNER JOIN website_sessions ws 
							ON wp.website_session_id = ws.website_session_id
							AND ws.utm_campaign = 'nonbrand'
							AND ws.utm_source = 'gsearch'
							AND ws.created_at > '2012-06-01'
							AND ws.created_at < '2012-08-31'
        ),
        -- For each session, find first pageview_id and total pageviews.
        min_page_views as (
						SELECT 	al.website_session_id
								,MIN(website_pageview_id) as min_pageview_id 
								,COUNT(DISTINCT website_pageview_id) as num_page_views
                                ,MIN(DATE (created_at)) as date_of_session
						FROM filtered_sessions al
						GROUP BY al.website_session_id
       ), 
-- Join to pageviews to label bounce & landing page.
       all_info_needed as (
						   SELECT 	min_pg.* 
									,CASE WHEN num_page_views = 1 then 1 else 0 END as bounce_session
                                    , wps.pageview_url as landing_page
						   FROM min_page_views min_pg
								INNER JOIN website_pageviews wps
										ON min_pg.website_session_id = wps.website_session_id
                                        AND min_pg.min_pageview_id = wps.website_pageview_id
						   WHERE wps.pageview_url in ('/home','/lander-1')
							),
	-- Attach week info.
       all_info_table as 
					   (
					   SELECT 	all_info.*
								,WEEK(wbs.created_at) as WEEK_CREATED
					   FROM all_info_needed all_info 
							INNER JOIN website_sessions wbs
							ON wbs.website_session_id = all_info.website_session_id
					   )
       -- Aggregate by week start.
       SELECT 
				DATE(MIN(date_of_session)) as First_date_of_week
			   ,COUNT(distinct website_session_id) as number_sessions
			   ,SUM(bounce_session) num_bounced_sessions
			   ,(SUM(bounce_session)/COUNT(distinct website_session_id))*1.0 bounce_rate 
			   ,SUM(CASE WHEN landing_page = '/home' then 1 else 0 end) number_home
			   ,SUM(CASE WHEN landing_page = '/lander-1' then 1 else 0 end) number_lander
        FROM all_info_table
		GROUP BY WEEK_CREATED
       ;
```


**Insights**

* Initially, both `/home` and `/lander-1` received traffic, but over time **traffic fully shifted to `/lander-1`**.
* The **overall bounce rate declined** as the switch was completed, validating the positive impact of the new landing page on top-of-funnel performance.

---

## 6. Building Conversion Funnels

**Business Question**

Where do we lose gsearch visitors between `/lander-1` and placing an order? Please build a full conversion funnel.

**Approach**

Trace sessions starting on `/lander-1` through each funnel stage: products page → Mr Fuzzy product page → cart → shipping → billing → thank-you.

```sql
WITH first_page AS (
					SELECT wp.website_session_id
						   ,MIN( wp.website_pageview_id ) as min_pgvw_id 
					FROM website_pageviews wp
                    INNER JOIN website_sessions ws
							ON ws.website_session_id = wp.website_session_id
					WHERE 	wp.created_at < '2012-09-05' -- date of request
					AND		wp.created_at >= '2012-08-05'
                    AND 	ws.utm_source = 'gsearch'
                    AND     ws.utm_campaign = 'nonbrand' 	
					GROUP BY wp.website_session_id
                   
					),
	-- Step 2: Keep only sessions whose first pageview URL was '/lander-1'
	first_page_lander_sessions AS (
					SELECT  DISTINCT fp.website_session_id
					FROM first_page FP
					LEFT JOIN website_pageviews wp 
							ON WP.website_pageview_id = FP.min_pgvw_id
					WHERE wp.pageview_url =  '/lander-1' 
                    ),

-- Step 3: Count how many of those sessions hit each funnel stage
number_sessions_stages as (
					 SELECT  
							 COUNT(DISTINCT website_session_id) as number_of_sessions
							 ,SUM(CASE WHEN pageview_url = '/lander-1' then 1 ELSE 0 END ) num_landed
							 ,SUM(CASE WHEN pageview_url = '/products' then 1 ELSE 0 END ) num_products
							 ,SUM(CASE WHEN pageview_url = '/the-original-mr-fuzzy' then 1 ELSE 0 END)  num_mr_fuzzy
							 ,SUM(CASE WHEN pageview_url = '/cart' then 1 ELSE 0 END)  num_cart
							 ,SUM(CASE WHEN pageview_url = '/shipping' then 1 ELSE 0 END)  num_shipping
							 ,SUM(CASE WHEN pageview_url = '/billing' then 1 ELSE 0 END)  num_billing
							 ,SUM(CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 ELSE 0 END)  num_thank_you
					FROM website_pageviews wp 
					WHERE website_session_id in (SELECT * FROM first_page_lander_sessions) 
					)


/* -- to identify the number of sessions that went to each page
SELECT * 
FROM number_sessions_stages
*/ 

 -- to identify the clickthrough rates from page to page

SELECT num_products/num_landed*1.0 as landing_click_rate 
	   ,num_mr_fuzzy/num_products*1.0 as products_click_rate 
       ,num_cart/num_mr_fuzzy*1.0 as fuzzy_click_rate 
       ,num_shipping/num_cart*1.0 as cart_click_rate 
       ,num_billing/num_shipping*1.0 as shipping_click_rate 
       ,num_thank_you/num_billing*1.0 as billing_click_rate 
FROM number_sessions_stages

```


**Insights**

* **Landing → Products CTR = 47%** (very low, major drop-off).
* **Products → Mr. Fuzzy CTR = 74%** (healthy).
* **Mr. Fuzzy → Cart CTR = 67%** (moderate).
* **Cart → Shipping CTR = 79%** (strong).
* **Shipping → Billing CTR = 44%** (biggest bottleneck).
* Overall: the **lander, product detail page, and billing page** are the biggest opportunities for optimisation.

---

## 7. Analysing Conversion Funnel Test (Billing vs Billing-2)

**Business Question**

We tested an updated billing page (`/billing-2`). Does it perform better than the original `/billing` page?

**Approach**

Compare sessions hitting `/billing` vs `/billing-2` (after `/billing-2` launched), measuring billing-to-order conversion.

```sql

-- Step 1: Identify the first time /billing-2 appears
SELECT 	min(created_at) as first_date 
		,min(website_session_id) as min_session_id
FROM website_pageviews wp
where pageview_url = '/billing-2'
; -- min session id = 25325

-- Step 2: For all sessions after billing-2 was introduced,
-- check whether they visited billing, billing-2, and/or placed an order

WITH bill_orders_numbers as (
								SELECT 	website_session_id 
										, MAX(CASE WHEN pageview_url = '/billing' then 1 ELSE 0 END) as billing  -- Flag if session hit billing page
										, MAX(CASE WHEN pageview_url = '/billing-2' then 1 ELSE 0 END) as billing_2    -- Flag if session hit billing-2 page
										, MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 ELSE 0 END) as order_placed  -- Flag if session hit thank-you page (order placed)
								FROM website_pageviews  
								WHERE website_session_id in 
															(SELECT distinct website_session_id 
															FROM website_pageviews wp
															WHERE website_session_id  >= 25325 -- only sessions since billing-2 went live
															AND created_at < '2012-11-10' -- date of request 
															AND pageview_url in ('/billing-2', '/billing')
															)
								GROUP BY website_session_id
								)
-- Step 3: Aggregate by page type (billing vs billing-2)
SELECT wp.pageview_url
       , CASE WHEN SUM(billing) = 0 
				THEN SUM(billing_2) 
                ELSE SUM(billing) END  as num_sessions -- number of sessions that made it to a billing page
       , SUM(order_placed) as num_ordered_sessions -- number of sessions that actually had an order placed 
       , (SUM(order_placed)*1.0)/(CASE WHEN SUM(billing) = 0 then SUM(billing_2) else SUM(billing) END ) billing_to_order_cvr
FROM website_pageviews wp
INNER JOIN bill_orders_numbers bo
		ON bo.website_session_id = wp.website_session_id
WHERE wp.pageview_url in ('/billing-2', '/billing')
GROUP BY wp.pageview_url
ORDER BY wp.pageview_url
;
```

**Insights**

* **Billing-2 CVR = 62.7%** vs **Billing CVR = 45.7%**.
* The new billing page clearly outperformed the original.
* Recommendation: **roll out `/billing-2` sitewide** to improve funnel conversion.

---
