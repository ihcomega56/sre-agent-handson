package com.example.orderapi;

import com.microsoft.applicationinsights.attach.ApplicationInsights;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class OrderApiApplication {

	public static void main(String[] args) {
		// APPLICATIONINSIGHTS_CONNECTION_STRING が設定されていれば App Insights Java エージェントが有効になる
		ApplicationInsights.attach();
		SpringApplication.run(OrderApiApplication.class, args);
	}

}
