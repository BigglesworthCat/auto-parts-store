package com.kriuchkov.autopartsstore.service.supplier;

import com.kriuchkov.autopartsstore.model.supplier.SupplierCategory;
import com.kriuchkov.autopartsstore.repository.supplier.SupplierCategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SupplierCategoryService {
    public final SupplierCategoryRepository supplierCategoryRepository;

    @Autowired
    public SupplierCategoryService(SupplierCategoryRepository supplierCategoryRepository) {
        this.supplierCategoryRepository = supplierCategoryRepository;
    }

    public SupplierCategory findById(Integer id) {
        return supplierCategoryRepository.findById(id).orElse(null);
    }

    public List<SupplierCategory> findAll() {
        return supplierCategoryRepository.findAll();
    }

    public SupplierCategory saveSupplierCategory(SupplierCategory supplierCategory) {
        return supplierCategoryRepository.save(supplierCategory);
    }

    public void deleteById(Integer id) {
        supplierCategoryRepository.deleteById(id);
    }
}
