#!/usr/bin/env bash
set -euo pipefail

TAG="${1:?usage: run_smartian_5.sh <tag> <bin> <abi>}"
BIN="${2:?missing .bin}"
ABI="${3:?missing .abi}"

SMARTIAN_DLL="$HOME/fuzzers/Smartian/build/Smartian.dll"
OUTBASE="$HOME/MyVulnContracts/results/smartian/$TAG"

mkdir -p "$OUTBASE"

for i in 1 2 3 4 5; do
  OUT="$OUTBASE/run$i"
  mkdir -p "$OUT"

  echo "=== Smartian $TAG | run $i ==="
  echo "OUT: $OUT"

  # Start Smartian in a new process group; redirect all output to stdout.log
  setsid dotnet "$SMARTIAN_DLL" fuzz \
    -p "$BIN" \
    -a "$ABI" \
    -t 600 \
    -o "$OUT" \
    > "$OUT/stdout.log" 2>&1 &

  PID=$!
  FOUND=0

  # Poll log until detection or timeout
  for t in $(seq 1 600); do
    if grep -q "found Reentrancy" "$OUT/stdout.log"; then
      FOUND=1
      echo "[+] Reentrancy found — stopping run $i"
      break
    fi
    # If process ended naturally, stop polling
    if ! kill -0 "$PID" 2>/dev/null; then
      break
    fi
    sleep 1
  done

  if [ "$FOUND" -eq 1 ]; then
    # Kill whole process group (created by setsid)
    kill -TERM -"$PID" 2>/dev/null || true
    sleep 1
    kill -KILL -"$PID" 2>/dev/null || true
  fi

  # Reap
  wait "$PID" 2>/dev/null || true

  # Summary for your spreadsheet
  if [ "$FOUND" -eq 1 ]; then
    TLINE="$(grep -m 1 "found Reentrancy" "$OUT/stdout.log" || true)"
    printf "FOUND=1\nTTD_LINE=%s\n" "$TLINE" > "$OUT/summary.txt"
  else
    printf "FOUND=0\n" > "$OUT/summary.txt"
  fi

  echo "=== End run $i ==="
done

echo "=== DONE: $TAG ==="
