-- Business analysis queries for the Olist E-Commerce Portfolio
USE ecommerce_portfolio;

-- 1. Monthly delivered-order trend
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(product_revenue), 2) AS product_revenue,
    ROUND(SUM(total_order_value), 2) AS total_order_value,
    ROUND(AVG(total_order_value), 2) AS average_order_value
FROM vw_order_summary
WHERE order_status = 'delivered'
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY month;

-- 2. Top product categories by delivered product revenue
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown')
ORDER BY product_revenue DESC
LIMIT 10;

-- 3. Customer states by delivered revenue
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS revenue_per_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY product_revenue DESC;

-- 4. Delivery experience and customer review score
SELECT
    CASE
        WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date)
            THEN 'On time or early'
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) BETWEEN 1 AND 3
            THEN 'Late by 1-3 days'
        ELSE 'Late by 4+ days'
    END AS delivery_experience,
    COUNT(*) AS total_orders,
    ROUND(AVG(avg_review_score), 2) AS average_review_score,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 1)
        AS average_delivery_days
FROM vw_order_summary
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_experience
ORDER BY FIELD(delivery_experience, 'On time or early', 'Late by 1-3 days', 'Late by 4+ days');

-- 5. High freight-burden categories (minimum 300 delivered orders)
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_cost,
    ROUND(100 * SUM(oi.freight_value) / SUM(oi.price + oi.freight_value), 2)
        AS freight_share_percentage,
    ROUND(AVG(oi.freight_value), 2) AS average_freight_per_item
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown')
HAVING COUNT(DISTINCT o.order_id) >= 300
ORDER BY freight_share_percentage DESC;

-- 6. Payment method contribution
SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value,
    ROUND(AVG(p.payment_installments), 2) AS average_installments
FROM order_payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_payment_value DESC;

-- 7. Retention segmentation with a window function
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        WHEN total_orders = 2 THEN 'Repeat customer (2 orders)'
        ELSE 'Loyal customer (3+ orders)'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_percentage
FROM customer_orders
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- 8. Cross-sell opportunities: different categories purchased in the same order
SELECT
    COALESCE(t1.product_category_name_english, p1.product_category_name, 'Unknown') AS category_a,
    COALESCE(t2.product_category_name_english, p2.product_category_name, 'Unknown') AS category_b,
    COUNT(DISTINCT oi1.order_id) AS orders_bought_together,
    ROUND(SUM(oi1.price + oi2.price), 2) AS combined_product_value
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.order_item_id < oi2.order_item_id
JOIN orders o ON oi1.order_id = o.order_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
LEFT JOIN category_translation t1 ON p1.product_category_name = t1.product_category_name
LEFT JOIN category_translation t2 ON p2.product_category_name = t2.product_category_name
WHERE o.order_status = 'delivered'
  AND COALESCE(t1.product_category_name_english, p1.product_category_name, 'Unknown')
      <> COALESCE(t2.product_category_name_english, p2.product_category_name, 'Unknown')
GROUP BY category_a, category_b
HAVING COUNT(DISTINCT oi1.order_id) >= 20
ORDER BY orders_bought_together DESC
LIMIT 15;
