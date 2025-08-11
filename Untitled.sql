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