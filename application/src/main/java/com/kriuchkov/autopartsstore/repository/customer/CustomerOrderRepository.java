package com.kriuchkov.autopartsstore.repository.customer;

import com.kriuchkov.autopartsstore.model.customer.CustomerOrder;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Integer> {
}
