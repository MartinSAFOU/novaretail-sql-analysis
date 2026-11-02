# NovaRetail Dataset

This folder contains the datasets used for the NovaRetail SQL analysis project.

The database is organized around five relational tables:

- `customers.csv` — customer information
- `stores.csv` — retail store information
- `products.csv` — product catalog
- `orders.csv` — customer orders
- `order_items.csv` — individual product lines within each order

## Relationships

- One customer can place multiple orders.
- One store can process multiple orders.
- One order can contain multiple order items.
- One product can appear in multiple order items.

## Revenue calculation

Net revenue is calculated using:

`quantity × unit_price × (1 - discount_pct)`

When `discount_pct` is NULL, the discount is considered equal to 0.

Only orders with the status `completed` are included in sales revenue analyses.

## Data quality

The dataset intentionally includes a small number of missing values and different order statuses to support realistic SQL data-quality checks and business analysis.C4EST BON 
