# 📊 Metrics Catalog

This catalog defines the **business metrics** implemented in the Ecommerce SQL Portfolio. Each definition is written in plain English.

---

## 1. Orders

* **Definition**: The total number of customer orders as per the orders table.
* **Logic**: Count of distinct `order_id`.
* **Why it matters**: Core measure of sales activity.

---

## 2. Sessions

* **Definition**: The number of website session or visits
* **Logic**: Count of distinct `website_session_id`.
* **Why it matters**: Shows the actual website traffic.

---


## 3. Session to Order Conversion Rate

* **Definition**: The percentage of sessions that resulted in an order.
* **Logic**: `Orders / Sessions`.
* **Why it matters**: Measures the efficiency of turning website traffic into paying customers.

---

## 4.Average Order Value (AOV)

* **Definition**: The average amount spent per order.
* **Logic**: `Net Revenue / Orders`.
* **Why it matters**: Helps assess customer spending behavior and the impact of pricing or promotions.


---

## 📌 Notes
