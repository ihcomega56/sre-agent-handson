#!/usr/bin/env bash
# 注文 API に通常トラフィックを流し続ける。
# 使い方: ./scripts/traffic.sh [API_URI] [継続秒数(既定 1800)]
set -u
API_URI="${1:-$(azd env get-value API_URI)}"
DURATION="${2:-1800}"
COUPONS=("WELCOME10" "VIP20" "welcome10")

echo "Sending traffic to ${API_URI} for ${DURATION}s (Ctrl+C to stop)"
end=$((SECONDS + DURATION))
while [ "$SECONDS" -lt "$end" ]; do
  products=$(curl -s -o /dev/null -w '%{http_code}' "${API_URI}/api/products")
  product_id=$((RANDOM % 4 + 1))
  quantity=$((RANDOM % 3 + 1))
  if [ $((RANDOM % 10)) -lt 3 ]; then
    coupon="${COUPONS[$((RANDOM % ${#COUPONS[@]}))]}"
    body="{\"productId\":${product_id},\"quantity\":${quantity},\"couponCode\":\"${coupon}\"}"
  else
    body="{\"productId\":${product_id},\"quantity\":${quantity}}"
  fi
  order=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d "${body}" "${API_URI}/api/orders")
  echo "$(date '+%H:%M:%S') GET /api/products=${products} POST /api/orders=${order} ${body}"
  sleep 1
done
