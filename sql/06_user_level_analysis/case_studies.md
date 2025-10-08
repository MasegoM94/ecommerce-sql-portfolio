# 📑 Case Studies – Repeat Visitors & Customer Value

This section explores whether customers return for multiple sessions, how quickly, and how their behavior and value compare to new visitors.

---

## 1. Identifying Repeat Visitors

**Business Question**

How many of our website visitors come back for another session? If customers return, they may be more valuable than we assumed.

**Approach**

* Looked at user sessions in 2014 (Jan 1 – Oct 31).
* Grouped by `user_id` and counted number of sessions.
* Excluded users whose first visit occurred outside the date range.

```sql
WITH USER_SESSIONS 	AS ( 
            SELECT	user_id,
								    SUM(is_repeat_session) AS NUM_SESSIONS
						FROM	website_sessions
						WHERE 	created_at < '2014-11-01'
                        AND 	created_at >= '2014-01-01'
						GROUP BY 	user_id
                        HAVING MIN(is_repeat_session) = 0 -- Eliminate repeat users originally from out of the time range
                        )
SELECT 	NUM_SESSIONS 
		    ,COUNT(DISTINCT user_id) AS NUM_OF_USERS
FROM USER_SESSIONS 
GROUP BY NUM_SESSIONS
ORDER BY NUM_SESSIONS
;
```

**Insights**

* 126,813 users had only 1 session.
* 14,086 users came back for 2 sessions.
* 315 users had 3 sessions.
* 4,686 users returned more than 3 times.
* This shows that a meaningful share of customers **do come back**, indicating higher lifetime value than one-time conversion metrics suggest.

---

## 2. Analysing Repeat Behavior

**Business Question**

What is the minimum, maximum, and average time between a user’s first and second session?

**Approach**

* For users with repeat sessions (2014 YTD), pulled the date of their first and second session.
* Calculated the days between these two sessions.

```sql
WITH USER_SESSIONS 	AS ( 
                          SELECT	wbs.user_id
                                , DATE(MIN(wbs.created_at)) AS first_created_date
                                , DATE(MIN(swbs.created_at)) AS second_created_date
          					    	FROM	website_sessions wbs
                                  inner JOIN website_sessions swbs
          								ON swbs.user_id = wbs.user_id
                                          AND swbs.is_repeat_session = 1
          						    WHERE 	wbs.created_at < '2014-11-03'
                                  AND 	wbs.created_at >= '2014-01-01'
          						    GROUP BY 	wbs.user_id
                                  HAVING MIN(wbs.is_repeat_session) = 0 -- Eliminate repeat users originally from out of the time range
                        ),
days_between AS (
				SELECT 	user_id
						    ,DATEDIFF(second_created_date, first_created_date) as days_between_first_second
				FROM USER_SESSIONS 
				GROUP BY 1
                )
SELECT  	AVG(days_between_first_second) as avg_days_between_1_2
		    , MIN(days_between_first_second) as min_days_between_1_2
        , MAX(days_between_first_second) as max_days_between_1_2
FROM days_between 
WHERE days_between_first_second is not null 

;

```

**Insights**

* **Average gap**: ~34 days.
* On average, customers come back about a **month later**, suggesting the brand has reasonable stickiness even without immediate repeat visits.

---

## 3. New vs. Repeat Session Performance

**Business Question**

How do conversion rates and revenue per session compare for repeat sessions versus new sessions?

**Approach**

* Pulled all sessions and joined to orders table (2014 YTD).
* Segmented by `is_repeat_session`.
* Calculated session-to-order conversion and revenue per session.

```sql
SELECT is_repeat_session
		, COUNT(DISTINCT wbs.website_session_id) AS sessions
		, COUNT(DISTINCT o.order_id)/COUNT(DISTINCT wbs.website_session_id) as conv_rate 
    , SUM(o.price_usd)/COUNT(DISTINCT wbs.website_session_id) as rev_per_session
FROM website_sessions wbs
LEFT JOIN 	orders o
		ON 	o.website_session_id = wbs.website_session_id
WHERE 	wbs.created_at < '2014-11-08'
	AND wbs.created_at >= '2014-01-01'
GROUP BY is_repeat_session
;
```

**Insights**

* **New sessions**: Conversion rate = 6.8%, Revenue per session = $4.34.
* **Repeat sessions**: Conversion rate = 8.1%, Revenue per session = $5.17.
* Repeat sessions are **more valuable per visit**, converting better and generating higher revenue.

---

## 4. New vs. Repeat Channel Patterns

**Business Question**

Through which channels do customers return? Are we paying for them again via nonbrand ads, or do they come back more cheaply?

**Approach**

* Segmented 2014 sessions by channel group (paid nonbrand, paid brand, organic, direct type-in, paid social).
* Counted new sessions vs repeat sessions per channel.

```sql
SELECT CASE WHEN utm_source is null AND http_referer in ( 'https://www.gsearch.com' , 'https://www.bsearch.com') then 'organic_search'
            WHEN utm_campaign = 'nonbrand' then 'paid_nonbrand'
            WHEN utm_campaign = 'brand' then 'paid_brand'
            WHEN utm_source is null AND http_referer is null then 'direct_type_in'
      			WHEN utm_source = 'socialbook' THEN 'paid_social'
      		END AS channel_group,
      	COUNT(CASE WHEN is_repeat_session = 0 then website_session_id ELSE NULL END) as new_sessions
      , COUNT(CASE WHEN is_repeat_session = 1 then website_session_id ELSE NULL END) as repeat_sessions
FROM website_sessions wbs
WHERE 	wbs.created_at < '2014-11-05'
	AND wbs.created_at >= '2014-01-01'
GROUP BY 1
ORDER BY 3 DESC
;
```

**Insights**

* **Repeat sessions** mainly came via organic search (11,507), direct type-in (10,564), and paid brand (11,027).
* Only about **⅓ of repeat visits came through paid channels**, and those were mostly **brand clicks**, which are cheaper than nonbrand.
* This indicates we are **not paying heavily** for repeat visits — many customers come back organically or via direct.
