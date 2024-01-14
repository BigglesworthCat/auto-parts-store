package com.kriuchkov.autopartsstore.repository;

import com.kriuchkov.autopartsstore.model.Catalogue;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CatalogueRepository extends JpaRepository<Catalogue, Integer> {
}
