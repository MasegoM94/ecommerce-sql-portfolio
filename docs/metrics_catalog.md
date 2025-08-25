# 📊 Metrics Catalog

This catalog defines the **business metrics** implemented in the Ecommerce SQL Portfolio. Each definition is written in plain English.

---

## 1. Orders

* **Definition**: The total number of customer orders as per the orders table.
* **Logic**: Count of `orders`.
* **Why it matters**: Core measure of sales activity.

---

## 2. Sessions

* **Definition**: The money earned from completed orders after discounts and before costs.
* **Logic**: `total_gross - discount + shipping + tax`.
* **Why it matters**: Shows the actual revenue recognized by the business.

---


## 4. Session to Order Conversion Rate

* **Definition**: The percentage of sessions that resulted in an order.
* **Logic**: `Orders / Sessions`.
* **Why it matters**: Measures the efficiency of turning website traffic into paying customers.

---

## 4. Bid 

* **Definition**: The percentage of sessions that resulted in an order.
* **Logic**: `Orders / Sessions`.
* **Why it matters**: Measures the efficiency of turning website traffic into paying customers.

---

##  Average Order Value (AOV)

* **Definition**: The average amount spent per order.
* **Logic**: `Net Revenue / Orders`.
* **Why it matters**: Helps assess customer spending behavior and the impact of pricing or promotions.

---


##  Repeat Purchase Rate (30 days)

* **Definition**: The share of customers who placed at least 2 orders within 30 days of their first purchase.
* **Logic**: Count customers with ≥2 completed orders in 30 days ÷ all customers.
* **Why it matters**: Indicates customer retention and loyalty.

---

##  New vs Returning Customers

* **Definition**: Breaks down orders into those from first-time customers vs repeat customers.
* **Logic**:

  * **New**: Order date = customer’s first-ever order date.
  * **Returning**: Order date > customer’s first order date.
* **Why it matters**: Reveals whether growth is coming from acquisition or retention.

---

##  Top Products & Categories

* **Definition**: Ranks products or categories by units sold and total revenue.
* **Logic**: `SUM(order_items.qty * order_items.unit_price)` grouped by product or category.
* **Why it matters**: Identifies best-sellers, merchandising opportunities, and areas for margin improvement.

---

## 📌 Notes
