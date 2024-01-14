package com.kriuchkov.autopartsstore.service.supplier;

import com.kriuchkov.autopartsstore.model.supplier.Supplier;
import com.kriuchkov.autopartsstore.repository.supplier.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SupplierService {
    public final SupplierRepository supplierRepository;

    @Autowired
    public SupplierService(SupplierRepository supplierRepository) {
        this.supplierRepository = supplierRepository;
    }

    public Supplier findById(Integer id) {
        return supplierRepository.findById(id).orElse(null);
    }

    public List<Supplier> findAll() {
        return supplierRepository.findAll();
    }

    public Supplier saveSupplier(Supplier supplier) {
        return supplierRepository.save(supplier);
    }

    public void deleteById(Integer id) {
        supplierRepository.deleteById(id);
    }
}
