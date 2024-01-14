package com.kriuchkov.autopartsstore.controller;

import com.kriuchkov.autopartsstore.model.Good;
import com.kriuchkov.autopartsstore.service.GoodService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/goods")
public class GoodController {
    public final GoodService goodService;

    @Autowired
    public GoodController(GoodService goodService) {
        this.goodService = goodService;
    }

    @GetMapping("/goods_list")
    public String goodsList(Model model) {
        List<Good> goods = goodService.findAll();
        model.addAttribute("goods", goods);
        return "goods/goods_list";
    }

    @GetMapping("/create_good")
    public String createGoodForm(Good good) {
        return "goods/create_good";
    }

    @PostMapping("/create_good")
    public String createGood(Good good) {
        goodService.saveGood(good);
        return "redirect:/goods/goods_list";
    }

    @GetMapping("/update_good/{id}")
    public String updateGoodForm(@PathVariable("id") Integer id, Model model) {
        Good good = goodService.findById(id);
        model.addAttribute("good", good);
        return "goods/update_good";
    }

    @PostMapping("/update_good")
    public String updateGood(Good good) {
        goodService.saveGood(good);
        return "redirect:/goods/goods_list";
    }

    @GetMapping("delete_good/{id}")
    public String deleteContract(@PathVariable("id") Integer id) {
        goodService.deleteById(id);
        return "redirect:/goods/goods_list";
    }
}

