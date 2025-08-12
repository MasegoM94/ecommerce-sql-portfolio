USE mavenfuzzyfactory; 
/* Q1: Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions
and orders so that we can showcase the growth there? */

WITH gsearch_sessions as (
						SELECT DISTINCT wbs.website_session_id
                        , wbs.created_at
                        , o.price_usd
                        , o.cogs_usd
						FROM website_sessions wbs
                        LEFT JOIN orders o
							ON  o.website_session_id = wbs.website_session_id
						WHERE wbs.utm_source = 'gsearch'
						AND wbs.created_at < '2012-11-27'
					)

SELECT  year(created_at) as year_session
		,month(created_at) as month_session
        , count(distinct website_session_id) num_of_sessions
        , sum(price_usd) as sales
        , sum(cogs_usd) as costs
        ,  sum(price_usd) - sum(cogs_usd) as revenue
FROM gsearch_sessions
GROUP BY  year(created_at) 
		 ,month(created_at)
;
/*Q2: it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.
*/

WITH gsearch_sessions_by_brand as (
						SELECT DISTINCT wbs.website_session_id
                        , wbs.created_at
                        , wbs.utm_campaign
                        , o.price_usd
                        , o.cogs_usd
						FROM website_sessions wbs
                        LEFT JOIN orders o
							ON  o.website_session_id = wbs.website_session_id
						WHERE wbs.utm_source = 'gsearch'
						AND wbs.created_at < '2012-11-27'
				)

SELECT  year(created_at) as year_session
		,month(created_at) as month_session
        , utm_campaign 
        , count(distinct website_session_id) num_of_sessions
        , sum(price_usd) as sales
        , sum(cogs_usd) as costs
        ,  sum(price_usd) - sum(cogs_usd) as revenue
FROM gsearch_sessions_by_brand
GROUP BY  year(created_at) 
		 ,month(created_at)
         ,utm_campaign
         
ORDER BY 3,1,2
;

/*
While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/


WITH gsearch_brand_sessions_by_device_type as (
						SELECT DISTINCT wbs.website_session_id
                        , wbs.created_at
                        , wbs.device_type
                        , o.price_usd
                        , o.cogs_usd
						FROM website_sessions wbs
                        LEFT JOIN orders o
							ON  o.website_session_id = wbs.website_session_id
						WHERE wbs.utm_source = 'gsearch'
                        AND wbs.utm_campaign = 'nonbrand'
						AND wbs.created_at < '2012-11-27'
				)

SELECT  year(created_at) as year_session
		,month(created_at) as month_session
        , device_type 
        , count(distinct website_session_id) num_of_sessions
        , sum(price_usd) as sales
        , sum(cogs_usd) as costs
        ,  sum(price_usd) - sum(cogs_usd) as revenue
FROM gsearch_brand_sessions_by_device_type
GROUP BY  year(created_at) 
		 ,month(created_at)
         ,device_type
         
ORDER BY 3,1,2
;


/*
Q4: I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from
Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/

WITH sessions as (
						SELECT DISTINCT wbs.website_session_id
                        , wbs.created_at
                        , wbs.utm_source
                        , o.price_usd
                        , o.cogs_usd
						FROM website_sessions wbs
                        LEFT JOIN orders o
							ON  o.website_session_id = wbs.website_session_id
						WHERE wbs.created_at < '2012-11-27'
					)

SELECT  year(created_at) as year_session
		,month(created_at) as month_session
        , utm_source
        , count(distinct website_session_id) num_of_sessions
        , sum(price_usd) as sales
        , sum(cogs_usd) as costs
        ,  sum(price_usd) - sum(cogs_usd) as revenue
FROM sessions
GROUP BY  year(created_at) 
		 ,month(created_at)
         ,utm_source
         
order by 3,1,2
;

/*
I’d like to tell the story of our website performance improvements over the course of the first 8 months.
Could you pull session to order conversion rates, by month?
*/

-- Month , number sessions , number orders, session to order conversion rate 

SELECT YEAR(ws.created_at) as YR
       , MONTH(ws.created_at) as MNTH 
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


/*
For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR
from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
*/

SELECT 	yearweek(ws.created_at) as yearweek_
		,date(min(ws.created_at)) as start_of_week
        ,count(distinct ws.website_session_id) as number_of_sessions
        ,count(distinct o.order_id) as number_of_orders
        ,count(distinct o.order_id)/count(distinct ws.website_session_id) as session_to_order_cvr
        ,sum(o.price_usd) as revenue
FROM website_sessions ws
	LEFT JOIN 	orders o
			on	ws.website_session_id = o.website_session_id
WHERE 	ws.utm_source = 'gsearch'
	AND	ws.utm_campaign = 'nonbrand' 
	AND	ws.created_at < '2012-07-28'
    AND ws.created_at > '2012-06-19'
GROUP BY yearweek(ws.created_at)

;
/*
For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/

-- lander page, sessions, the different pages , 

WITH lander_page as (
					SELECT wp.website_session_id
							, min(website_pageview_id) as min_pg_id
					FROM website_pageviews wp
						 WHERE	wp.created_at < '2012-07-28'
						 AND 	wp.created_at > '2012-06-19'
					GROUP BY wp.website_session_id
                    ),
                    
 distinct_lander_session as (
							SELECT distinct lp.website_session_id
											,wp.pageview_url
							FROM lander_page lp
									LEFT JOIN 	website_pageviews wp
											ON	lp.min_pg_id = wp.website_pageview_id
							WHERE wp.pageview_url in ('/home','/lander')
						)
                            
SELECT distinct wpv.pageview_url
       -- CASE WHEN wpv.pageview
FROM distinct_lander_session ds
	LEFT JOIN 	website_pageviews wpv
			ON 	wpv.website_session_id = ds.website_session_id
    

;

/*
I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test
(Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions
for the past month to understand monthly impact.
*/ 
WITH BILLING AS 
				(SELECT 	wp.pageview_url 
                ,COUNT(DISTINCT wp.website_session_id) as NUMBER_OF_SESSIONS
							,SUM(o.price_usd) as REVENUE
                                                       ,SUM(o.price_usd) / COUNT(DISTINCT wp.website_session_id) as REVENUE_PER_PAGE_SESSION 
				FROM website_pageviews wp
					LEFT JOIN 	orders o
							ON 	o.website_session_id = wp.website_session_id
				WHERE wp.pageview_url in ('/billing-2', '/billing')
					AND	wp.website_session_id  >= 25325
					AND wp.created_at < '2012-11-10'
				GROUP BY wp.pageview_url  )

SELECT *
FROM BILLING;

SELECT 	wp.pageview_url 
		,COUNT(DISTINCT wp.website_session_id) as NUMBER_OF_SESSIONS
							,SUM(o.price_usd) as REVENUE
                           ,SUM(o.price_usd) / COUNT(DISTINCT wp.website_session_id) as REVENUE_PER_PAGE_SESSION 
				FROM website_pageviews wp
					LEFT JOIN 	orders o
							ON 	o.website_session_id = wp.website_session_id
				WHERE wp.pageview_url in ('/billing-2', '/billing')
					AND wp.created_at < '2012-11-27'
                    AND wp.created_at > '2012-11-01'
				GROUP BY wp.pageview_url 



