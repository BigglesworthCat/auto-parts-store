package com.kriuchkov.autopartsstore.model.customer;

import com.kriuchkov.autopartsstore.model.Catalogue;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.persistence.*;
import java.sql.Date;

@Data
@Entity
@Table(name = "customers_orders")
public class CustomerOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_order_id")
    private Integer id;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne
    @JoinColumn(name = "sku_id")
    private Catalogue catalogue;

    @Column(name = "sku_amount")
    private Integer skuAmount;

    @Column(name = "defected_sku_amount")
    private Integer defectedSkuAmount;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne
    @JoinColumn(name = "customer_order_status_id")
    private CustomerOrderStatus customerOrderStatus;

    @Column(name = "customer_order_date")
    private Date date;
}
