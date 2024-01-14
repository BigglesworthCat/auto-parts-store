CREATE OR REPLACE FUNCTION insert_catalogue_func()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.store_price := NEW.supplier_price * 1.2;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_catalogue
    BEFORE INSERT
    ON catalogue
    FOR EACH ROW
EXECUTE FUNCTION insert_catalogue_func();

CREATE OR REPLACE FUNCTION update_catalogue_func()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.store_price = 0 THEN
        NEW.store_price := NEW.supplier_price * 1.2;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_catalogue
    BEFORE UPDATE
    ON catalogue
    FOR EACH ROW
EXECUTE FUNCTION update_catalogue_func();

CREATE OR REPLACE FUNCTION insert_customers_orders_func()
    RETURNS TRIGGER AS
$$
DECLARE
    cell_in_storage INT;
    status_paid     INT;
    status_accepted INT;
BEGIN
    SELECT cell_id
    INTO cell_in_storage
    FROM storage
    WHERE storage.sku_id = NEW.sku_id
      AND storage.sku_amount >= NEW.sku_amount;

    SELECT customer_order_status_id
    INTO status_paid
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Оплачено';

    SELECT customer_order_status_id
    INTO status_accepted
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Заявку прийнято';

    IF cell_in_storage IS NOT NULL THEN
        NEW.customer_order_status_id := status_paid;
        UPDATE storage SET sku_amount = sku_amount - NEW.sku_amount WHERE sku_id = NEW.sku_id;
    ELSE
        NEW.customer_order_status_id := status_accepted;
        NEW.defected_sku_amount := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_customers_orders
    BEFORE INSERT
    ON customers_orders
    FOR EACH ROW
EXECUTE FUNCTION insert_customers_orders_func();

CREATE OR REPLACE FUNCTION update_customers_orders_func()
    RETURNS TRIGGER AS
$$
DECLARE
    send_order_id  INT;
    taken_order_id INT;
BEGIN
    NEW.customer_order_id := OLD.customer_order_id;
    NEW.sku_id := OLD.sku_id;
    NEW.sku_amount := OLD.sku_amount;
    NEW.customer_order_date := OLD.customer_order_date;

    SELECT customer_order_status_id
    INTO send_order_id
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Заявку прийнято';

    SELECT customer_order_status_id
    INTO taken_order_id
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Оплачено';

    IF OLD.customer_order_status_id = send_order_id AND NEW.customer_order_status_id = send_order_id THEN
        NEW.defected_sku_amount := 0;
    END IF;

    IF OLD.customer_order_status_id = taken_order_id AND NEW.customer_order_status_id = send_order_id THEN
        NEW.customer_order_status_id := OLD.customer_order_status_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customers_orders
    BEFORE UPDATE
    ON customers_orders
    FOR EACH ROW
EXECUTE FUNCTION update_customers_orders_func();

CREATE OR REPLACE FUNCTION insert_store_orders_func()
    RETURNS TRIGGER AS
$$
BEGIN
    SELECT store_order_status_id
    INTO NEW.store_order_status_id
    FROM store_orders_statuses
    WHERE store_order_status_name = 'Заявку надіслано';

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_store_orders
    BEFORE INSERT
    ON store_orders
    FOR EACH ROW
EXECUTE FUNCTION insert_store_orders_func();

CREATE OR REPLACE FUNCTION update_store_orders_func()
    RETURNS TRIGGER AS
$$
DECLARE
    send_order_id        INT;
    taken_order_id       INT;
    storage_sku_capacity INT;
    storage_sku_amount   INT;
