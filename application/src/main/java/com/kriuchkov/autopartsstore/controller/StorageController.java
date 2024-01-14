package com.kriuchkov.autopartsstore.controller;

import com.kriuchkov.autopartsstore.model.storage.Storage;
import com.kriuchkov.autopartsstore.service.storage.StorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/storage")
public class StorageController {
    public final StorageService storageService;

    @Autowired
    public StorageController(StorageService storageService) {
        this.storageService = storageService;
    }

    @GetMapping("/storage_list")
    public String findAll(Model model) {
        List<Storage> storages = storageService.findAll();
        model.addAttribute("storages", storages);
        return "storage/storage_list";
    }
}
