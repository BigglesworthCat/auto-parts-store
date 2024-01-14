package com.kriuchkov.autopartsstore.service.supplier;

import com.kriuchkov.autopartsstore.model.supplier.SupplierStatus;
import com.kriuchkov.autopartsstore.repository.supplier.SupplierStatusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SupplierStatusService {
    public final SupplierStatusRepository supplierStatusRepository;

    @Autowired
    public SupplierStatusService(SupplierStatusRepository supplierStatusRepository) {
        this.supplierStatusRepository = supplierStatusRepository;
    }

    public SupplierStatus findById(Integer id) {
        return supplierStatusRepository.findById(id).orElse(null);
    }

    public List<SupplierStatus> findAll() {
        return supplierStatusRepository.findAll();
    }

    public SupplierStatus saveSupplierStatus(SupplierStatus supplierStatus) {
        return supplierStatusRepository.save(supplierStatus);
    }

    public void deleteById(Integer id) {
        supplierStatusRepository.deleteById(id);
    }
}
