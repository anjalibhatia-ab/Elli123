-- ============================================================
-- FILE: ecommerce_schema.sql
-- DATABASE: PostgreSQL
-- PURPOSE: Production-style e-commerce schema
-- ============================================================

BEGIN;

-- ============================================================
-- EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS citext;


-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE order_status AS ENUM (
    'pending',
    'paid',
    'shipped',
    'completed',
    'cancelled'
);

CREATE TYPE payment_status AS ENUM (
    'pending',
    'paid',
    'failed',
    'refunded'
);


-- ============================================================
-- TABLE: customers
-- ============================================================

CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email       CITEXT NOT NULL,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_customers_email UNIQUE (email),

    CONSTRAINT chk_customers_email
        CHECK (length(trim(email::TEXT)) > 0),

    CONSTRAINT chk_customers_first_name
        CHECK (length(trim(first_name)) > 0),

    CONSTRAINT chk_customers_last_name
        CHECK (length(trim(last_name)) > 0)
);


-- ============================================================
-- TABLE: categories
-- ============================================================

CREATE TABLE categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_categories_name UNIQUE (name)
);


-- ============================================================
-- TABLE: products
-- ============================================================

CREATE TABLE products (
    product_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id  BIGINT NOT NULL,
    sku          VARCHAR(50) NOT NULL,
    name         VARCHAR(255) NOT NULL,
    description  TEXT,
    price        NUMERIC(12, 2) NOT NULL,
    stock_qty    INTEGER NOT NULL DEFAULT 0,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_products_sku UNIQUE (sku),

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_products_price
        CHECK (price >= 0),

    CONSTRAINT chk_products_stock
        CHECK (stock_qty >= 0),

    CONSTRAINT chk_products_name
        CHECK (length(trim(name)) > 0)
);


-- ============================================================
-- TABLE: orders
-- ============================================================

CREATE TABLE orders (
    order_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   BIGINT NOT NULL,
    status        order_status NOT NULL DEFAULT 'pending',
    total_amount  NUMERIC(12, 2) NOT NULL DEFAULT 0,
    ordered_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_orders_total
        CHECK (total_amount >= 0)
);


-- ============================================================
-- TABLE: order_items
-- ============================================================

CREATE TABLE order_items (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      BIGINT NOT NULL,
    product_id    BIGINT NOT NULL,
    quantity      INTEGER NOT NULL,
    unit_price    NUMERIC(12, 2) NOT NULL,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_items_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT uq_order_items_order_product
        UNIQUE (order_id, product_id)
);


-- ============================================================
-- TABLE: payments
-- ============================================================

CREATE TABLE payments (
    payment_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id          BIGINT NOT NULL,
    amount            NUMERIC(12, 2) NOT NULL,
    status            payment_status NOT NULL DEFAULT 'pending',
    transaction_ref   VARCHAR(100),
    paid_at           TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_payments_transaction_ref
        UNIQUE (transaction_ref),

    CONSTRAINT chk_payments_amount
        CHECK (amount > 0)
);


-- ============================================================
-- INDEXES
-- ============================================================

-- ------------------------------------------------------------
-- Customers
-- ------------------------------------------------------------

-- Supports:
-- WHERE is_active = TRUE
CREATE INDEX idx_customers_active
    ON customers (customer_id)
    WHERE is_active = TRUE;


-- ------------------------------------------------------------
-- Products
-- ------------------------------------------------------------

-- Supports category filtering and product listing.
CREATE INDEX idx_products_category_id
    ON products (category_id);

-- Supports:
-- WHERE category_id = ?
--   AND is_active = TRUE
-- ORDER BY created_at DESC
CREATE INDEX idx_products_category_active_created
    ON products (category_id, created_at DESC)
    WHERE is_active = TRUE;

-- Supports low-stock monitoring.
CREATE INDEX idx_products_low_stock
    ON products (stock_qty)
    WHERE is_active = TRUE
      AND stock_qty < 10;


-- ------------------------------------------------------------
-- Orders
-- ------------------------------------------------------------

-- Supports:
-- WHERE customer_id = ?
-- ORDER BY ordered_at DESC
CREATE INDEX idx_orders_customer_ordered_at
    ON orders (customer_id, ordered_at DESC);

-- Supports operational queries such as:
-- WHERE status = 'pending'
-- ORDER BY ordered_at
CREATE INDEX idx_orders_pending_ordered_at
    ON orders (ordered_at)
    WHERE status = 'pending';


-- ------------------------------------------------------------
-- Order Items
-- ------------------------------------------------------------

