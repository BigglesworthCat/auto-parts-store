package com.kriuchkov.autopartsstore.repository.supplier;

import com.kriuchkov.autopartsstore.model.supplier.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupplierRepository extends JpaRepository<Supplier, Integer> {
}
