-- ============================================================
-- NovaRetail - Advanced Analysis
-- ============================================================


-- 1. Performance globale des magasins
-- KPI : chiffre d'affaires, nombre de commandes, panier moyen
SELECT
    s.store_id,
    s.store_name,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ),
        2
    ) AS total_revenue,

    COUNT(DISTINCT o.order_id) AS completed_orders,

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

ORDER BY total_revenue DESC;



-- 2. Dépendance d'un magasin à son meilleur client
WITH store_customer_revenue AS (
    SELECT
        s.store_id,
        s.store_name,
        o.customer_id,

        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ) AS customer_revenue

    FROM stores s
    JOIN orders o
        ON s.store_id = o.store_id
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.status = 'completed'

    GROUP BY
        s.store_id,
        s.store_name,
        o.customer_id
),

store_analysis AS (
    SELECT
        store_id,
        store_name,
        SUM(customer_revenue) AS total_revenue,
        MAX(customer_revenue) AS top_customer_revenue

    FROM store_customer_revenue

    GROUP BY
        store_id,
        store_name
)

SELECT
    store_name,
    ROUND(top_customer_revenue, 2) AS top_customer_revenue,
    ROUND(total_revenue, 2) AS total_revenue,

    ROUND(
        top_customer_revenue
        / NULLIF(total_revenue, 0)
        * 100,
        2
    ) AS dependency_ratio_pct

FROM store_analysis

ORDER BY dependency_ratio_pct DESC;



-- 3. Score global de performance des magasins
WITH store_metrics AS (
    SELECT
        s.store_id,
        s.store_name,

        COALESCE(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - COALESCE(oi.discount_pct, 0))
            ),
            0
        ) AS total_revenue,

        COUNT(DISTINCT o.order_id) AS total_orders,

        COALESCE(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - COALESCE(oi.discount_pct, 0))
            ),
            0
        )
        / NULLIF(COUNT(DISTINCT o.order_id), 0) AS average_order_value

    FROM stores s

    LEFT JOIN orders o
        ON s.store_id = o.store_id
        AND o.status = 'completed'

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        s.store_id,
        s.store_name
),

normalized_metrics AS (
    SELECT
        store_id,
        store_name,
        total_revenue,
        total_orders,
        average_order_value,

        (total_revenue - MIN(total_revenue) OVER())
        / NULLIF(
            MAX(total_revenue) OVER()
            - MIN(total_revenue) OVER(),
            0
        ) AS normalized_revenue,

        (total_orders - MIN(total_orders) OVER())::NUMERIC
        / NULLIF(
            MAX(total_orders) OVER()
            - MIN(total_orders) OVER(),
            0
        ) AS normalized_orders,

        (average_order_value - MIN(average_order_value) OVER())
        / NULLIF(
            MAX(average_order_value) OVER()
            - MIN(average_order_value) OVER(),
            0
        ) AS normalized_avg_order_value

    FROM store_metrics
),

store_scores AS (
    SELECT
        *,
        (
            normalized_revenue
            + normalized_orders
            + normalized_avg_order_value
        ) / 3 AS overall_score

    FROM normalized_metrics
)

SELECT
    store_id,
    store_name,
    ROUND(total_revenue, 2) AS total_revenue,
    total_orders,
    ROUND(average_order_value, 2) AS average_order_value,
    ROUND(overall_score, 3) AS overall_score

FROM store_scores

ORDER BY overall_score DESC;



-- 4. Catégorie dominante par magasin
WITH store_category_revenue AS (
    SELECT
        s.store_id,
        s.store_name,
        p.category,

        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0))
        ) AS category_revenue

    FROM stores s
    JOIN orders o
        ON s.store_id = o.store_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id

    WHERE o.status = 'completed'

    GROUP BY
        s.store_id,
        s.store_name,
        p.category
),

store_total_revenue AS (
    SELECT
        store_id,
        SUM(category_revenue) AS total_revenue

    FROM store_category_revenue

    GROUP BY store_id
),

store_top_category AS (
    SELECT
        scr.store_id,
        scr.store_name,
        scr.category,
        scr.category_revenue,
        str.total_revenue,

        ROUND(
            scr.category_revenue
            / NULLIF(str.total_revenue, 0)
            * 100,
            2
        ) AS category_share_pct

    FROM store_category_revenue scr

    JOIN store_total_revenue str
        ON scr.store_id = str.store_id

    WHERE scr.category_revenue = (
        SELECT
            MAX(inner_scr.category_revenue)

        FROM store_category_revenue inner_scr

        WHERE inner_scr.store_id = scr.store_id
    )
)

SELECT
    store_id,
    store_name,
    category AS top_category,
    ROUND(category_revenue, 2) AS category_revenue,
    ROUND(total_revenue, 2) AS total_revenue,
    category_share_pct

FROM store_top_category

ORDER BY category_share_pct DESC;