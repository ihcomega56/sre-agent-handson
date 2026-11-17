#!/usr/bin/env bash
# メモリを少しずつ増やし続ける（予兆検知シナリオ用）。
# 使い方: ./scripts/leak.sh [API_URI] [1回あたりMB(既定 20)] [間隔秒(既定 60)] [回数(既定 25)]
set -u
API_URI="${1:-$(azd env get-value API_URI)}"
STEP_MB="${2:-20}"
INTERVAL="${3:-60}"
STEPS="${4:-25}"

echo "Leaking ${STEP_MB}MB every ${INTERVAL}s, ${STEPS} times, on ${API_URI}"
for i in $(seq 1 "${STEPS}"); do
  echo "$(date '+%H:%M:%S') [${i}/${STEPS}] $(curl -s -X POST "${API_URI}/api/debug/leak?mb=${STEP_MB}")"
  [ "${i}" -lt "${STEPS}" ] && sleep "${INTERVAL}"
done
