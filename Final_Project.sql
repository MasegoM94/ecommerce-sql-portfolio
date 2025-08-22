Use mavenfuzzyfactory;

-- Q1 : First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter
-- for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.

SELECT 	year(wbs.created_at) as Yr,
		quarter(wbs.created_at) as Qtr
        -- ,count(distinct month(wbs.created_at)) as months
        -- ,max(date(wbs.created_at))
        ,count(distinct wbs.website_session_id) as sessions
        ,count(distinct o.order_id) as orders
FROM website_sessions wbs
	LEFT JOIN orders o
			ON	o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2015-01-01'
GROUP BY 1,2
;

-- Q2 : Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we
-- launched, for session-to-order conversion rate, revenue per order, and revenue per session.

SELECT  year(wbs.created_at) as Yr,
		quarter(wbs.created_at) as Qtr
        -- ,count(distinct month(wbs.created_at)) as months
        -- ,max(date(wbs.created_at))
        ,count(distinct wbs.website_session_id) as sessions
        ,count(distinct o.order_id) as orders
        , count(distinct o.order_id)/count(distinct wbs.website_session_id) as conv_rate
        , sum(price_usd)/count(distinct o.order_id) as revenue_per_order
        , sum(price_usd)/count(distinct wbs.website_session_id) as revenue_per_session
        
FROM website_sessions wbs
	LEFT JOIN orders o
			ON	o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2015-01-01'
GROUP BY 1,2
;

-- Q3 : I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch
-- nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?

