-- =====================================================
-- E-commerce Customer Experience SQL Analysis
-- Tool: MySQL Workbench
-- Dataset: Processed Olist Order-Level Sample
-- =====================================================

-- =====================================================
-- Database Setup and Data Preparation
-- =====================================================

CREATE DATABASE ecommerce_project;
USE ecommerce_project;

CREATE TABLE ecommerce_orders (
    order_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(50),
    customer_state VARCHAR(10),
    total_price DECIMAL(10,2),
    total_freight DECIMAL(10,2),
    order_value DECIMAL(10,2),
    review_score DECIMAL(3,1),
    delivery_days DECIMAL(10,2),
    delivery_delay_days DECIMAL(10,2),
    is_late_delivery INT,
    order_value_bucket VARCHAR(30),
    purchase_month VARCHAR(20),
    purchase_year INT,
    purchase_day VARCHAR(20)
);

ALTER TABLE ecommerce_orders
MODIFY order_purchase_timestamp VARCHAR(30);

SELECT COUNT(*) FROM ecommerce_orders;

ALTER TABLE ecommerce_orders
ADD COLUMN order_date_clean DATE;

UPDATE ecommerce_orders
SET order_date_clean = STR_TO_DATE(order_purchase_timestamp, '%c/%e/%Y %H:%i');

SELECT order_purchase_timestamp, order_date_clean
FROM ecommerce_orders
LIMIT 5;

select * from ecommerce_orders;


-- =====================================================
-- Query 1: Customer Value Segmentation
-- Business Question: Which customers generate the most value?
-- =====================================================


WITH customer_value AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(order_value), 2) AS total_revenue,
        ROUND(AVG(order_value), 2) AS avg_order_value,
        ROUND(AVG(review_score), 2) AS avg_review_score,
        ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate
    FROM ecommerce_orders
    GROUP BY customer_unique_id
),

ranked_customers AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS value_segment
    FROM customer_value
)
SELECT
    CASE 
        WHEN value_segment = 1 THEN 'High Value Customers'
        WHEN value_segment = 2 THEN 'Medium-High Value Customers'
        WHEN value_segment = 3 THEN 'Medium-Low Value Customers'
        ELSE 'Low Value Customers'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS segment_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(late_delivery_rate), 2) AS avg_late_delivery_rate
FROM ranked_customers
GROUP BY value_segment
ORDER BY value_segment;


-- =====================================================
-- Query 2: Late Delivery Impact on Customer Satisfaction
-- Business Question: How much do late deliveries affect review scores and order performance?
-- =====================================================

WITH delivery_review AS (
    SELECT
        CASE 
            WHEN is_late_delivery = 1 THEN 'Late Delivery'
            ELSE 'On-Time / Early Delivery'
        END AS delivery_status,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(AVG(review_score), 2) AS avg_review_score,
        ROUND(AVG(order_value), 2) AS avg_order_value,
        ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
        ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
    FROM ecommerce_orders
    GROUP BY is_late_delivery
)

SELECT
    delivery_status,
    total_orders,
    avg_review_score,
    avg_order_value,
    avg_delivery_days,
    avg_delay_days,
    ROUND(
        avg_review_score - LAG(avg_review_score) OVER (ORDER BY avg_review_score DESC),
        2
    ) AS review_score_gap
FROM delivery_review
ORDER BY avg_review_score DESC;



-- =====================================================
-- Query 3: Regional Revenue and Shipping Cost Analysis
-- Business Question: Which states generate the most revenue and what are their shipping cost structures?
-- =====================================================

SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(SUM(total_freight), 2) AS total_shipping_cost,
    ROUND((SUM(total_freight) / SUM(order_value)) * 100, 2) AS shipping_cost_pct,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate
FROM ecommerce_orders
GROUP BY customer_state
HAVING COUNT(DISTINCT order_id) >= 20
ORDER BY total_revenue DESC;


-- =====================================================
-- Query 4: Review Score Driver Analysis
-- Business Question: How do review scores relate to delivery performance and order characteristics?
-- =====================================================

SELECT
    review_score,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days,
    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate
FROM ecommerce_orders
GROUP BY review_score
ORDER BY review_score DESC;


-- =====================================================
-- Query 5: Monthly Revenue and Seasonality Analysis
-- Business Question: How do orders, revenue, and customer experience change over time?
-- =====================================================

SELECT
    purchase_year,
    purchase_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate
FROM ecommerce_orders
GROUP BY purchase_year, purchase_month
ORDER BY purchase_year, purchase_month;


-- =====================================================
-- Query 6: Order Value Segment Performance Analysis
-- Business Question: How does customer experience differ across order value segments?
-- =====================================================


