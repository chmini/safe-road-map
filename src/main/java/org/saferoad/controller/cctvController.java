package org.saferoad.controller;

import org.saferoad.service.cctvService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.AllArgsConstructor;

@Controller
@RequestMapping("/map/*")
@AllArgsConstructor
public class cctvController {

	private cctvService service;
	
	@GetMapping("/cctv")
	public void list(Model model) {
		
		model.addAttribute("map", service.getLoc());
	}
	
	@GetMapping("/findroad")
	public void findroad() {
		
	}
	
	@GetMapping("/findcctvroad")
	public void findcctvroad(Model model) {
		
		model.addAttribute("map", service.getLoc());
	}
	
	@GetMapping("/cctvincircle")
	public void cctvincircle(Model model) {
		
		model.addAttribute("map", service.getLoc());
	}
	
	@GetMapping("/findcloseroad")
	public void findcloseroad() {
		
	}
	
	@GetMapping("/filterbyone")
	public void filterbyone(Model model) {
		model.addAttribute("map", service.getLoc());
	}
	
	@GetMapping("/filtercctv")
	public void filtercctv(Model model) {
		model.addAttribute("map", service.getLoc());
	}
	
	@GetMapping("/filtercctv2")
	public void filtercctv2(Model model) {
		model.addAttribute("map2", service.getLoc2());
	}
	
	@GetMapping("/clickforlonlat")
	public void clickforlonlat() {
		
	}
	
	@GetMapping("/findsaferoad")
	public void findsaferoad(Model model) {
		model.addAttribute("map", service.getLoc());
	}
	
	@GetMapping("/dong")
	public void dong(Model model) {
		model.addAttribute("map", service.getLoc());
	}
}
