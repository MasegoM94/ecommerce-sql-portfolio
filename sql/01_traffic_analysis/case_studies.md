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
SELECT 	COUNT(DISTINCT WS.website_session_id) as SESSIONS
		    ,COUNT(DISTINCT O.ORDER_ID) AS ORDERS
		    ,COUNT(DISTINCT O.ORDER_ID)/COUNT(DISTINCT WS.website_session_id)  AS CVR
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
SELECT  YEARWEEK(WS.created_at) as YEAR_WEEK_NO 
	      ,DATE(MIN(WS.created_at)) as WEEK_START 
        ,COUNT(DISTINCT WS.website_session_id) as SESSIONS
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

SELECT  YEARWEEK(WS.created_at) as WEEK_NO 
	      ,DATE(MIN(WS.created_at)) as WEEK_START
        ,COUNT(DISTINCT CASE WHEN WS.device_type = 'desktop' then WS.website_session_id else null end) as DTOP_SESSIONS
        ,COUNT(DISTINCT CASE WHEN WS.device_type = 'mobile' then WS.website_session_id else null end) as MOB_SESSIONS
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

# 🧩 Narrative Arc (Summary)

1. Initial analysis showed **Gsearch nonbrand dominated traffic**.
2. Conversion was weak (**2.8% CVR**), so **bids were reduced**.
3. As expected, **traffic volume dropped** following the bid-down.
4. Device-level analysis revealed **desktop was efficient, mobile weak**.
5. By **bidding up desktop**, traffic increased in the higher-performing segment.


## 🚀 Forward Recommendations

### 1) Rebalance paid spend toward efficient segments (now)

**Why:** Gsearch nonbrand dominates traffic, but overall CVR was 2.8% vs 4% target. Desktop converts far better than mobile, and desktop sessions rose after bidding up.
**Actions**

* **Bid up**: Gsearch nonbrand **desktop** campaigns by small, controlled increments (e.g., +10–15%).
* **Hold/trim**: Gsearch nonbrand **mobile** until UX issues are addressed.
* **Watch volume sensitivity**: Expect sessions to move with bids (as seen post bid-down).
  **Metrics to track (weekly)**: Sessions, Orders, CVR, **Revenue/Session** by device & campaign.
  **Decision rule**: Keep raising desktop bids while **Revenue/Session ↑** or **Cost per Acquisition ≤ target**; pause increases if diminishing returns.

---

### 2) Fix mobile conversion friction (1–3 sprints)

**Why:** Mobile CVR (\~0.96%) is far below desktop (\~3.73%) and mobile sessions are declining.
**Actions**

* Audit mobile **billing & checkout steps** (latency, form fields, errors).
* Run **A/B tests** on mobile landers (copy, CTA prominence, image weight), and **billing page** (guest checkout, auto-fill).
* Prioritize fixes that reduce taps/keystrokes and time-to-pay.
  **Metrics**: Mobile **funnel step CVRs** (landing→product, product→billing, billing→order),       **Revenue/Session (mobile)**, **Drop-off by page**.
  **Goal**: Lift mobile CVR by **+0.5–1.0 pp**; then reassess mobile bids.

---

### 3) Keep compounding wins via funnel tests (continuous)

**Why:** Prior lander/billing tests generated measurable lift in CVR/revenue (your test workflow).
**Actions**

* Institutionalize a **test pipeline**: one live A/B at lander, one at billing, always.
* Size each test off historical **baseline CVR** and traffic (to reach 80% power).
* For winning variants, **estimate incremental revenue** using post-test traffic & CVR deltas.
  **Metrics**: **Incremental revenue**, **Lift in CVR**, **Time-to-impact** (rollout date to revenue effect).
  **Guardrail**: Ensure **Revenue/Session** stays flat or improves during tests.

---

### 4) Diversify beyond a single channel (next quarter)

**Why:** Over-reliance on Gsearch nonbrand concentrates risk; volume falls when bids drop.
**Actions**

* Build **channel portfolio** view weekly (Gsearch nonbrand, Bsearch nonbrand, brand search, organic, direct).
* Identify channels with rising **CVR** or **Revenue/Session** to merit incremental budget.
* Nurture **brand search** and **direct** via content/CRM to reduce paid dependence.


---

### 5) Product & cross-sell optimisation (next)

**Why:** You’ll analyse product revenue/margin and cross-sell; these change Average Order Value and Lifetime Value.
**Actions**

* Track **revenue & margin by product** monthly; flag low-margin best-sellers for price/pack changes.
* Build a **cross-sell matrix** post product launches to design bundles and in-cart recommendations.
  **Metrics**: **AOV**, **Attach rate** (secondary items/order), **Gross margin %**.

---

### 6) Reporting & operating cadence (make it repeatable)

**Dashboards/Views to maintain (SQL backed):**

* **Channel efficiency**: Sessions, Orders, CVR, **Revenue/Session**, **CPA** by source/campaign/device (weekly).
* **Funnel**: Step CVRs per lander/billing variant; mobile vs desktop (weekly).
* **Product**: Revenue, margin, refund rate; cross-sell pairs (monthly).
* **Seasonality**: Sessions & Orders by week/quarter to anticipate peaks.
  **Process:**
* Monday standup: review last week, decide **bid changes** and **test launches**.
* Mid-week check: guardrails (no CVR drops > X%, no CPA spikes).
* Month-end: roll up tests and approve winning variants.




