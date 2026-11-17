package com.example.orderapi.order;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record OrderRequest(
		@NotNull Long productId,
		@Min(1) @Max(100) int quantity,
		String couponCode) {
}
