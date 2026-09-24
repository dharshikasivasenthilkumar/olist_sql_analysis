/*--------------------
CREATE DATABASE
--------------------*/

CREATE DATABASE IF NOT EXISTS olist
  DEFAULT CHARACTER SET utf8mb4;
USE olist;

/*------------------------
CREATE TABLES
---------------------------*/

CREATE TABLE customers (
  customer_id              VARCHAR(50) PRIMARY KEY,
  customer_unique_id       VARCHAR(50) NOT NULL,   
  customer_zip_code_prefix VARCHAR(10),
  customer_city            VARCHAR(100),
  customer_state           CHAR(2)
);

CREATE TABLE orders (
  order_id                      VARCHAR(50) PRIMARY KEY,
  customer_id                   VARCHAR(50) NOT NULL,
  order_status                  VARCHAR(20),
  order_purchase_timestamp      DATETIME,
  order_approved_at             DATETIME,
  order_delivered_carrier_date  DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME
);

CREATE TABLE order_items (
  order_id      VARCHAR(50) NOT NULL,
  order_item_id INT NOT NULL,
  product_id    VARCHAR(50),
  seller_id     VARCHAR(50),
  price         DECIMAL(10,2),
  freight_value DECIMAL(10,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
  order_id             VARCHAR(50) NOT NULL,
  payment_sequential   INT NOT NULL,
  payment_type         VARCHAR(30),
  payment_installments INT,
  payment_value        DECIMAL(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
  review_id               VARCHAR(50),
  order_id                VARCHAR(50) NOT NULL,
  review_score            TINYINT,
  review_creation_date    DATETIME,
  review_answer_timestamp DATETIME
);

CREATE TABLE products (
  product_id            VARCHAR(50) PRIMARY KEY,
  product_category_name VARCHAR(100)
);

CREATE TABLE sellers (
  seller_id              VARCHAR(50) PRIMARY KEY,
  seller_zip_code_prefix VARCHAR(10),
  seller_city            VARCHAR(100),
  seller_state           CHAR(2)
);

CREATE TABLE product_category_translation (
  product_category_name         VARCHAR(100) PRIMARY KEY,
  product_category_name_english VARCHAR(100)
);


/*---------------------------------------------------------------------
Load csv files
----------------------------------------------------------------------*/
SET GLOBAL local_infile = 1;

SHOW GLOBAL VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, @state)
SET customer_state = TRIM(TRAILING '\r' FROM @state);


LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id, @shipping_limit, price, @freight)
SET freight_value = TRIM(TRAILING '\r' FROM @freight);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, @purchase, @approved, @carrier, @delivered, @estimated)
SET order_purchase_timestamp      = NULLIF(@purchase, ''),
    order_approved_at             = NULLIF(@approved, ''),
    order_delivered_carrier_date  = NULLIF(@carrier, ''),
    order_delivered_customer_date = NULLIF(@delivered, ''),
    order_estimated_delivery_date = NULLIF(TRIM(TRAILING '\r' FROM @estimated), '');



LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, payment_sequential, payment_type, payment_installments, @value)
SET payment_value = TRIM(TRAILING '\r' FROM @value);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id, order_id, review_score, @title, @message, @created, @answered)
SET review_creation_date    = NULLIF(@created, ''),
    review_answer_timestamp = NULLIF(TRIM(TRAILING '\r' FROM @answered), '');

LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, @category, @a, @b, @c, @d, @e, @f, @g)
SET product_category_name = NULLIF(@category, '');

SELECT * FROM order_reviews WHERE review_id = (
  SELECT review_id FROM order_reviews LIMIT 1 OFFSET 77916
);


LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id, seller_zip_code_prefix, seller_city, @state)
SET seller_state = TRIM(TRAILING '\r' FROM @state);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/OneDrive/Desktop/projects/sql_analysis/dataset/product_category_name_translation.csv'
INTO TABLE product_category_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_category_name, @english)
SET product_category_name_english = TRIM(TRAILING '\r' FROM @english);

/*---------------------------------------------------------------------
INDEXES 
---------------------------------------------------------------------*/
CREATE INDEX idx_orders_customer  ON orders (customer_id);
CREATE INDEX idx_items_product    ON order_items (product_id);
CREATE INDEX idx_items_seller     ON order_items (seller_id);
CREATE INDEX idx_reviews_order    ON order_reviews (order_id);
CREATE INDEX idx_customers_unique ON customers (customer_unique_id);


