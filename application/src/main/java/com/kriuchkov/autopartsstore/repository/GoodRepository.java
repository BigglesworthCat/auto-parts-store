package com.kriuchkov.autopartsstore.repository;

import com.kriuchkov.autopartsstore.model.Good;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GoodRepository extends JpaRepository<Good, Integer> {
}
