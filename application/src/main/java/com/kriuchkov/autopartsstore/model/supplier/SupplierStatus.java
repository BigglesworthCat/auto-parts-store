package com.kriuchkov.autopartsstore.model.supplier;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.persistence.*;
import java.util.Set;

@Data
@Entity
@Table(name = "suppliers_statuses")
public class SupplierStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "supplier_status_id")
    private Integer id;

    @Column(name = "supplier_status_name")
    private String name;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "supplierStatus")
    private Set<Supplier> suppliers;
}
