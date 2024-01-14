package com.kriuchkov.autopartsstore.model.customer;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.persistence.*;
import java.util.Set;

@Data
@Entity
@Table(name = "customers_orders_statuses")
public class CustomerOrderStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_order_status_id")
    private Integer id;

    @Column(name = "customer_order_status_name")
    private String name;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "customerOrderStatus")
    private Set<CustomerOrder> customerOrder;
}
