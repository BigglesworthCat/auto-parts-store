package com.kriuchkov.autopartsstore.service.storage;

import com.kriuchkov.autopartsstore.model.storage.Storage;
import com.kriuchkov.autopartsstore.repository.storage.StorageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StorageService {
    public final StorageRepository storageRepository;

    @Autowired
    public StorageService(StorageRepository storageRepository) {
        this.storageRepository = storageRepository;
    }

    public Storage findById(Integer id) {
        return storageRepository.findById(id).orElse(null);
    }

    public List<Storage> findAll() {
        return storageRepository.findAll();
    }

    public Storage saveStorage(Storage storage) {
        return storageRepository.save(storage);
    }

    public void deleteById(Integer id) {
        storageRepository.deleteById(id);
    }
}
