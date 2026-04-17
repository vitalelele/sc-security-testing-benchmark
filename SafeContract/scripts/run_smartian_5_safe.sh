#!/usr/bin/env bash
set -euo pipefail

# usage: run_smartian_5_safe.sh <tag> <bin> <abi> [timebox_sec]
TAG="${1:?usage: run_smartian_5_safe.sh <tag> <bin> <abi> [timebox_sec]}"
BIN="${2:?missing bin}"
ABI="${3:?missing abi}"
TIMEBOX="${4:-600}"

SMARTIAN_HOME="$HOME/fuzzers/Smartian"
OUT="$HOME/SafeContract/results/smartian/$TAG"
mkdir -p "$OUT"

cd "$SMARTIAN_HOME"
dotnet build -c Release >/dev/null

for r in 1 2 3 4 5; do
  RUN_DIR="$OUT/run$r"
  mkdir -p "$RUN_DIR"

  echo "[*] $TAG run$r (timebox=${TIMEBOX}s)"

  /usr/bin/time -p dotnet build/Smartian.dll fuzz \
    -p "$BIN" \
    -a "$ABI" \
    -t "$TIMEBOX" \
    -o "$RUN_DIR" \
    > "$RUN_DIR/stdout.log" 2> "$RUN_DIR/stderr.log" || true

  # salva exit code
  echo "exit_code=$?" > "$RUN_DIR/exit_code.txt"

  # FOUND heuristic (control-set)
  FOUND=0
  if grep -qiE "\bfound\b|reentr|overflow|underflow|tx\.origin|access|vulnerab" "$RUN_DIR/stdout.log" \
     || grep -qiE "\bfound\b|reentr|overflow|underflow|tx\.origin|access|vulnerab" "$RUN_DIR/stderr.log"; then
    FOUND=1
  fi

  BUG_ART=0
  if [ -d "$RUN_DIR/bug" ]; then
    BUG_ART=$(find "$RUN_DIR/bug" -type f | wc -l | tr -d ' ')
  fi

  TTD_SEC="ND"
  TTD_LINE="ND"
  if [ "$FOUND" -eq 1 ]; then
    TTD_LINE=$(grep -iE "\bfound\b|reentr|overflow|underflow|tx\.origin|access|vulnerab" "$RUN_DIR/stdout.log" | head -n 1 || true)
    [ -z "$TTD_LINE" ] && TTD_LINE=$(grep -iE "\bfound\b|reentr|overflow|underflow|tx\.origin|access|vulnerab" "$RUN_DIR/stderr.log" | head -n 1 || true)
  fi

  {
    echo "TOOL=smartian"
    echo "CATEGORY=control-set"
    echo "CONTRACT=$TAG"
    echo "RUN=$r"
    echo "FOUND=$FOUND"
    echo "TTD_sec=$TTD_SEC"
    echo "TIMEBOX_sec=$TIMEBOX"
    echo "BugArtifacts=$BUG_ART"
    echo "TTD_LINE=$TTD_LINE"
    if [ "$FOUND" -eq 1 ]; then
      echo "Notes=control-set; potential-false-positive; inspect logs"
    else
      echo "Notes=control-set; no-findings; expected"
    fi
  } > "$RUN_DIR/summary.txt"
done

echo "[+] Done. Results in: $OUT"