SELECT  year(wbs.created_at) as Yr,
		quarter(wbs.created_at) as Qtr
        , count( distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as gsearch_nonbrand
		, count( distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as bsearch_nonbrand
        , count( distinct case when utm_campaign = 'brand' then o.order_id else null end) as brand
		, count( distinct case when utm_source is null and http_referer is null then o.order_id else null end) as direct_type_in
        , count( distinct case when utm_source is null and http_referer is not null then o.order_id else null end) as organic_search
FROM website_sessions wbs
	LEFT JOIN orders o
			ON	o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2015-01-01'
GROUP BY 1,2
;

-- Q4 : Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter.
-- Please also make a note of any periods where we made major improvements or optimizations.

SELECT  year(wbs.created_at) as Yr,
		quarter(wbs.created_at) as Qtr
        , count( distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) / count( distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then wbs.website_session_id else null end)  as gsearch_nonbrand
		, count( distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) /  count( distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then wbs.website_session_id  else null end)  as bsearch_nonbrand
        , count( distinct case when utm_campaign = 'brand' then o.order_id else null end) / count( distinct case when utm_campaign = 'brand' then wbs.website_session_id else null end)  as brand
		, count( distinct case when utm_source is null and http_referer is null then o.order_id else null end) / count( distinct case when utm_source is null and http_referer is null then wbs.website_session_id  else null end)  as direct_type_in
        , count( distinct case when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then o.order_id else null end) / count( distinct case when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then wbs.website_session_id else null end)as organic_search
FROM website_sessions wbs
	LEFT JOIN orders o
			ON	o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2015-01-01'
GROUP BY 1,2
-- significant changes increases made here  
-- gsearch - 2014 4 
-- bsearch - 2013 1 
-- brand - 2013 1 
-- direct type in - 2014 -1 
-- organic - 2013 -1 

; 

-- Q5 : We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue
-- and margin by product, along with total sales and revenue. Note anything you notice about seasonality.

SELECT 	YEAR(O.created_at) AS YR
		, MONTH(O.created_at) AS MNTH
		, SUM(CASE WHEN O.product_id = 1 THEN price_usd ELSE NULL END) AS REVENUE_1 
        , COUNT(DISTINCT CASE WHEN O.product_id = 1 THEN order_id ELSE NULL END) AS SALES_1 
        , SUM(CASE WHEN O.product_id = 1 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 1 THEN cogs_usd ELSE NULL END) AS MARGIN_1 
        , (SUM(CASE WHEN O.product_id = 1 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 1 THEN cogs_usd ELSE NULL END))/SUM(CASE WHEN O.product_id = 1 THEN cogs_usd ELSE NULL END) AS MARGIN_1_PERC
		
        , SUM(CASE WHEN O.product_id = 2 THEN price_usd ELSE NULL END) AS REVENUE_2 
        , COUNT(DISTINCT CASE WHEN O.product_id = 2 THEN order_id ELSE NULL END) AS SALES_2 
        , SUM(CASE WHEN O.product_id = 2 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 2 THEN cogs_usd ELSE NULL END) AS MARGIN_2 
        , (SUM(CASE WHEN O.product_id = 2 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 2 THEN cogs_usd ELSE NULL END))/SUM(CASE WHEN O.product_id = 2 THEN cogs_usd ELSE NULL END) AS MARGIN_2_PERC
        
        		
        , SUM(CASE WHEN O.product_id = 3 THEN price_usd ELSE NULL END) AS REVENUE_3 
        , COUNT(DISTINCT CASE WHEN O.product_id = 3 THEN order_id ELSE NULL END) AS SALES_3 
        , SUM(CASE WHEN O.product_id = 3 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 3 THEN cogs_usd ELSE NULL END) AS MARGIN_3 
        , (SUM(CASE WHEN O.product_id = 3 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 3 THEN cogs_usd ELSE NULL END))/SUM(CASE WHEN O.product_id = 3 THEN cogs_usd ELSE NULL END) AS MARGIN_3_PERC

, SUM(CASE WHEN O.product_id = 4 THEN price_usd ELSE NULL END) AS REVENUE_4 
        , COUNT(DISTINCT CASE WHEN O.product_id = 4 THEN order_id ELSE NULL END) AS SALES_4 
        , SUM(CASE WHEN O.product_id = 4 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 4 THEN cogs_usd ELSE NULL END) AS MARGIN_4 
        , (SUM(CASE WHEN O.product_id = 4 THEN price_usd ELSE NULL END) -  SUM(CASE WHEN O.product_id = 4 THEN cogs_usd ELSE NULL END))/SUM(CASE WHEN O.product_id = 4 THEN cogs_usd ELSE NULL END) AS MARGIN_4_PERC
FROM order_items  o 
	LEFT JOIN products P
			ON P.product_id = O.product_id
GROUP BY 1,2
;

-- Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products
-- page, and show how the % of those sessions clicking through another page has changed over time, along with
-- a view of how conversion from /products to placing an order has improved.

WITH sessions_pageviews_products as (
							SELECT * 
							FROM website_pageviews wpv
							WHERE wpv.pageview_url = '/products'
                            ), 
	Next_Page_sessions as (
							SELECT wpvs.website_session_id AS WBS_ID
									, wpvs.website_pageview_id AS WBS_PAGEVIEW_ID
								FROM website_pageviews wpvs
									inner JOIN sessions_pageviews_products spv
											ON	spv.website_session_id = wpvs.website_session_id
											AND	spv.website_pageview_id <= wpvs.website_pageview_id
							),
	WEBSITE_SESSION_INFO AS (
							SELECT 	WP.website_session_id
									,DATE(WP.created_at) AS DATE_SESSION
									, COUNT(DISTINCT WP.Website_pageview_id ) AS NUMBER_OF_PAGES_VISTED
									, COUNT(DISTINCT O.ORDER_ID) AS ORDER_PLACED 
									
							FROM website_pageviews WP
								INNER JOIN sessions_pageviews_products spd
										ON spd.website_session_id = WP.website_session_id
								LEFT JOIN Next_Page_sessions NPS
										ON NPS.WBS_PAGEVIEW_ID = WP.website_pageview_id
								LEFT JOIN ORDERS O 
										ON O.website_session_id = WP.website_session_id
							 WHERE WBS_PAGEVIEW_ID IS NOT NULL
							 GROUP BY 1,2
						)	
SELECT 
		YEAR(DATE_SESSION) AS YR
        ,MONTH(DATE_SESSION) AS MNTH
        ,COUNT(CASE WHEN NUMBER_OF_PAGES_VISTED > 1 THEN website_session_id ELSE NULL END) AS CLICKED_THROUGH_PRODUCT
        ,SUM(ORDER_PLACED)/COUNT(DISTINCT website_session_id) AS CONVERTED_FROM_PRODUCTS
FROM WEBSITE_SESSION_INFO
GROUP BY 1,2
;

-- Q7: We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell
-- item). Could you please pull sales data since then, and show how well each product cross-sells from one another?

	WITH main_product_data as (
								SELECT  *
										, case when product_id = 1 then 1 else 0 end product_1
										, case when product_id = 2 then 1 else 0 end product_2
										, case when product_id = 3 then 1 else 0 end product_3
										, case when product_id = 4 then 1 else 0 end product_4
										-- , case when is_primary_item = 1 then product_id else null end primary_product_id
                                        , first_value(product_id)over(partition by order_id order by created_at, is_primary_item desc ) as primary_id_order

								FROM order_items 
								WHERE created_at >= '2014-12-05' 
                                )
SELECT 	primary_id_order
		,SUM(CASE WHEN product_1 = 1 and primary_id_order <> 1 then price_usd else 0 end ) as Product_Sales_1 
        ,SUM(CASE WHEN product_2 = 1  and primary_id_order <> 2 then price_usd else 0 end ) as Product_Sales_2
        ,SUM(CASE WHEN product_3 = 1 and primary_id_order <> 3 then price_usd else 0 end ) as Product_Sales_3 
        ,SUM(CASE WHEN product_4 = 1 and primary_id_order <> 4  then price_usd else 0 end ) as Product_Sales_4 
FROM main_product_data 
GROUP BY primary_id_order
;

