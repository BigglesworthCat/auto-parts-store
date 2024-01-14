CREATE OR REPLACE FUNCTION suppliers_by_good(good VARCHAR(30), supplier_category VARCHAR(30))
    RETURNS TABLE
            (
                supplier_name VARCHAR(30),
                count         BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT cv.supplier_name, COUNT(*)
                 FROM catalogue_view cv
                 WHERE cv.good_name = good
                   AND cv.supplier_category_name = supplier_category
                 GROUP BY cv.supplier_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION suppliers_by_good_in_period(good VARCHAR(30), supplier_category VARCHAR(30), amount INT,
                                                       since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                supplier_name VARCHAR(30),
                count         BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT sov.supplier_name, COUNT(*)
                 FROM store_orders_view sov
                 WHERE sov.good_name = good
                   AND sov.store_order_status_name = 'Прийнято'
                   AND sov.supplier_category_name = supplier_category
                   AND sov.sku_amount >= amount
                   AND sov.store_order_date BETWEEN since_date AND until_date
                 GROUP BY sov.supplier_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION good_info(good VARCHAR(30))
    RETURNS SETOF catalogue_view AS
$$
BEGIN
    RETURN QUERY SELECT * FROM catalogue_view WHERE good_name = good;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION good_sales_in_period(good VARCHAR(30), since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                customer_order_id   INT,
                good_name           VARCHAR(30),
                sku_amount          INT,
                customer_order_date DATE
            )
AS
$$
BEGIN
    RETURN QUERY SELECT v.customer_order_id, v.good_name, v.sku_amount, v.customer_order_date
                 FROM customers_orders_view v
                 WHERE v.good_name = good
                   AND v.customer_order_status_name = 'Оплачено'
                   AND v.customer_order_date BETWEEN since_date AND until_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION good_sales_by_amount(good VARCHAR(30), amount INT)
    RETURNS TABLE
            (
                customer_order_id   INT,
                good_name           VARCHAR(30),
                sku_amount          INT,
                customer_order_date DATE
            )
AS
$$
BEGIN
    RETURN QUERY SELECT v.customer_order_id, v.good_name, v.sku_amount, v.customer_order_date
                 FROM customers_orders_view v
                 WHERE v.good_name = good
                   AND v.sku_amount >= amount;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION storage_info()
    RETURNS SETOF storage_view AS
$$
BEGIN
    RETURN QUERY SELECT * FROM storage_view;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ten_best_sold_goods()
    RETURNS TABLE
            (
                good_name VARCHAR(30),
                sum       BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT v.good_name, SUM(v.sku_amount) AS sum
                 FROM customers_orders_view v
                 WHERE v.customer_order_status_name = 'Оплачено'
                 GROUP BY v.good_name
                 ORDER BY sum DESC
                 LIMIT 10;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ten_cheapest_suppliers_by_good(good VARCHAR(30))
    RETURNS TABLE
            (
                supplier_name  VARCHAR(30),
                supplier_price INT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT cv.supplier_name, cv.supplier_price
                 FROM catalogue_view cv
                 WHERE cv.good_name = good
                 ORDER BY cv.supplier_price
                 LIMIT 10;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION good_average_sales_by_months()
    RETURNS TABLE
            (
                good_name     VARCHAR(30),
                average_sales BIGINT
            )
AS
$$
DECLARE
    min_date DATE;
    max_date DATE;
    months   INT;
BEGIN
    SELECT DISTINCT customer_order_date
    INTO min_date
    FROM customers_orders_view
    WHERE customer_order_status_name = 'Оплачено'
    ORDER BY customer_order_date
    LIMIT 1;

    SELECT DISTINCT customer_order_date
    INTO max_date
    FROM customers_orders_view
    WHERE customer_order_status_name = 'Оплачено'
    ORDER BY customer_order_date DESC
    LIMIT 1;

    SELECT EXTRACT(MONTH FROM age(max_date, min_date)) + 1 INTO months;

    RETURN QUERY SELECT v.good_name, SUM(v.sku_amount) / NULLIF(months, 0) AS average_sales
                 FROM customers_orders_view v
                 WHERE v.customer_order_status_name = 'Оплачено'
                 GROUP BY v.good_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION suppliers_part_in_period(supplier VARCHAR(30), since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                part_percent        DECIMAL,
                cost_part           DECIMAL,
                amount_part_ratio   TEXT,
                profit_part_percent DECIMAL
            )
AS
$$
DECLARE
    amount_part  DECIMAL;
    amount_total DECIMAL;
    cost_part    DECIMAL;
    profit_part  DECIMAL;
    profit_total DECIMAL;
BEGIN
    SELECT SUM(sku_amount)
    INTO amount_part
    FROM store_orders_view
    WHERE store_order_status_name = 'Прийнято'
      AND supplier_name = supplier;

    SELECT SUM(sku_amount) INTO amount_total FROM store_orders_view WHERE store_order_status_name = 'Прийнято';

    SELECT SUM(sku_amount * supplier_price)
    INTO cost_part
    FROM store_orders_view
    WHERE store_order_status_name = 'Прийнято'
      AND supplier_name = supplier;

    SELECT SUM((sku_amount - defected_sku_amount) * (store_price - supplier_price))
    INTO profit_part
    FROM customers_orders_view
    WHERE customer_order_status_name = 'Оплачено'
      AND supplier_name = supplier
      AND customer_order_date BETWEEN since_date AND until_date;

    SELECT SUM((sku_amount - defected_sku_amount) * (store_price - supplier_price))
    INTO profit_total
    FROM customers_orders_view
    WHERE customer_order_status_name = 'Оплачено'
      AND customer_order_date BETWEEN since_date AND until_date;

    RETURN QUERY SELECT ROUND(amount_part / amount_total * 100, 3),
                        ROUND(cost_part, 2),
                        CONCAT(amount_part, '/', amount_total),
                        ROUND(profit_part / profit_total * 100, 3);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION overheads_part()
    RETURNS TABLE
            (
                part_percent DECIMAL
            )
AS
$$
DECLARE
    overheads_total DECIMAL;
    sell_total      DECIMAL;
BEGIN
    SELECT SUM(overhead_cost) INTO overheads_total FROM overheads;
    SELECT SUM((sku_amount - defected_sku_amount) * store_price)
    INTO sell_total
    FROM customers_orders_view
    WHERE customer_order_status_name = 'Оплачено';

    RETURN QUERY SELECT ROUND(overheads_total / sell_total * 100, 3) AS part_percent;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unsold_goods()
    RETURNS TABLE
            (
                unsold_percent DECIMAL,
                unsold_ratio   TEXT
            )
AS
$$
DECLARE
    unsold        INT;
    total_ordered INT;
BEGIN
    SELECT SUM(sku_amount) INTO unsold FROM storage_view;
    SELECT SUM(sku_amount) INTO total_ordered FROM store_orders_view WHERE store_order_status_name = 'Прийнято';

    RETURN QUERY SELECT ROUND((unsold::DECIMAL / total_ordered) * 100, 3), CONCAT(unsold, '/', total_ordered);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION suppliers_by_defected_sku_in_period(since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                good_name     VARCHAR(30),
                supplier_name VARCHAR(30),
                defected      BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT c.good_name, c.supplier_name, SUM(c.defected_sku_amount) AS defected
                 FROM customers_orders_view c
                 WHERE c.customer_order_status_name = 'Оплачено'
                   AND c.customer_order_date BETWEEN since_date AND until_date
                 GROUP BY c.sku_id, c.good_name, c.supplier_name
                 HAVING SUM(c.defected_sku_amount) != 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_defected_sku_in_period(since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                total_defected BIGINT
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT CAST(SUM(defected) AS BIGINT) AS total_defected
        FROM (SELECT SUM(defected_sku_amount) AS defected
              FROM customers_orders_view
              WHERE customer_order_status_name = 'Оплачено'
                AND customer_order_date BETWEEN since_date AND until_date
              GROUP BY sku_id) AS query;
END;
$$;

CREATE OR REPLACE FUNCTION sells_in_date(sale_date DATE)
    RETURNS TABLE
            (
                customer_order_id   INT,
                good_name           VARCHAR(30),
                supplier_name       VARCHAR(30),
                sku_amount          INT,
                defected_sku_amount INT,
                sum                 INT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT c.customer_order_id,
                        c.good_name,
                        c.supplier_name,
                        c.sku_amount,
                        c.defected_sku_amount,
                        c.result_sku_amount * c.store_price AS sum
                 FROM customers_orders_view c
                 WHERE c.customer_order_date = sale_date
                   AND c.customer_order_status_name = 'Оплачено';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_sells_in_date(sale_date DATE)
    RETURNS TABLE
            (
                total_amount  BIGINT,
                total_revenue BIGINT
            )
AS
$$
DECLARE
    total_revenue BIGINT;
    total_amount  BIGINT;
BEGIN
    SELECT SUM(result_sku_amount * store_price)
    INTO total_revenue
    FROM customers_orders_view
    WHERE customer_order_date = sale_date
      AND customer_order_status_name = 'Оплачено';

    SELECT SUM(result_sku_amount)
    INTO total_amount
    FROM customers_orders_view
    WHERE customer_order_date = sale_date
      AND customer_order_status_name = 'Оплачено';

    RETURN QUERY SELECT total_revenue, total_revenue;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cash_report_in_date(report_date DATE)
    RETURNS SETOF cash_report_view AS
$$
BEGIN
    RETURN QUERY SELECT * FROM cash_report_view WHERE operation_date = report_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_cash_report_in_date(report_date DATE)
    RETURNS TABLE
            (
                total_store_purchase     BIGINT,
                total_customers_purchase BIGINT
            )
AS
$$
DECLARE
    total_store_purchase     BIGINT;
    total_customers_purchase BIGINT;
BEGIN
    SELECT SUM(store_purchase) INTO total_store_purchase FROM cash_report_view WHERE operation_date = report_date;
    SELECT SUM(customers_purchase)
    INTO total_customers_purchase
    FROM cash_report_view
    WHERE operation_date = report_date;

    RETURN QUERY SELECT total_store_purchase, total_customers_purchase;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cash_report_in_period(since_date DATE, until_date DATE)
    RETURNS SETOF cash_report_view AS
$$
BEGIN
    RETURN QUERY SELECT * FROM cash_report_view WHERE operation_date BETWEEN since_date AND until_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_cash_report_in_period(since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                total_store_purchase     BIGINT,
                total_customers_purchase BIGINT
            )
AS
$$
DECLARE
    total_store_purchase     BIGINT;
    total_customers_purchase BIGINT;
BEGIN
    SELECT SUM(store_purchase)
    INTO total_store_purchase
    FROM cash_report_view
    WHERE operation_date BETWEEN since_date AND until_date;
    SELECT SUM(customers_purchase)
    INTO total_customers_purchase
    FROM cash_report_view
    WHERE operation_date BETWEEN since_date AND until_date;

    RETURN QUERY SELECT total_store_purchase, total_customers_purchase;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION inventory_report()
    RETURNS SETOF storage_view AS
$$
BEGIN
    RETURN QUERY SELECT * FROM storage_view;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION velocity_of_good(good VARCHAR(20), since_date DATE, until_date DATE)
    RETURNS TABLE
            (
                total_good_profit DECIMAL,
                average_reserve   DECIMAL,
                velocity          DECIMAL
            )
AS
$$
DECLARE
    total_good_profit DECIMAL;
    average_reserve   DECIMAL;
BEGIN
    SELECT SUM(result_sku_amount * store_price)
    INTO total_good_profit
    FROM customers_orders_view
    WHERE good_name = good
      AND customer_order_date BETWEEN since_date AND until_date;

    SELECT SUM(sku_amount * store_price) / 2
    INTO average_reserve
    FROM inventory_reports_view
             INNER JOIN catalogue ON inventory_reports_view.sku_id = catalogue.sku_id
    WHERE good_name = good
      AND (inventory_report_date = since_date OR inventory_report_date = until_date);

    RETURN QUERY SELECT total_good_profit,
                        average_reserve,
                        CASE WHEN average_reserve <> 0 THEN TRUNC(total_good_profit / average_reserve, 2) ELSE NULL END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION storage_free_space()
    RETURNS TABLE
            (
                free_space BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY SELECT SUM(cell_capacity - sku_amount) FROM storage_view;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION customers_bookings()
    RETURNS TABLE
            (
                customer_order_id   INT,
                good_name           VARCHAR(30),
                supplier_name       VARCHAR(30),
                sku_amount          INT,
                total_price         INT,
                customer_order_date DATE
            )
AS
$$
BEGIN
    RETURN QUERY SELECT c.customer_order_id,
                        c.good_name,
                        c.supplier_name,
                        c.sku_amount,
                        c.sku_amount * c.store_price AS total_price,
                        c.customer_order_date
                 FROM customers_orders_view c
                 WHERE c.customer_order_status_name = 'Заявку прийнято';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_customers_bookings()
    RETURNS TABLE
            (
                total_bookings BIGINT,
                total_sum      BIGINT
            )
AS
$$
DECLARE
    total_bookings BIGINT;
    total_sum      BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_bookings FROM customers_orders_view WHERE customer_order_status_name = 'Заявку прийнято';

    SELECT SUM(sku_amount * store_price)
    INTO total_sum
    FROM customers_orders_view
    WHERE customer_order_status_name = 'Заявку прийнято';

    RETURN QUERY SELECT total_bookings, total_sum;
END;
$$ LANGUAGE plpgsql;