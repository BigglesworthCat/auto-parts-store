package com.kriuchkov.autopartsstore.model;

import com.kriuchkov.autopartsstore.model.customer.CustomerOrder;
import com.kriuchkov.autopartsstore.model.storage.Storage;
import com.kriuchkov.autopartsstore.model.store.StoreOrder;
import com.kriuchkov.autopartsstore.model.supplier.Supplier;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.persistence.*;
import java.util.Set;

@Data
@Entity
@Table(name = "catalogue")
public class Catalogue {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sku_id")
    private Integer id;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne
    @JoinColumn(name = "good_id")
    private Good good;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;

    @Column(name = "supplier_price")
    private Integer supplierPrice;

    @Column(name = "store_price")
    private Integer storePrice;

    @Column(name = "delivery_days")
    private Integer deliveryDays;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "catalogue")
    private Set<CustomerOrder> customerOrder;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "catalogue")
    private Set<StoreOrder> storeOrder;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "catalogue")
    private Set<Storage> storage;
}
