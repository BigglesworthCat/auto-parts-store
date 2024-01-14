CREATE OR REPLACE VIEW catalogue_view AS
SELECT c.sku_id,
       g.good_name,
       s.supplier_name,
       sc.supplier_category_name,
       c.supplier_price,
       c.store_price,
       c.delivery_days
FROM catalogue c
         JOIN
     goods g ON c.good_id = g.good_id
         JOIN
     suppliers s ON c.supplier_id = s.supplier_id
         JOIN
     suppliers_categories sc ON s.supplier_category_id = sc.supplier_category_id;

CREATE OR REPLACE VIEW store_orders_view AS
SELECT so.store_order_id,
       so.sku_id,
       cv.good_name,
       cv.supplier_name,
       cv.supplier_category_name,
       so.sku_amount,
       cv.supplier_price,
       cv.store_price,
       sos.store_order_status_name,
       so.store_order_date
FROM store_orders so
         JOIN
     store_orders_statuses sos ON so.store_order_status_id = sos.store_order_status_id
         JOIN
     catalogue_view cv ON so.sku_id = cv.sku_id;

CREATE OR REPLACE VIEW customers_orders_view AS
SELECT co.customer_order_id,
       co.sku_id,
       cv.good_name,
       cv.supplier_name,
       cv.supplier_category_name,
       co.sku_amount,
       co.defected_sku_amount,
       CASE
           WHEN cv.supplier_category_name IN ('Виробник', 'Дилер') THEN co.sku_amount
           ELSE co.sku_amount - co.defected_sku_amount
           END AS result_sku_amount,
       cv.supplier_price,
       cv.store_price,
       cos.customer_order_status_name,
       co.customer_order_date
FROM customers_orders co
         JOIN
     customers_orders_statuses cos ON co.customer_order_status_id = cos.customer_order_status_id
         JOIN
     catalogue_view cv ON co.sku_id = cv.sku_id;

CREATE OR REPLACE VIEW cash_report_view AS
SELECT sov.good_name,
       sov.supplier_name                   AS supplier_customer_id,
       sov.sku_amount * sov.supplier_price AS store_purchase,
       0                                   AS customers_purchase,
       sov.store_order_date                AS operation_date
FROM store_orders_view sov
WHERE sov.store_order_status_name = 'Прийнято'

UNION

SELECT cov.good_name,
       cov.supplier_name,
       0,
       cov.sku_amount * cov.store_price,
       cov.customer_order_date
FROM customers_orders_view cov
WHERE cov.customer_order_status_name = 'Оплачено';

CREATE OR REPLACE VIEW catalogue_view AS
SELECT c.sku_id,
       g.good_name,
       s.supplier_name,
       sc.supplier_category_name,
       c.supplier_price,
       c.store_price,
       c.delivery_days
FROM catalogue c
         JOIN
     goods g ON c.good_id = g.good_id
         JOIN
     suppliers s ON c.supplier_id = s.supplier_id
         JOIN
     suppliers_categories sc ON s.supplier_category_id = sc.supplier_category_id;

CREATE OR REPLACE VIEW inventory_reports_view AS
SELECT ir.inventory_report_date,
       ir.sku_id,
       cv.good_name,
       cv.supplier_name,
       ir.sku_amount
FROM inventory_reports ir
         JOIN
     catalogue_view cv ON ir.sku_id = cv.sku_id;

CREATE OR REPLACE VIEW storage_view AS
SELECT st.cell_id,
       st.sku_id,
       cv.good_name,
       cv.supplier_name,
       cv.supplier_category_name,
       st.sku_amount,
       st.cell_capacity,
       st.replenishment_date
FROM storage st
         JOIN
     catalogue_view cv ON st.sku_id = cv.sku_id;
