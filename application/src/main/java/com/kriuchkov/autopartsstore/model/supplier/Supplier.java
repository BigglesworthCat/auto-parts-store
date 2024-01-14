package com.kriuchkov.autopartsstore.model.supplier;

import com.kriuchkov.autopartsstore.model.Catalogue;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.persistence.*;
import java.util.Set;

@Data
@Entity
@Table(name = "suppliers")
public class Supplier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "supplier_id")
    private Integer id;

    @Column(name = "supplier_name")
    private String name;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne
    @JoinColumn(name = "supplier_category_id")
    private SupplierCategory supplierCategory;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne
    @JoinColumn(name = "supplier_status_id")
    private SupplierStatus supplierStatus;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "supplier")
    private Set<Catalogue> catalogue;
}
