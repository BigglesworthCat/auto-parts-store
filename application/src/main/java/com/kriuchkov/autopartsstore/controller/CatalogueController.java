package com.kriuchkov.autopartsstore.controller;


import com.kriuchkov.autopartsstore.model.Catalogue;
import com.kriuchkov.autopartsstore.model.Good;
import com.kriuchkov.autopartsstore.model.supplier.Supplier;
import com.kriuchkov.autopartsstore.service.CatalogueService;
import com.kriuchkov.autopartsstore.service.GoodService;
import com.kriuchkov.autopartsstore.service.supplier.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/catalogue")
public class CatalogueController {
    public final CatalogueService catalogueService;
    public final GoodService goodService;
    public final SupplierService supplierService;

    @Autowired
    public CatalogueController(CatalogueService catalogueService, GoodService goodService, SupplierService supplierService) {
        this.catalogueService = catalogueService;
        this.goodService = goodService;
        this.supplierService = supplierService;
    }

    @GetMapping("/catalogue_menu")
    public String catalogueMenu(Model model) {
        return "catalogue/catalogue_menu";
    }

    @GetMapping("/catalogue_list")
    public String catalogueList(Model model) {
        List<Catalogue> catalogues = catalogueService.findAll();
        model.addAttribute("catalogues", catalogues);
        return "catalogue/catalogue_list";
    }

    @GetMapping("/create_sku")
    public String createSKUForm(Model model, Catalogue catalogue) {
        List<Good> goods = goodService.findAll();
        List<Supplier> suppliers = supplierService.findAll();
        model.addAttribute("goods", goods);
        model.addAttribute("suppliers", suppliers);
        return "catalogue/create_sku";
    }

    @PostMapping("/create_sku")
    public String createSKU(Catalogue catalogue) {
        catalogueService.saveCatalogue(catalogue);
        return "redirect:/catalogue/catalogue_list";
    }

    @GetMapping("/update_sku/{id}")
    public String updateSKUForm(@PathVariable("id") Integer id, Model model) {
        Catalogue catalogue = catalogueService.findById(id);
        model.addAttribute("catalogue", catalogue);
        List<Good> goods = goodService.findAll();
        List<Supplier> suppliers = supplierService.findAll();
        model.addAttribute("goods", goods);
        model.addAttribute("suppliers", suppliers);
        return "catalogue/update_sku";
    }

    @PostMapping("/update_sku")
    public String updateSKU(Catalogue catalogue) {
        catalogueService.saveCatalogue(catalogue);
        return "redirect:/catalogue/catalogue_list";
    }

    @GetMapping("delete_sku/{id}")
    public String deleteSKU(@PathVariable("id") Integer id) {
        catalogueService.deleteById(id);
        return "redirect:/catalogue/catalogue_list";
    }
}