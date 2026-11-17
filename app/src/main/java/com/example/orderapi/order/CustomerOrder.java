package com.example.orderapi.order;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "orders")
public class CustomerOrder {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private Long productId;

	private int quantity;

	private String couponCode;

	private BigDecimal totalPrice;

	private OffsetDateTime createdAt;

	protected CustomerOrder() {
	}

	public CustomerOrder(Long productId, int quantity, String couponCode, BigDecimal totalPrice) {
		this.productId = productId;
		this.quantity = quantity;
		this.couponCode = couponCode;
		this.totalPrice = totalPrice;
		this.createdAt = OffsetDateTime.now();
	}

	public Long getId() {
		return id;
	}

	public Long getProductId() {
		return productId;
	}

	public int getQuantity() {
		return quantity;
	}

	public String getCouponCode() {
		return couponCode;
	}

	public BigDecimal getTotalPrice() {
		return totalPrice;
	}

	public OffsetDateTime getCreatedAt() {
		return createdAt;
	}

}
