package com.kriuchkov.autopartsstore.service.customer;

import com.kriuchkov.autopartsstore.model.customer.CustomerOrderStatus;
import com.kriuchkov.autopartsstore.repository.customer.CustomerOrderStatusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerOrderStatusService {
    public final CustomerOrderStatusRepository storeOrderRepository;

    @Autowired
    public CustomerOrderStatusService(CustomerOrderStatusRepository storeOrderRepository) {
        this.storeOrderRepository = storeOrderRepository;
    }

    public CustomerOrderStatus findById(Integer id) {
        return storeOrderRepository.findById(id).orElse(null);
    }

    public List<CustomerOrderStatus> findAll() {
        return storeOrderRepository.findAll();
    }

    public CustomerOrderStatus saveCustomerOrderStatus(CustomerOrderStatus storeOrder) {
        return storeOrderRepository.save(storeOrder);
    }

    public void deleteById(Integer id) {
        storeOrderRepository.deleteById(id);
    }
}
