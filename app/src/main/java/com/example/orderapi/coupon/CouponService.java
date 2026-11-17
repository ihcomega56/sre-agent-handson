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
	 * クーポンコードに対応する割引率を返す。未知のコードは割引なし。
	 */
	public BigDecimal discountRateFor(String couponCode) {
		return DISCOUNT_RATES.getOrDefault(normalize(couponCode), BigDecimal.ZERO);
	}

	/**
	 * 全角スペースなどの前後の空白を除去し、大文字に揃える。
	 */
	private static String normalize(String couponCode) {
		return couponCode.strip().toUpperCase(Locale.ROOT);
	}

}
