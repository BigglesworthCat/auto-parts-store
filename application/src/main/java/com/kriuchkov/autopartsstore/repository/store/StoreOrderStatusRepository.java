package com.kriuchkov.autopartsstore.repository.store;

import com.kriuchkov.autopartsstore.model.store.StoreOrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoreOrderStatusRepository extends JpaRepository<StoreOrderStatus, Integer> {
}
