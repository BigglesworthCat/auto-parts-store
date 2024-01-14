package com.kriuchkov.autopartsstore.service.store;

import com.kriuchkov.autopartsstore.model.store.StoreOrder;
import com.kriuchkov.autopartsstore.repository.store.StoreOrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StoreOrderService {
    public final StoreOrderRepository storeOrderRepository;

    @Autowired
    public StoreOrderService(StoreOrderRepository storeOrderRepository) {
        this.storeOrderRepository = storeOrderRepository;
    }

    public StoreOrder findById(Integer id) {
        return storeOrderRepository.findById(id).orElse(null);
    }

    public List<StoreOrder> findAll() {
        return storeOrderRepository.findAll();
    }

    public StoreOrder saveStoreOrder(StoreOrder storeOrder) {
        return storeOrderRepository.save(storeOrder);
    }

    public void deleteById(Integer id) {
        storeOrderRepository.deleteById(id);
    }
}
