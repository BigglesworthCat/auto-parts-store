package com.kriuchkov.autopartsstore.repository.storage;

import com.kriuchkov.autopartsstore.model.storage.Storage;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StorageRepository extends JpaRepository<Storage, Integer> {
}
