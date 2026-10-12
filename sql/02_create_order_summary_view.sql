-- Create an order-level view before combining item, payment, and review data.
-- Aggregating each one-to-many table first prevents accidental revenue duplication.

USE ecommerce_portfolio;

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COALESCE(i.item_count, 0) AS item_count,
    COALESCE(i.product_revenue, 0) AS product_revenue,
    COALESCE(i.freight_revenue, 0) AS freight_revenue,
    COALESCE(i.product_revenue, 0) + COALESCE(i.freight_revenue, 0) AS total_order_value,
    COALESCE(p.payment_value, 0) AS payment_value,
    r.avg_review_score
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS product_revenue,
        SUM(freight_value) AS freight_revenue
    FROM order_items
    GROUP BY order_id
) i
    ON o.order_id = i.order_id
LEFT JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value
    FROM order_payments
    GROUP BY order_id
) p
    ON o.order_id = p.order_id
LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM order_reviews
    GROUP BY order_id
) r
    ON o.order_id = r.order_id;
