-- ============================================================
-- NovaRetail - Product & Customer Analysis
-- ============================================================

-- 1. Top 5 produits par chiffre d'affaires
SELECT
    p.product_name,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


-- 2. Top 5 produits par quantité vendue
SELECT
    p.product_name,
    SUM(oi.quantity) AS quantity_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY quantity_sold DESC
LIMIT 5;


-- 3. Produits présents dans le plus grand nombre de commandes
SELECT
    p.product_name,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY order_count DESC;


-- 4. Chiffre d'affaires par catégorie
SELECT
    p.category,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS category_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY
    p.category
ORDER BY category_revenue DESC;


-- 5. Top 5 clients par chiffre d'affaires
SELECT
    c.customer_name,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY customer_revenue DESC
LIMIT 5;


-- 6. Clients par nombre de commandes complétées
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY completed_orders DESC;


-- 7. Panier moyen par client
SELECT
    c.customer_name,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY average_order_value DESC;


-- 8. Clients stratégiques :
-- au moins 2 commandes complétées et plus de 300 € de CA
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    c.customer_id,
    c.customer_name
HAVING
    COUNT(DISTINCT o.order_id) >= 2
    AND SUM(
        oi.quantity
        * oi.unit_price
        * (1 - COALESCE(oi.discount_pct, 0))
    ) > 300
ORDER BY total_revenue DESC;