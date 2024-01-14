CREATE TABLE IF NOT EXISTS customers_orders_statuses
(
    customer_order_status_id   SERIAL PRIMARY KEY,
    customer_order_status_name VARCHAR(30) NOT NULL,
    CONSTRAINT customers_orders_statuses_key
        UNIQUE (customer_order_status_name)
);

CREATE TABLE IF NOT EXISTS goods
(
    good_id   SERIAL PRIMARY KEY,
    good_name VARCHAR(30) NOT NULL,
    CONSTRAINT goods_key
        UNIQUE (good_name)
);

CREATE TABLE IF NOT EXISTS overheads
(
    overhead_id   SERIAL PRIMARY KEY,
    overhead_name VARCHAR(30)   NOT NULL,
    overhead_cost INT DEFAULT 0 NOT NULL,
    CONSTRAINT overheads_key
        UNIQUE (overhead_name),
    CONSTRAINT overheads_check
        CHECK (overhead_cost >= 0)
);

CREATE TABLE IF NOT EXISTS store_orders_statuses
(
    store_order_status_id   SERIAL PRIMARY KEY,
    store_order_status_name VARCHAR(30) NOT NULL,
    CONSTRAINT store_orders_statuses_key
        UNIQUE (store_order_status_name)
);

CREATE TABLE IF NOT EXISTS suppliers_categories
(
    supplier_category_id   SERIAL PRIMARY KEY,
    supplier_category_name VARCHAR(30) NOT NULL,
    CONSTRAINT suppliers_categories_key
        UNIQUE (supplier_category_name)
);

CREATE TABLE IF NOT EXISTS suppliers_statuses
(
    supplier_status_id   SERIAL PRIMARY KEY,
    supplier_status_name VARCHAR(30) NOT NULL,
    CONSTRAINT suppliers_statuses_key
        UNIQUE (supplier_status_name)
);

CREATE TABLE IF NOT EXISTS suppliers
(
    supplier_id          SERIAL PRIMARY KEY,
    supplier_name        VARCHAR(30)   NOT NULL,
    supplier_category_id INT DEFAULT 1 NOT NULL,
    supplier_status_id   INT DEFAULT 1 NOT NULL,
    CONSTRAINT suppliers_key
        UNIQUE (supplier_name),
    CONSTRAINT suppliers_suppliers_categories_supplier_category_id_fk
        FOREIGN KEY (supplier_category_id) REFERENCES suppliers_categories (supplier_category_id)
            ON UPDATE CASCADE,
    CONSTRAINT suppliers_suppliers_statuses_supplier_status_id_fk
        FOREIGN KEY (supplier_status_id) REFERENCES suppliers_statuses (supplier_status_id)
            ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS catalogue
(
    sku_id         SERIAL PRIMARY KEY,
    good_id        INT           NOT NULL,
    supplier_id    INT           NOT NULL,
    supplier_price INT DEFAULT 0 NOT NULL,
    store_price    INT DEFAULT 0 NOT NULL,
    delivery_days  INT DEFAULT 1 NOT NULL,
    CONSTRAINT catalogue_key
        UNIQUE (good_id, supplier_id),
    CONSTRAINT catalogue_goods_good_id_fk
        FOREIGN KEY (good_id) REFERENCES goods (good_id)
            ON UPDATE CASCADE,
    CONSTRAINT catalogue_suppliers_supplier_id_fk
        FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
            ON UPDATE CASCADE,
    CONSTRAINT catalog_check
        CHECK (supplier_price >= 0 AND store_price >= 0 AND delivery_days >= 0)
);

CREATE TABLE IF NOT EXISTS customers_orders
(
    customer_order_id        SERIAL PRIMARY KEY,
    sku_id                   INT                       NOT NULL,
    sku_amount               INT  DEFAULT 1            NOT NULL,
    defected_sku_amount      INT  DEFAULT 0            NULL,
    customer_order_status_id INT  DEFAULT 1            NOT NULL,
    customer_order_date      DATE DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT customers_orders_catalogue_sku_id_fk
        FOREIGN KEY (sku_id) REFERENCES catalogue (sku_id)
            ON UPDATE CASCADE,
    CONSTRAINT customers_orders_statuses_id_fk
        FOREIGN KEY (customer_order_status_id) REFERENCES customers_orders_statuses (customer_order_status_id)
            ON UPDATE CASCADE,
    CONSTRAINT customer_order_check
        CHECK (sku_amount >= 1 AND defected_sku_amount BETWEEN 0 AND sku_amount)
);

CREATE TABLE IF NOT EXISTS inventory_reports
(
    inventory_report_date DATE NOT NULL,
    sku_id                INT  NULL,
    sku_amount            INT  NOT NULL,
    CONSTRAINT inventory_reports_pk
        UNIQUE (inventory_report_date, sku_id),
    CONSTRAINT inventory_reports_catalogue_sku_id_fk
        FOREIGN KEY (sku_id) REFERENCES catalogue (sku_id)
            ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS storage
(
    cell_id            SERIAL PRIMARY KEY,
    sku_id             INT  DEFAULT 1            NULL,
    sku_amount         INT                       NOT NULL,
    cell_capacity      INT  DEFAULT 20           NOT NULL,
    replenishment_date DATE DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT storage_key
        UNIQUE (sku_id),
    CONSTRAINT storage_catalogue_sku_id_fk
        FOREIGN KEY (sku_id) REFERENCES catalogue (sku_id)
            ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT storage_check
        CHECK (cell_capacity >= 0 AND sku_amount BETWEEN 0 AND cell_capacity)
);

CREATE TABLE IF NOT EXISTS store_orders
(
    store_order_id        SERIAL PRIMARY KEY,
    sku_id                INT                       NOT NULL,
    sku_amount            INT  DEFAULT 1            NOT NULL,
    store_order_status_id INT  DEFAULT 1            NOT NULL,
    store_order_date      DATE DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT store_orders_catalogue_sku_id_fk
        FOREIGN KEY (sku_id) REFERENCES catalogue (sku_id)
            ON UPDATE CASCADE,
    CONSTRAINT store_orders_store_orders_statuses_store_order_status_id_fk
        FOREIGN KEY (store_order_status_id) REFERENCES store_orders_statuses (store_order_status_id)
            ON UPDATE CASCADE,
    CONSTRAINT store_orders_check
        CHECK (sku_amount >= 1)
);