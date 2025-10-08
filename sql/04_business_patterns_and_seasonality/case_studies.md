# Case Studies – Seasonality & Business Patterns

This section highlights analyses of traffic and order patterns across time, focusing on seasonality in 2012 and daily/weekly business rhythms to guide planning for 2013.

---

## 1. Analysing Seasonality

**Business Question**

2012 was a great year for us. As we continue to grow, we should take a look at 2012’s monthly and weekly volume patterns to see if we can find any seasonal trends we should plan for in 2013. Pull both session volume and order volume.

**Approach**

* Pulled all sessions and orders with `created_at < 2013-01-01`.
* Aggregated by **month** to identify broader seasonal swings.
* Aggregated by **week** (`YEARWEEK`) to spot holiday-driven spikes.

```sql

SELECT 	YEAR(wbs.created_at) as yr
		    ,MONTH(wbs.created_at) as mnth
        ,COUNT(DISTINCT wbs.website_session_id) as num_of_sessions
        , COUNT(DISTINCT o.order_id) as num_of_orders
FROM website_sessions wbs
	LEFT JOIN orders o
			ON 	o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2013-01-01'
GROUP BY 1, 2;


SELECT 	MIN(date(wbs.created_at)) as week_start_date
	    	,COUNT(DISTINCT wbs.website_session_id) as num_of_sessions
        , COUNT(DISTINCT o.order_id) as num_of_orders
FROM website_sessions wbs
	LEFT JOIN orders o
			ON 	o.website_session_id = wbs.website_session_id
WHERE wbs.created_at < '2013-01-01'
GROUP BY YEARWEEK(wbs.created_at) ;
```

**Insights**

* Growth was steady through most of the year, starting with ~1,879 sessions in March and reaching ~8,183 in October.
* Sharp surges occurred in **November (14,011 sessions)** and **December (10,072 sessions)**.
* Weekly patterns showed clear holiday-driven spikes, especially around **Black Friday and Cyber Monday**.
* Conclusion: while the long-term trend is strong growth, the business also shows **holiday seasonality** that should be anticipated in 2013.

---

## 2. Analysing Business Patterns

**Business Question**

We’re considering adding live chat support to improve customer experience. Can you analyze average session volume by **hour of day** and **day of week** so that we can staff appropriately? Use Sep 15 – Nov 15, 2012, avoiding holiday distortion.

**Approach**

* Filtered sessions between Sep 15 – Nov 15, 2012.
* Extracted `HOUR(created_at)` and `WEEKDAY(created_at)` for each session.
* Calculated average sessions per hour for each day of the week.

```sql
WITH hour_weekday as (
	      SELECT website_session_id
			      , created_at
            , HOUR(created_at ) as hr
            , WEEKDAY(created_at) as weekday
	FROM website_sessions 
	WHERE 	created_at between '2012-09-15'AND '2012-11-15'
), 

		sessions_by_day_hour as ( 
        SELECT 	DATE(created_at) as date,
			        	hr, 
			        	weekday,
				        COUNT(DISTINCT website_session_id) as sessions
			FROM hour_weekday
			GROUP BY 1,2,3
					)
					
SELECT hr 
		,ROUND(AVG(CASE WHEN weekday = 0 then sessions else NULL end),1) as mon
		,ROUND(AVG(CASE WHEN weekday = 1 then sessions else NULL end),1) as tues
		,ROUND(AVG(CASE WHEN weekday = 2 then sessions else NULL end),1) as wed
		,ROUND(AVG(CASE WHEN weekday = 3 then sessions else NULL end),1) as thurs
		,ROUND(AVG(CASE WHEN weekday = 4 then sessions else NULL end),1) as fri
		,ROUND(AVG(CASE WHEN weekday = 5 then sessions else NULL end),1) as sat
		,ROUND(AVG(CASE WHEN weekday = 6 then sessions else NULL end),1) as sun
FROM sessions_by_day_hour sby
GROUP BY 1 
ORDER BY 1

; 
```


**Session Volume by Hour & Day of Week**

| hr | mon  | tues | wed  | thurs | fri  | sat  | sun  |
| -- | ---- | ---- | ---- | ----- | ---- | ---- | ---- |
| 0  | 8.7  | 7.7  | 6.3  | 7.4   | 6.8  | 5.0  | 5.0  |
| 1  | 6.6  | 6.7  | 5.3  | 4.9   | 7.1  | 5.0  | 3.0  |
| 2  | 6.1  | 4.4  | 4.4  | 6.1   | 4.6  | 3.7  | 3.0  |
| 3  | 5.7  | 4.0  | 4.7  | 4.6   | 3.6  | 3.9  | 3.4  |
| 4  | 5.9  | 6.3  | 6.0  | 4.0   | 6.1  | 2.8  | 2.4  |
| 5  | 5.9  | 5.7  | 4.8  | 5.0   | 6.1  | 3.0  | 3.0  |
| 6  | 9.0  | 7.4  | 7.7  | 8.6   | 8.0  | 3.9  | 3.9  |
| 7  | 14.7 | 13.7 | 12.4 | 14.0  | 13.7 | 6.6  | 6.4  |
| 8  | 17.9 | 18.0 | 17.6 | 16.7  | 17.6 | 9.1  | 9.6  |
| 9  | 20.0 | 20.7 | 19.6 | 20.1  | 20.0 | 10.3 | 11.6 |
| 10 | 22.0 | 22.3 | 21.4 | 21.0  | 22.4 | 11.6 | 12.0 |
| 11 | 21.7 | 22.1 | 21.0 | 21.6  | 21.7 | 11.4 | 12.1 |
| 12 | 21.4 | 20.0 | 19.6 | 19.6  | 20.7 | 11.0 | 11.1 |
| 13 | 20.6 | 21.3 | 20.1 | 20.3  | 20.6 | 11.0 | 10.6 |
| 14 | 21.6 | 20.6 | 20.7 | 20.3  | 21.0 | 10.9 | 10.7 |
| 15 | 21.6 | 21.3 | 21.3 | 20.7  | 21.3 | 10.9 | 10.7 |
| 16 | 22.3 | 21.9 | 22.0 | 21.3  | 21.9 | 11.0 | 11.0 |
| 17 | 21.7 | 22.0 | 21.3 | 21.0  | 21.6 | 11.0 | 10.7 |
| 18 | 18.6 | 18.1 | 17.7 | 18.0  | 18.3 | 10.0 | 9.6  |
| 19 | 17.6 | 17.6 | 17.1 | 16.9  | 17.7 | 9.6  | 9.4  |
| 20 | 17.3 | 16.6 | 16.0 | 16.3  | 16.6 | 9.1  | 8.9  |
| 21 | 15.7 | 15.0 | 14.4 | 14.6  | 15.3 | 8.4  | 8.4  |
| 22 | 13.7 | 12.7 | 12.4 | 12.3  | 12.9 | 7.4  | 7.4  |
| 23 | 10.7 | 9.9  | 9.6  | 10.0  | 9.9  | 6.1  | 6.0  |


**Insights**

* Traffic peaks during **workday hours (8 AM – 5 PM, Mon–Fri)**, averaging **12–25 sessions per hour**.
* Weekends are lighter but still consistent.
* Benchmark from support providers: ~10 sessions per hour per support staff.
* Recommendation:

  * **1 support staff around the clock** for baseline coverage.
  * **2 staff during weekday working hours (8 AM – 5 PM, Mon–Fri)** to handle peak demand efficiently.

