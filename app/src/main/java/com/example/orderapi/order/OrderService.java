package com.example.orderapi.order;

import com.example.orderapi.common.NotFoundException;
import com.example.orderapi.coupon.CouponService;
import com.example.orderapi.product.Product;
import com.example.orderapi.product.ProductRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

	private final ProductRepository products;
	private final OrderRepository orders;
	private final CouponService coupons;

	public OrderService(ProductRepository products, OrderRepository orders, CouponService coupons) {
		this.products = products;
		this.orders = orders;
		this.coupons = coupons;
	}

	@Transactional
	public CustomerOrder placeOrder(OrderRequest request) {
		Product product = products.findById(request.productId())
				.orElseThrow(() -> new NotFoundException("product " + request.productId() + " not found"));
		BigDecimal subtotal = product.getPrice().multiply(BigDecimal.valueOf(request.quantity()));
		BigDecimal discount = subtotal.multiply(coupons.discountRateFor(request.couponCode()));
		BigDecimal total = subtotal.subtract(discount).setScale(0, RoundingMode.HALF_UP);
		return orders.save(new CustomerOrder(product.getId(), request.quantity(), request.couponCode(), total));
	}

	@Transactional(readOnly = true)
	public CustomerOrder find(Long id) {
		return orders.findById(id).orElseThrow(() -> new NotFoundException("order " + id + " not found"));
	}

}
