package com.example.orderapi.debug;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

/**
 * ハンズオン（予兆検知シナリオ）用に、意図的にヒープを解放せず保持し続けるエンドポイント。
 * app.leak.enabled=true（環境変数 APP_LEAK_ENABLED=true）のときだけ有効になる。
 */
@RestController
@RequestMapping("/api/debug/leak")
@ConditionalOnProperty(name = "app.leak.enabled", havingValue = "true")
public class LeakController {

	private static final int ONE_MB = 1024 * 1024;

	private final List<byte[]> retained = new ArrayList<>();

	private final int maxMb;

	public LeakController(@Value("${app.leak.max-mb:600}") int maxMb) {
		this.maxMb = maxMb;
	}

	@PostMapping
	public synchronized Map<String, Integer> leak(@RequestParam(defaultValue = "20") int mb) {
		if (mb < 1 || retained.size() + mb > maxMb) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
					"mb must be >= 1 and total retained must be <= " + maxMb + " MB");
		}
		for (int i = 0; i < mb; i++) {
			byte[] chunk = new byte[ONE_MB];
			Arrays.fill(chunk, (byte) 1);
			retained.add(chunk);
		}
		return status();
	}

	@GetMapping
	public synchronized Map<String, Integer> status() {
		Runtime rt = Runtime.getRuntime();
		int usedHeapMb = (int) ((rt.totalMemory() - rt.freeMemory()) / ONE_MB);
		return Map.of("retainedMb", retained.size(), "usedHeapMb", usedHeapMb, "maxRetainedMb", maxMb);
	}

	@DeleteMapping
	public synchronized Map<String, Integer> release() {
		retained.clear();
		System.gc();
		return status();
	}

}
