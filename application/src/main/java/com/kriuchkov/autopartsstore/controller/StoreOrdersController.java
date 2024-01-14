package com.kriuchkov.autopartsstore.controller;

import com.kriuchkov.autopartsstore.model.Catalogue;
import com.kriuchkov.autopartsstore.model.store.StoreOrder;
import com.kriuchkov.autopartsstore.model.store.StoreOrderStatus;
import com.kriuchkov.autopartsstore.service.CatalogueService;
import com.kriuchkov.autopartsstore.service.store.StoreOrderService;
import com.kriuchkov.autopartsstore.service.store.StoreOrderStatusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/store_orders")
public class StoreOrdersController {
    public final StoreOrderService storeOrderService;
    public final CatalogueService catalogueService;
    public final StoreOrderStatusService storeOrderStatusService;

    @Autowired
    public StoreOrdersController(StoreOrderService storeOrderService, CatalogueService catalogueService, StoreOrderStatusService storeOrderStatusService) {
        this.storeOrderService = storeOrderService;
        this.catalogueService = catalogueService;
        this.storeOrderStatusService = storeOrderStatusService;
    }

    @GetMapping("/store_orders_list")
    public String findAll(Model model) {
        List<StoreOrder> storeOrders = storeOrderService.findAll();
        model.addAttribute("storeOrders", storeOrders);
        return "store_orders/store_orders_list";
    }

    @GetMapping("/create_store_order")
    public String createStoreOrderForm(Model model, StoreOrder storeOrder) {
        List<Catalogue> catalogues = catalogueService.findAll();
        model.addAttribute("catalogues", catalogues);
        return "store_orders/create_store_order";
    }

    @PostMapping("/create_store_order")
    public String createStoreOrder(StoreOrder storeOrder) {
        storeOrder.setDate(Date.valueOf(LocalDate.now()));
        storeOrderService.saveStoreOrder(storeOrder);
        return "redirect:/store_orders/store_orders_list";
    }

    @GetMapping("/update_store_order/{id}")
    public String updateStoreOrderForm(@PathVariable("id") Integer id, Model model) {
        StoreOrder storeOrder = storeOrderService.findById(id);
        model.addAttribute("storeOrder", storeOrder);
        List<Catalogue> catalogues = catalogueService.findAll();
        List<StoreOrderStatus> storeOrderStatuses = storeOrderStatusService.findAll();
        model.addAttribute("catalogues", catalogues);
        model.addAttribute("storeOrderStatuses", storeOrderStatuses);
        return "store_orders/update_store_order";
    }

    @PostMapping("/update_store_order")
    public String updateStoreOrder(StoreOrder storeOrder) {
        StoreOrder upd = (storeOrderService.findById(storeOrder.getId()));
        upd.setStoreOrderStatus(storeOrder.getStoreOrderStatus());
        storeOrderService.saveStoreOrder(upd);
        return "redirect:/store_orders/store_orders_list";
    }

    @GetMapping("delete_store_order/{id}")
    public String deleteStoreOrder(@PathVariable("id") Integer id) {
        storeOrderService.deleteById(id);
        return "redirect:/store_orders/store_orders_list";
    }
}
