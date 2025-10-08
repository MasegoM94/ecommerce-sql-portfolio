# 📑 Case Studies – Channel Portfolio & Paid Search Optimisation

This section compiles five analyses that explore how the company grew its acquisition portfolio, optimised across channels, and evaluated reliance on paid vs. free sources.

---

## 1. Analysing Channel Portfolio

**Business Question**

With gsearch performing well and the site improving overall, we launched a second paid search channel, bsearch, around August 22. Can we pull weekly trended session volume since then and compare it to gsearch nonbrand to gauge how important this new channel will be?

**Approach**

* Pulled weekly session counts (`YEARWEEK(created_at)`) from Aug 22 – Nov 29, 2012.
* Segmented sessions by `utm_source = 'gsearch'` vs. `utm_source = 'bsearch'`, restricted to `utm_campaign = 'nonbrand'`.
* Compared week-over-week trends for both channels.

```sql
SELECT 	DATE(MIN(created_at)) as week_start
		    ,SUM(case when utm_source = 'gsearch' then 1 else 0 end) as gsearch_sessions
        ,SUM(case when utm_source = 'bsearch' then 1 else 0 end) as bsearch_sessions
FROM website_sessions
WHERE 	created_at < '2012-11-29' #based on time of request
	  AND	created_at > '2012-08-22' # as per request 
    AND utm_campaign = 'nonbrand' 
GROUP BY YEARWEEK(created_at) 
;
```

**Insights**

* **Gsearch sessions grew more than 4× in just three months**—from ~590 sessions in the week of Aug 22 to 2,286 by Nov 25, with a notable spike to 3,508 sessions in mid-November.
* **Bsearch sessions also showed steady growth**, rising from 197 to 774 in the same period.
* Overall, **bsearch tends to bring in roughly one-third the volume of gsearch**, which is a substantial share.


---

## 2. Comparing Channel Characteristics

**Business Question**

We’d like to learn more about the bsearch nonbrand campaign. Specifically, what percentage of traffic is coming from mobile, and how does that compare to gsearch? Aggregate data since August 22 is sufficient.

**Approach**

* Pulled distinct sessions from Aug 22 – Nov 29, 2012.
* Segmented by `utm_source = 'gsearch'` vs. `utm_source = 'bsearch'`, restricted to `utm_campaign = 'nonbrand'`.
* Calculated total sessions, mobile sessions, and the percentage of sessions on mobile for each source.

```sql
SELECT 	utm_source
		    , count(distinct website_session_id) as num_sessions 
        , sum(case when device_type = 'mobile' then 1 else 0 end) as num_mobile_sessions
        , sum(case when device_type = 'mobile' then 1 else 0 end)/count(distinct website_session_id) as pct_mobile_session
FROM website_sessions
WHERE 	created_at < '2012-11-30' #based on time of request
	  AND	created_at > '2012-08-22' # as per request 
    AND utm_campaign = 'nonbrand'
GROUP BY utm_source
;
```

**Insights**

* **Gsearch**: ~24.5% of sessions came from mobile.
* **Bsearch**: only ~8.6% of sessions were mobile.
* This reveals a **large difference in device mix**: gsearch is much more mobile-heavy, while bsearch remains overwhelmingly desktop-based.

---

## 3. Cross-Channel Bid Optimisation

**Business Question**

Should bsearch nonbrand have the same bids as gsearch? Please pull nonbrand conversion rates from session to order for gsearch and bsearch, sliced by device type. Use Aug 22 – Sep 18 (pre-holiday campaign period).

**Approach**

* Pulled distinct sessions and orders from Aug 22 – Sep 18, 2012.
* Segmented by `utm_source` (gsearch vs bsearch) and `device_type` (desktop vs mobile).
* Calculated session-to-order conversion rate for each source × device combination.

