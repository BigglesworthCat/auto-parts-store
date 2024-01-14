package com.kriuchkov.autopartsstore.controller;

import com.kriuchkov.autopartsstore.model.Catalogue;
import com.kriuchkov.autopartsstore.model.customer.CustomerOrder;
import com.kriuchkov.autopartsstore.model.customer.CustomerOrderStatus;
import com.kriuchkov.autopartsstore.service.CatalogueService;
import com.kriuchkov.autopartsstore.service.customer.CustomerOrderService;
import com.kriuchkov.autopartsstore.service.customer.CustomerOrderStatusService;
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
@RequestMapping("/customers_orders")
public class CustomersOrdersController {
    public final CustomerOrderService customerOrderService;
    public final CatalogueService catalogueService;
    public final CustomerOrderStatusService customerOrderStatusService;

    @Autowired
    public CustomersOrdersController(CustomerOrderService customerOrderService, CatalogueService catalogueService, CustomerOrderStatusService customerOrderStatusService) {
        this.customerOrderService = customerOrderService;
        this.catalogueService = catalogueService;
        this.customerOrderStatusService = customerOrderStatusService;
    }

    @GetMapping("/customers_orders_list")
    public String customersOrdersList(Model model) {
        List<CustomerOrder> customerOrders = customerOrderService.findAll();
        model.addAttribute("customerOrders", customerOrders);
        return "customers_orders/customers_orders_list";
    }

    @GetMapping("/create_customer_order")
    public String createCustomerOrderForm(Model model, CustomerOrder customerOrder) {
        List<Catalogue> catalogues = catalogueService.findAll();
        model.addAttribute("catalogues", catalogues);
        return "customers_orders/create_customer_order";
    }

    @PostMapping("/create_customer_order")
    public String createCustomerOrder(CustomerOrder customerOrder) {
        customerOrder.setDate(Date.valueOf(LocalDate.now()));
        customerOrderService.saveCustomerOrder(customerOrder);
        return "redirect:/customers_orders/customers_orders_list";
    }

    @GetMapping("/update_customer_order/{id}")
    public String updateCustomerOrderForm(@PathVariable("id") Integer id, Model model) {
        CustomerOrder customerOrder = customerOrderService.findById(id);
        model.addAttribute("customerOrder", customerOrder);
        List<Catalogue> catalogues = catalogueService.findAll();
        List<CustomerOrderStatus> customerOrderStatuses = customerOrderStatusService.findAll();
        model.addAttribute("catalogues", catalogues);
        model.addAttribute("customerOrderStatuses", customerOrderStatuses);
        return "customers_orders/update_customer_order";
    }

    @PostMapping("/update_customer_order")
    public String updateCustomerOrder(CustomerOrder customerOrder) {
        CustomerOrder upd = (customerOrderService.findById(customerOrder.getId()));
        upd.setDefectedSkuAmount(customerOrder.getDefectedSkuAmount());
        upd.setCustomerOrderStatus(customerOrder.getCustomerOrderStatus());
        customerOrderService.saveCustomerOrder(upd);
        return "redirect:/customers_orders/customers_orders_list";
    }

    @GetMapping("delete_customer_order/{id}")
    public String deleteCustomerOrder(@PathVariable("id") Integer id) {
        customerOrderStatusService.deleteById(id);
        return "redirect:/customers_orders/customers_orders_list";
    }
}