BEGIN
    NEW.store_order_id := OLD.store_order_id;
    NEW.sku_id := OLD.sku_id;
    NEW.sku_amount := OLD.sku_amount;
    NEW.store_order_date := OLD.store_order_date;

    SELECT store_order_status_id
    INTO send_order_id
    FROM store_orders_statuses
    WHERE store_order_status_name = 'Заявку надіслано';

    SELECT store_order_status_id
    INTO taken_order_id
    FROM store_orders_statuses
    WHERE store_order_status_name = 'Прийнято';

    IF OLD.store_order_status_id = send_order_id AND NEW.store_order_status_id = taken_order_id THEN
        SELECT cell_capacity, sku_amount
        INTO storage_sku_capacity, storage_sku_amount
        FROM storage
        WHERE storage.sku_id = OLD.sku_id;

        INSERT INTO storage(sku_id, sku_amount, cell_capacity, replenishment_date)
        VALUES (OLD.sku_id, OLD.sku_amount, GREATEST(OLD.sku_amount * 2, 20), NOW())
        ON CONFLICT (sku_id) DO UPDATE SET cell_capacity      = GREATEST(EXCLUDED.sku_amount + storage.sku_amount,
                                                                         storage.cell_capacity),
                                           sku_amount         = storage.sku_amount + EXCLUDED.sku_amount,
                                           replenishment_date = NOW();
    ELSE
        NEW.store_order_status_id := OLD.store_order_status_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_store_orders
    BEFORE UPDATE
    ON store_orders
    FOR EACH ROW
EXECUTE FUNCTION update_store_orders_func();

CREATE OR REPLACE FUNCTION insert_storage_func()
    RETURNS TRIGGER AS
$$
DECLARE
    ordered_status_id  INT;
    payed_status_id    INT;
    found_order_id     INT;
    found_order_amount INT;
BEGIN
    SELECT customer_order_status_id
    INTO ordered_status_id
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Заявку прийнято';

    SELECT customer_order_status_id
    INTO payed_status_id
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Оплачено';

    WHILE NEW.sku_amount > 0
        LOOP
            SELECT customer_order_id
            INTO found_order_id
            FROM customers_orders
            WHERE sku_id = NEW.sku_id
              AND sku_amount <= NEW.sku_amount
              AND customer_order_status_id = ordered_status_id
            ORDER BY customer_order_date
            LIMIT 1;

            IF found_order_id IS NOT NULL THEN
                SELECT sku_amount
                INTO found_order_amount
                FROM customers_orders
                WHERE customer_order_id = found_order_id;

                UPDATE customers_orders
                SET customer_order_status_id = payed_status_id
                WHERE customer_order_id = found_order_id;

                NEW.sku_amount := NEW.sku_amount - found_order_amount;
            ELSE
                EXIT;
            END IF;
        END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_storage
    BEFORE INSERT
    ON storage
    FOR EACH ROW
EXECUTE FUNCTION insert_storage_func();


CREATE OR REPLACE FUNCTION update_storage_func()
    RETURNS TRIGGER AS
$$
DECLARE
    ordered_status_id  INT;
    payed_status_id    INT;
    found_order_id     INT;
    found_order_amount INT;
BEGIN
    SELECT customer_order_status_id
    INTO ordered_status_id
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Заявку прийнято';

    SELECT customer_order_status_id
    INTO payed_status_id
    FROM customers_orders_statuses
    WHERE customer_order_status_name = 'Оплачено';

    WHILE NEW.sku_amount > 0
        LOOP
            SELECT customer_order_id
            INTO found_order_id
            FROM customers_orders
            WHERE sku_id = NEW.sku_id
              AND sku_amount <= NEW.sku_amount
              AND customer_order_status_id = ordered_status_id
            ORDER BY customer_order_date
            LIMIT 1;

            IF found_order_id IS NOT NULL THEN
                SELECT sku_amount
                INTO found_order_amount
                FROM customers_orders
                WHERE customer_order_id = found_order_id;

                UPDATE customers_orders
                SET customer_order_status_id = payed_status_id
                WHERE customer_order_id = found_order_id;

                NEW.sku_amount := NEW.sku_amount - found_order_amount;
            ELSE
                EXIT;
            END IF;
        END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_storage
    BEFORE UPDATE
    ON storage
    FOR EACH ROW
EXECUTE FUNCTION update_storage_func();