package com.kriuchkov.autopartsstore.repository.supplier;

import com.kriuchkov.autopartsstore.model.supplier.SupplierStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupplierStatusRepository extends JpaRepository<SupplierStatus, Integer> {
}