/*---------------------------------------------------------------------
CHECKS
---------------------------------------------------------------------*/
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders',         COUNT(*) FROM orders
UNION ALL SELECT 'order_items',    COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',  COUNT(*) FROM order_reviews
UNION ALL SELECT 'products',       COUNT(*) FROM products
UNION ALL SELECT 'sellers',        COUNT(*) FROM sellers
UNION ALL SELECT 'translation',    COUNT(*) FROM product_category_translation;

SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

SELECT SUM(order_delivered_customer_date IS NULL) AS missing_delivery_date,
       COUNT(*) AS total_orders
FROM orders;


-- ---------------------------------------------------------------------
-- Q1. Monthly revenue and month-over-month growth
-- Insight to write: which months grew fastest, and where does the
-- trend flatten?
-- ---------------------------------------------------------------------

WITH monthly AS (
  SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
         ROUND(SUM(oi.price), 2)                          AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY order_month
)
SELECT order_month,
       revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
                 / LAG(revenue) OVER (ORDER BY order_month), 1) AS mom_growth_pct
FROM monthly
ORDER BY order_month;


-- ---------------------------------------------------------------------
-- Q2. Revenue and average order value by product category
-- Insight to write: which categories bring the most revenue, and which
-- have a high order value but low volume?
-- ---------------------------------------------------------------------
SELECT COALESCE(t.product_category_name_english,
                p.product_category_name, 'unknown')  AS category,
       COUNT(DISTINCT oi.order_id)                   AS orders,
       ROUND(SUM(oi.price), 2)                       AS revenue,
       ROUND(SUM(oi.price) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
                AND o.order_status = 'delivered'
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_translation t
       ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY revenue DESC;


-- ---------------------------------------------------------------------
-- Q3. Repeat customers
-- Uses customer_unique_id: customer_id changes with every order, so
-- counting it would wrongly show almost no repeat buyers.
-- Insight to write: what share of customers buy again, and what could
-- the business do about it?
-- ---------------------------------------------------------------------
WITH customer_orders AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS orders
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT COUNT(*)                              AS customers,
       SUM(orders > 1)                       AS repeat_customers,
       ROUND(100 * SUM(orders > 1) / COUNT(*), 2) AS repeat_pct
FROM customer_orders;

-- ---------------------------------------------------------------------
-- Q4. revenue and orders by state
-- ---------------------------------------------------------------------


SELECT c.customer_state                              AS state,
       COUNT(DISTINCT o.order_id)                     AS orders,
       ROUND(SUM(oi.price), 2)                        AS revenue,
       ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

/*-- --------------------------------------------------------------------------------
--Q5 review scores by category
--
----------------------------------------------------------------------------------*/


SELECT COALESCE(t.product_category_name_english,
                p.product_category_name, 'unknown')  AS category,
			COUNT(DISTINCT o.order_id)                     AS orders,
			ROUND(AVG(r.review_score), 2)                 AS avg_review_score
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id - oi.product_id
LEFT JOIN product_category_translation t
       ON t.product_category_name = p.product_category_name
JOIN order_reviews r    ON r.order_id = oi.order_id
GROUP BY category
HAVING orders >= 30
ORDER BY avg_review_score ASC;

/*-- --------------------------------------------------------------------------------
--Q6 average delivery time and % of late deliveries
--
----------------------------------------------------------------------------------*/

SELECT
  COUNT(*)                                                        AS delivered_orders,
  ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                      order_purchase_timestamp)), 1)               AS avg_delivery_days,
  SUM(order_delivered_customer_date > order_estimated_delivery_date) AS late_orders,
  ROUND(100 * SUM(order_delivered_customer_date > order_estimated_delivery_date)
            / COUNT(*), 2)                                         AS late_pct
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

/*-- --------------------------------------------------------------------------------
--Q7 delivery performance by state--
----------------------------------------------------------------------------------*/


SELECT c.customer_state                                                AS state,
       COUNT(*)                                                        AS delivered_orders,
	   ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                      order_purchase_timestamp)), 1)                    AS avg_delivery_days, 
	   ROUND(100 * SUM(order_delivered_customer_date > order_estimated_delivery_date)
            / COUNT(*), 2)                                              AS late_pct
FROM orders o
JOIN customers c    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
 AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING delivered_orders >= 30
ORDER BY late_pct DESC;