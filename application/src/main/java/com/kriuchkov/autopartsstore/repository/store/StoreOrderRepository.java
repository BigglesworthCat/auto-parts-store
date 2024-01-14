package com.kriuchkov.autopartsstore.repository.store;

import com.kriuchkov.autopartsstore.model.store.StoreOrder;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoreOrderRepository extends JpaRepository<StoreOrder, Integer> {
}
