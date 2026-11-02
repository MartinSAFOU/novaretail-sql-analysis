-- ============================================================
-- NovaRetail - Data Quality Checks
-- ============================================================

-- 1. Vérification des valeurs NULL dans customers
SELECT
    COUNT(*) FILTER (WHERE email IS NULL) AS null_email,
    COUNT(*) FILTER (WHERE city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE region IS NULL) AS null_region
FROM customers;


-- 2. Vérification des doublons sur customer_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM customers;


-- 3. Vérification des commandes sans ligne de commande
SELECT
    COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;


-- 4. Vérification de la multiplication des lignes après JOIN
SELECT
    COUNT(*) AS total_rows_after_join,
    COUNT(DISTINCT o.order_id) AS distinct_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;