```sql
SELECT 	  wbs.device_type
		    , wbs.utm_source
		    , count(distinct wbs.website_session_id) as num_sessions 
        , count(distinct o.order_id) as num_orders 
        , count(distinct o.order_id)/count(distinct wbs.website_session_id) as conv_rate
FROM website_sessions wbs
	LEFT JOIN orders o
			ON o.website_session_id = wbs.website_session_id
WHERE 	wbs.created_at < '2012-09-19' # as per request 
	  AND	wbs.created_at > '2012-08-22' # as per request 
    AND wbs.utm_campaign = 'nonbrand'
GROUP BY   	wbs.device_type
		    	,wbs.utm_source
;
```

**Insights**

* **Desktop**: bsearch CVR = 3.79% vs gsearch CVR = 4.52%.
* **Mobile**: bsearch CVR = 0.77% vs gsearch CVR = 1.28%.
* Both on desktop and mobile, **bsearch underperforms gsearch**, confirming that the two channels don’t convert equally well.
* Recommendation: **differentiate bids by channel** and consider bidding down bsearch relative to gsearch.

---

## 4. Channel Portfolio Trends

**Business Question**

After bidding down bsearch nonbrand on December 2nd, how did session volumes trend? Please show weekly session volume for gsearch and bsearch nonbrand, split by device, since November 4th. Also include a comparison metric showing bsearch as a percentage of gsearch for each device.

**Approach**

* Pulled weekly sessions from Nov 4 – Dec 22, 2012.
* Segmented by `utm_source` (gsearch vs bsearch) and `device_type` (desktop vs mobile).
* Calculated bsearch sessions ÷ gsearch sessions for each device.
* Exported results into CSV for reporting.


```sql
SELECT 	
		    MIN(DATE(created_at)) as week_start
        , COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' then wbs.website_session_id ELSE NULL END) as bsearch_dtop_sessions
        , COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' then wbs.website_session_id ELSE NULL END) as gsearch_dtop_sessions
        ,  COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' then wbs.website_session_id ELSE NULL END) /COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' then wbs.website_session_id ELSE NULL END) AS bsearch_of_gsearch_dtop 
	    	, COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' then wbs.website_session_id ELSE NULL END) as bsearch_mobile_sessions
	  	, COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' then wbs.website_session_id ELSE NULL END) as gsearch_mobile_sessions
	  	, COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' then wbs.website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' then wbs.website_session_id ELSE NULL END)  AS bsearch_of_gsearch_mobile 

FROM website_sessions wbs

WHERE 	wbs.created_at < '2012-12-22' #based on time of request 
	  AND	wbs.created_at > '2012-11-04' #as per request 
    AND wbs.utm_campaign = 'nonbrand'
GROUP BY 	YEARWEEK(created_at)
;

```

**CSV Output**

| week_start | bsearch_dtop_sessions | gsearch_dtop_sessions | bsearch_of_gsearch_dtop | bsearch_mobile_sessions | gsearch_mobile_sessions | bsearch_of_gsearch_mobile |
| :--------- | --------------------: | --------------------: | ----------------------: | ----------------------: | ----------------------: | ------------------------: |
| 2012-11-04 |                   400 |                  1027 |                  0.3895 |                      29 |                     323 |                    0.0898 |
| 2012-11-11 |                   401 |                   956 |                  0.4195 |                      37 |                     290 |                    0.1276 |
| 2012-11-18 |                  1008 |                  2655 |                  0.3797 |                      85 |                     853 |                    0.0996 |
| 2012-11-25 |                   843 |                  2058 |                  0.4096 |                      62 |                     692 |                    0.0896 |
| 2012-12-02 |                   517 |                  1326 |                  0.3899 |                      31 |                     396 |                    0.0783 |
| 2012-12-09 |                   293 |                  1277 |                  0.2294 |                      46 |                     424 |                    0.1085 |
| 2012-12-16 |                   348 |                  1270 |                  0.2740 |                      41 |                     376 |                    0.1090 |


**Insights**

