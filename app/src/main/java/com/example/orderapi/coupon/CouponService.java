package com.example.orderapi.coupon;

import java.math.BigDecimal;
import java.util.Locale;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class CouponService {

	private static final Map<String, BigDecimal> DISCOUNT_RATES = Map.of(
			"WELCOME10", new BigDecimal("0.10"),
			"VIP20", new BigDecimal("0.20"));

	/**
	 * クーポンコードに対応する割引率を返す。未指定・未知のコードは割引なし。
	 */
	public BigDecimal discountRateFor(String couponCode) {
		if (couponCode == null || couponCode.isBlank()) {
			return BigDecimal.ZERO;
		}
		String normalized = couponCode.trim().toUpperCase(Locale.ROOT);
		return DISCOUNT_RATES.getOrDefault(normalized, BigDecimal.ZERO);
	}

}
