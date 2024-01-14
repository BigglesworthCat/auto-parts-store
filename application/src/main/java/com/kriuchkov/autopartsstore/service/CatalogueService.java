package com.kriuchkov.autopartsstore.service;

import com.kriuchkov.autopartsstore.model.Catalogue;
import com.kriuchkov.autopartsstore.repository.CatalogueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CatalogueService {
    public final CatalogueRepository catalogueRepository;

    @Autowired
    public CatalogueService(CatalogueRepository catalogueRepository) {
        this.catalogueRepository = catalogueRepository;
    }

    public Catalogue findById(Integer id) {
        return catalogueRepository.findById(id).orElse(null);
    }

    public List<Catalogue> findAll() {
        return catalogueRepository.findAll();
    }

    public Catalogue saveCatalogue(Catalogue catalogue) {
        return catalogueRepository.save(catalogue);
    }

    public void deleteById(Integer id) {
        catalogueRepository.deleteById(id);
    }
}
