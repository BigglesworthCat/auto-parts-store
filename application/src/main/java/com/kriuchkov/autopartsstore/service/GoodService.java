package com.kriuchkov.autopartsstore.service;

import com.kriuchkov.autopartsstore.model.Good;
import com.kriuchkov.autopartsstore.repository.GoodRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GoodService {
    public final GoodRepository goodRepository;

    @Autowired
    public GoodService(GoodRepository goodRepository) {
        this.goodRepository = goodRepository;
    }

    public Good findById(Integer id) {
        return goodRepository.findById(id).orElse(null);
    }

    public List<Good> findAll() {
        return goodRepository.findAll();
    }

    public Good saveGood(Good good) {
        return goodRepository.save(good);
    }

    public void deleteById(Integer id) {
        goodRepository.deleteById(id);
    }
}
