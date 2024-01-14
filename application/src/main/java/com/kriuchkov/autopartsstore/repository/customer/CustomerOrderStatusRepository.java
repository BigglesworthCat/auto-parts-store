package com.kriuchkov.autopartsstore.repository.customer;

import com.kriuchkov.autopartsstore.model.customer.CustomerOrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerOrderStatusRepository extends JpaRepository<CustomerOrderStatus, Integer> {
}
