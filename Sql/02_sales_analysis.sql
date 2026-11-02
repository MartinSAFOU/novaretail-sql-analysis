-- ============================================================
-- NovaRetail - Sales Analysis
-- ============================================================

-- 1. Nombre de commandes par statut
SELECT
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- 2. Période couverte par les commandes
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders;


-- 3. Nombre de clients distincts ayant passé une commande
SELECT
    COUNT(DISTINCT customer_id) AS active_customers
FROM orders;


-- 4. Clients n'ayant jamais passé de commande
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 5. Commandes complétées par magasin
SELECT
    s.store_name,
    COUNT(*) AS completed_orders
FROM orders o
JOIN stores s
    ON o.store_id = s.store_id
WHERE o.status = 'completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY completed_orders DESC;


-- 6. Commandes complétées par mois
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(*) AS completed_orders
FROM orders
WHERE status = 'completed'
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY
    year,
    month;


-- 7. Chiffre d'affaires total des commandes complétées
SELECT
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed';


-- 8. Chiffre d'affaires par magasin
SELECT
    s.store_name,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS total_revenue
FROM stores s
JOIN orders o
    ON s.store_id = o.store_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY total_revenue DESC;


-- 9. Panier moyen par magasin
SELECT
    s.store_name,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM stores s
JOIN orders o
    ON s.store_id = o.store_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY average_order_value DESC;


-- 10. Nombre moyen d'articles par commande complétée
SELECT
    s.store_name,
    ROUND(
        SUM(oi.quantity)::NUMERIC
        / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_items_per_order
FROM stores s
JOIN orders o
    ON s.store_id = o.store_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY avg_items_per_order DESC;