-- UNIQUE(order_id, product_id) already creates an index
-- beginning with order_id.

-- Supports:
-- WHERE product_id = ?
CREATE INDEX idx_order_items_product_id
    ON order_items (product_id);


-- ------------------------------------------------------------
-- Payments
-- ------------------------------------------------------------

-- Supports payment lookup by order.
CREATE INDEX idx_payments_order_id
    ON payments (order_id);

-- Supports unpaid/failed payment processing.
CREATE INDEX idx_payments_pending
    ON payments (created_at)
    WHERE status IN ('pending', 'failed');


-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO categories (name)
VALUES
    ('Electronics'),
    ('Accessories'),
    ('Office');

INSERT INTO products (
    category_id,
    sku,
    name,
    description,
    price,
    stock_qty
)
SELECT
    category_id,
    'LAPTOP-001',
    'Business Laptop',
    '14-inch business laptop',
    1299.99,
    25
FROM categories
WHERE name = 'Electronics';

INSERT INTO products (
    category_id,
    sku,
    name,
    description,
    price,
    stock_qty
)
SELECT
    category_id,
    'MOUSE-001',
    'Wireless Mouse',
    'Ergonomic wireless mouse',
    49.99,
    100
FROM categories
WHERE name = 'Accessories';


-- ============================================================
-- SAMPLE QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- 1. Customer order history
-- ------------------------------------------------------------

SELECT
    o.order_id,
    o.status,
    o.total_amount,
    o.ordered_at
FROM orders AS o
WHERE o.customer_id = 1001
ORDER BY o.ordered_at DESC
LIMIT 20;


-- ------------------------------------------------------------
-- 2. Active products by category
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.sku,
    p.name,
    p.price,
    p.stock_qty
FROM products AS p
WHERE p.category_id = 1
  AND p.is_active = TRUE
ORDER BY p.created_at DESC
LIMIT 50;


-- ------------------------------------------------------------
-- 3. Complete order details
-- ------------------------------------------------------------

SELECT
    o.order_id,
    o.status,
    p.sku,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM orders AS o
INNER JOIN order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN products AS p
    ON p.product_id = oi.product_id
WHERE o.order_id = 1001
ORDER BY oi.order_item_id;


-- ------------------------------------------------------------
-- 4. Pending orders
-- ------------------------------------------------------------

SELECT
    o.order_id,
    o.customer_id,
    o.total_amount,
    o.ordered_at
FROM orders AS o
WHERE o.status = 'pending'
ORDER BY o.ordered_at
LIMIT 100;


-- ------------------------------------------------------------
-- 5. Low-stock products
-- ------------------------------------------------------------

SELECT
    p.product_id,
    p.sku,
    p.name,
    p.stock_qty
FROM products AS p
WHERE p.is_active = TRUE
  AND p.stock_qty < 10
ORDER BY p.stock_qty ASC;


-- ============================================================
-- TRANSACTION EXAMPLE
-- ============================================================

-- Create an order and reserve inventory atomically.

BEGIN;

-- Create order.
INSERT INTO orders (
    customer_id,
    status
)
VALUES (
    1001,
    'pending'
)
RETURNING order_id;


-- Lock product row before modifying inventory.
SELECT
    product_id,
    price,
    stock_qty
FROM products
WHERE product_id = 1
  AND is_active = TRUE
FOR UPDATE;


-- Reduce inventory.
UPDATE products
SET
    stock_qty = stock_qty - 2,
    updated_at = CURRENT_TIMESTAMP
WHERE product_id = 1
  AND is_active = TRUE
  AND stock_qty >= 2;


-- Insert order item.
INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    1,
    product_id,
    2,
    price
FROM products
WHERE product_id = 1;


-- Calculate order total.
UPDATE orders AS o
SET
    total_amount = (
        SELECT COALESCE(
            SUM(oi.quantity * oi.unit_price),
            0
        )
        FROM order_items AS oi
        WHERE oi.order_id = o.order_id
    ),
    updated_at = CURRENT_TIMESTAMP
WHERE o.order_id = 1;

COMMIT;


-- ============================================================
-- QUERY ANALYSIS
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.status,
    o.total_amount,
    o.ordered_at
FROM orders AS o
WHERE o.customer_id = 1001
ORDER BY o.ordered_at DESC
LIMIT 20;


-- ============================================================
-- MAINTENANCE NOTES
-- ============================================================

-- Keep statistics current after significant data changes.
ANALYZE customers;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
ANALYZE payments;

COMMIT;