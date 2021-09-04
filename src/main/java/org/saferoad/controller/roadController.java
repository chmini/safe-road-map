package org.saferoad.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.AllArgsConstructor;

@Controller
@RequestMapping("/road/*")
@AllArgsConstructor
public class roadController {
	
	@GetMapping("/test")
	public void test() {
		
	}
	
	@GetMapping("/login")
	public void login() {
		
	}
}
