# 📖 Case Studies — Traffic & Conversion Optimisation

## 1. Finding the Top Traffic Sources

**Business Question**

Where are our website sessions coming from in the first month after launch?

**SQL Approach**

* Pulled sessions from `website_sessions` by `utm_source`, `utm_campaign`, and `http_referer`.

```sql
SELECT    utm_source
	    	, utm_campaign
        , http_referer
        , COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions 
WHERE created_at < '2012-04-12' -- date of request
GROUP BY 1,2,3 
ORDER BY sessions DESC;
```

**Insights**

* **Gsearch nonbrand** was the **largest traffic driver**, primarily from `https://www.gsearch.com`.
* Other sources contributed smaller volumes, making Gsearch nonbrand the **priority channel for optimisation**.

---

## 2. Establishing the Baseline: Conversion from Gsearch Nonbrand

**Business Question**

Is Gsearch nonbrand actually converting well enough to justify investment?

**SQL Approach**

* Joined `website_sessions` with `orders`.
* Calculated session-to-order conversion rate (CVR).

```sql
SELECT 	COUNT(DISTINCT WS.website_session_id) as sessions
		    ,COUNT(DISTINCT O.ORDER_ID) AS orders
		    ,COUNT(DISTINCT O.ORDER_ID)/COUNT(DISTINCT WS.website_session_id)  AS cvr
FROM website_sessions ws
LEFT JOIN ORDERS o 
		ON WS.WEBSITE_SESSION_ID = O.WEBSITE_SESSION_ID
WHERE WS.created_at < '2012-04-14' -- date of request
AND WS.utm_source = 'gsearch'
AND WS.utm_campaign = 'nonbrand';
```

**Insights**

* CVR was only **2.8%**, below the **4% target** needed for profitability.
* Action: **reduce bids** on Gsearch nonbrand until efficiency improves.

---

## 3. Measuring the Impact of Bid Changes

**Business Question**

Did reducing bids decrease Gsearch nonbrand traffic volume?

**SQL Approach**

* Tracked weekly sessions post bid-down (Apr–May 2012).

```sql
SELECT  YEARWEEK(WS.created_at) as year_week_no 
	      ,DATE(MIN(WS.created_at)) as week_start 
        ,COUNT(DISTINCT WS.website_session_id) as sessions
FROM website_sessions ws
WHERE WS.created_at < '2012-05-10' -- date of request
		AND WS.utm_source = 'gsearch'
		AND WS.utm_campaign = 'nonbrand'
GROUP BY 1 ;
```

**Insights**

* Sessions from Gsearch nonbrand **fell significantly**, showing traffic volume is **highly sensitive to bid levels**.
* Confirmed the trade-off: lower cost but lower reach.

---

## 4. Device-Level Conversion Analysis

**Business Question**

Are all Gsearch nonbrand sessions performing equally, or does device type matter?

**SQL Approach**

* Segmented session-to-order CVR by `device_type`.

```sql
SELECT 	WS.device_type 
		    ,COUNT(DISTINCT WS.website_session_id) as sessions
		    ,COUNT(DISTINCT O.ORDER_ID) AS orders
        ,COUNT(DISTINCT O.ORDER_ID)/COUNT(DISTINCT WS.website_session_id)  AS session_to_order_cvr
FROM website_sessions WS
LEFT JOIN ORDERS O 
		ON WS.WEBSITE_SESSION_ID = O.WEBSITE_SESSION_ID
WHERE WS.created_at < '2012-05-11' -- date of request
		AND WS.utm_source = 'gsearch'
		AND WS.utm_campaign = 'nonbrand'
GROUP BY 1 ;

```

**Insights**

* **Desktop CVR: 3.73%** vs **Mobile CVR: 0.96%**.
* Desktop traffic was near the target, while mobile lagged severely.
* Action: **increase bids on desktop**, but also **prioritize improving the mobile experience**.

---

## 5. Segment Trends After Device-Specific Bidding

**Business Question**

After bidding up desktop, did we see an impact on traffic by device?

**SQL Approach**

* Tracked weekly sessions for desktop vs mobile post bid changes (Apr–Jun 2012).

```sql

SELECT  YEARWEEK(WS.created_at) as week_no 
	      ,DATE(MIN(WS.created_at)) as week_start
        ,COUNT(DISTINCT CASE WHEN WS.device_type = 'desktop' then WS.website_session_id else null end) as dtop_sessions
        ,COUNT(DISTINCT CASE WHEN WS.device_type = 'mobile' then WS.website_session_id else null end) as mob_sessions
FROM website_sessions WS
WHERE WS.created_at >= '2012-04-15'  -- baseline start date
		and WS.created_at < '2012-06-09' -- date of request
		AND WS.utm_source = 'gsearch'
		AND WS.utm_campaign = 'nonbrand'
GROUP BY 1 ;

```

**Insights**

* **Desktop sessions increased** significantly after bid-up.
* **Mobile sessions declined steadily**, further highlighting underperformance.
* Next step: validate whether rising desktop sessions translated to **order and revenue lift**.

---

