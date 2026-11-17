package com.example.orderapi;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class OrderApiTests {

	@Autowired
	MockMvc mvc;

	@Test
	void listsProducts() throws Exception {
		mvc.perform(get("/api/products"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.length()").value(4));
	}

	@Test
	void placesOrderWithoutCoupon() throws Exception {
		mvc.perform(post("/api/orders").contentType(MediaType.APPLICATION_JSON)
				.content("{\"productId\":2,\"quantity\":2}"))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.totalPrice").value(5000));
	}

	@Test
	void placesOrderWithCoupon() throws Exception {
		mvc.perform(post("/api/orders").contentType(MediaType.APPLICATION_JSON)
				.content("{\"productId\":2,\"quantity\":2,\"couponCode\":\" welcome10 \"}"))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.totalPrice").value(4500));
	}

	@Test
	void returnsNotFoundForUnknownProduct() throws Exception {
		mvc.perform(post("/api/orders").contentType(MediaType.APPLICATION_JSON)
				.content("{\"productId\":999,\"quantity\":1}"))
				.andExpect(status().isNotFound());
	}

}