SELECT
    order_value_bucket,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days,
    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM ecommerce_orders
GROUP BY order_value_bucket
ORDER BY AVG(order_value);


-- =====================================================
-- Query 7: Revenue at Risk by State
-- Business Question: Which regions put the most revenue at risk due to poor delivery performance?
-- =====================================================

SELECT
    customer_state,

    COUNT(*) AS total_orders,

    ROUND(SUM(order_value), 2) AS total_revenue,

    ROUND(AVG(order_value), 2) AS avg_order_value,

    ROUND(AVG(review_score), 2) AS avg_review_score,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate,

    ROUND(
        SUM(order_value) * AVG(is_late_delivery),
        2
    ) AS revenue_at_risk

FROM ecommerce_orders
GROUP BY customer_state
HAVING COUNT(*) >= 20
ORDER BY revenue_at_risk DESC;



-- =====================================================
-- Query 8: Customer Retention and Repeat Purchase Analysis
-- Business Question: How strong is repeat purchasing behavior across customer segments?
-- =====================================================


WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(order_value), 2) AS total_revenue,
        ROUND(AVG(order_value), 2) AS avg_order_value,
        ROUND(AVG(review_score), 2) AS avg_review_score,
        ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate
    FROM ecommerce_orders
    GROUP BY customer_unique_id
),

customer_segments AS (
    SELECT
        CASE
            WHEN total_orders = 1 THEN 'One-Time Customer'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Repeat Customer'
            ELSE 'Loyal Customer'
        END AS retention_segment,
        total_orders,
        total_revenue,
        avg_order_value,
        avg_review_score,
        late_delivery_rate
    FROM customer_orders
)

SELECT
    retention_segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(avg_review_score), 2) AS avg_review_score,
    ROUND(AVG(late_delivery_rate), 2) AS avg_late_delivery_rate
FROM customer_segments
GROUP BY retention_segment
ORDER BY avg_orders_per_customer DESC;



-- =====================================================
-- Query 9: Delivery Performance by Value Segment
-- Business Question: Are high-value orders receiving the service quality they require?
-- =====================================================


SELECT
    CASE
        WHEN is_late_delivery = 1 THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    order_value_bucket,

    COUNT(*) AS total_orders,

    ROUND(AVG(order_value), 2) AS avg_order_value,

    ROUND(AVG(review_score), 2) AS avg_review_score,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days

FROM ecommerce_orders
GROUP BY
    delivery_status,
    order_value_bucket
ORDER BY
    delivery_status,
    AVG(order_value);


-- =====================================================
-- Query 10: Delivery Efficiency Benchmarking by State
-- Business Question: Which states generate the most revenue relative to delivery speed?
-- =====================================================


SELECT
    customer_state,

    COUNT(*) AS total_orders,

    ROUND(SUM(order_value), 2) AS total_revenue,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate,

    ROUND(AVG(review_score), 2) AS avg_review_score,

    ROUND(
        SUM(order_value) / AVG(delivery_days),
        2
    ) AS revenue_per_delivery_day

FROM ecommerce_orders
GROUP BY customer_state
HAVING COUNT(*) >= 20
ORDER BY revenue_per_delivery_day DESC;



-- =====================================================
-- Query 11: Market Opportunity Scoring Model
-- Business Question: Which states represent the strongest balance of revenue opportunity and customer experience?
-- =====================================================

SELECT
    customer_state,

    COUNT(*) AS total_orders,

    ROUND(SUM(order_value), 2) AS total_revenue,

    ROUND(AVG(review_score), 2) AS avg_review_score,

    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    ROUND(
        (SUM(order_value) * 0.5) +
        (AVG(review_score) * 1000 * 0.3) -
        (AVG(is_late_delivery) * 1000 * 0.2),
        2
    ) AS market_opportunity_score

FROM ecommerce_orders
GROUP BY customer_state
HAVING COUNT(*) >= 20
ORDER BY market_opportunity_score DESC;


-- =====================================================
-- Query 12: Executive KPI Summary
-- Business Question: What are the core business-wide marketplace performance metrics?
-- =====================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT customer_unique_id) AS total_customers,

    ROUND(SUM(order_value), 2) AS total_revenue,

    ROUND(AVG(order_value), 2) AS avg_order_value,

    ROUND(AVG(review_score), 2) AS avg_review_score,

    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,

    ROUND(AVG(is_late_delivery) * 100, 2) AS late_delivery_rate,

    ROUND(SUM(total_freight), 2) AS total_shipping_cost,

    ROUND((SUM(total_freight) / SUM(order_value)) * 100, 2) AS shipping_cost_pct

FROM ecommerce_orders;