* **Bsearch traffic dropped noticeably after the Dec 2 bid-down**.
* **Gsearch also saw a slight decline after Black Friday/Cyber Monday**, but bsearch’s reduction was sharper.
* The ratio of bsearch-to-gsearch sessions fell across both desktop and mobile, confirming that the bid adjustment had a direct and outsized impact on bsearch volume.


---

## 5. Analysing Free Channels

**Business Question**

A potential investor is asking if we’re building momentum with our brand or if we’ll need to keep relying on paid traffic. Could you pull organic search, direct type-in, and paid brand search sessions by month, and show those sessions as a % of paid search nonbrand?

**Approach**

* Pulled monthly sessions up to Dec 22, 2012.
* Segmented sessions into:

  * **Paid nonbrand search** (baseline denominator)
  * **Paid brand search**
  * **Direct type-in** (sessions with null referrer)
  * **Organic search** (sessions with null utm tags but non-null referrer)
* Calculated each free/brand channel’s volume and expressed it as a percentage of paid nonbrand.

```sql

SELECT    year(created_at) as yr
		    ,month(created_at) as mnth
        ,COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' then website_session_id else null end) as count_nonbrand
        ,COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' then website_session_id else null end) as count_brand
        ,COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' then website_session_id else null end)/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' then website_session_id else null end) as brand_pct_nonbrand        
        ,COUNT(DISTINCT CASE WHEN http_referer is null then website_session_id else null end) as count_direct
        ,COUNT(DISTINCT CASE WHEN http_referer is null then website_session_id else null end)/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' then website_session_id else null end) as direct_pct_nonbrand    
        ,COUNT(DISTINCT CASE WHEN utm_source is null and utm_campaign is null and http_referer is not null then website_session_id else null end) as count_organic
		  , COUNT(DISTINCT CASE WHEN utm_source is null and utm_campaign is null and http_referer is not null then website_session_id else null end) / COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' then website_session_id else null end)  as organic_pct_nonbrand  
FROM website_sessions wbs
WHERE wbs.created_at < '2012-12-23'
GROUP BY 1,2 ;

```

**CSV Output**

|   yr | mnth | count_nonbrand | count_brand | brand_pct_nonbrand | count_direct | direct_pct_nonbrand | count_organic | organic_pct_nonbrand |
| ---: | ---: | -------------: | ----------: | -----------------: | -----------: | ------------------: | ------------: | -------------------: |
| 2012 |    3 |           1852 |          10 |             0.0054 |            9 |              0.0049 |             8 |               0.0043 |
| 2012 |    4 |           3509 |          76 |             0.0217 |           71 |              0.0202 |            78 |               0.0222 |
| 2012 |    5 |           3295 |         140 |             0.0425 |          151 |              0.0458 |           150 |               0.0455 |
| 2012 |    6 |           3439 |         164 |             0.0477 |          170 |              0.0494 |           190 |               0.0552 |
| 2012 |    7 |           3660 |         195 |             0.0533 |          187 |              0.0511 |           207 |               0.0566 |
| 2012 |    8 |           5318 |         264 |             0.0496 |          250 |              0.0470 |           265 |               0.0498 |
| 2012 |    9 |           5591 |         339 |             0.0606 |          285 |              0.0510 |           331 |               0.0592 |
| 2012 |   10 |           6883 |         432 |             0.0628 |          440 |              0.0639 |           428 |               0.0622 |
| 2012 |   11 |          12260 |         556 |             0.0454 |          571 |              0.0466 |           624 |               0.0509 |
| 2012 |   12 |           6643 |         464 |             0.0698 |          482 |              0.0726 |           492 |               0.0741 |


**Insights**

* **Brand, direct, and organic sessions are all growing month over month.**
* Importantly, these are not just rising in raw volume, but also **as a percentage of paid nonbrand sessions**.
* This demonstrates momentum outside of paid acquisition, suggesting that Maven Fuzzy Factory is beginning to build **brand equity and organic traction**.
