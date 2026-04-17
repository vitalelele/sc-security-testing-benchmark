#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   run_ityfuzz_5.sh <CATEGORY> <CONTRACT> <BUILD_DIR> <TIMEBOX_SEC>
# Example:
#   run_ityfuzz_5.sh reentrancy reentrancy_simple ~/MyVulnContracts/build_ityfuzz/reentrancy_simple 600

CATEGORY="${1:-}"
CONTRACT="${2:-}"
BUILD_DIR="${3:-}"
TIMEBOX="${4:-}"

if [[ -z "${CATEGORY}" || -z "${CONTRACT}" || -z "${BUILD_DIR}" || -z "${TIMEBOX}" ]]; then
  echo "Usage: $0 <CATEGORY> <CONTRACT> <BUILD_DIR> <TIMEBOX_SEC>" >&2
  exit 1
fi

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "[-] BUILD_DIR not found: $BUILD_DIR" >&2
  exit 1
fi

ROOT_DIR="${ROOT_DIR:-$HOME/MyVulnContracts}"
RESULTS_BASE="${ROOT_DIR}/results/ityfuzz"
RAW_TSV="${ROOT_DIR}/results/ityfuzz_raw.tsv"

RESULTS_DIR="${RESULTS_BASE}/${CONTRACT}"
TARGET="./build/*"

mkdir -p "${RESULTS_DIR}"

hms_to_sec() {
  local hms="$1"
  local h m s
  h="$(echo "$hms" | sed -n 's/^\([0-9]\+\)h-.*/\1/p')"
  m="$(echo "$hms" | sed -n 's/^[0-9]\+h-\([0-9]\+\)m-.*/\1/p')"
  s="$(echo "$hms" | sed -n 's/.*-\([0-9]\+\)s$/\1/p')"
  h="${h:-0}"; m="${m:-0}"; s="${s:-0}"
  echo $((10#$h*3600 + 10#$m*60 + 10#$s))
}

append_tsv() {
  local tool="$1" category="$2" contract="$3" run="$4" found="$5" ttd="$6" timebox="$7" bugart="$8" notes="$9"
  if [[ ! -f "$RAW_TSV" ]]; then
    printf "Tool\tCategory\tContract\tRun\tFOUND\tTTD_sec\tTimebox_sec\tBugArtifacts\tNotes\n" > "$RAW_TSV"
  fi
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "$tool" "$category" "$contract" "$run" "$found" "$ttd" "$timebox" "$bugart" "$notes" >> "$RAW_TSV"
}

for RUN in 1 2 3 4 5; do
  OUTDIR="${RESULTS_DIR}/run${RUN}"
  mkdir -p "${OUTDIR}/build"
  rm -rf "${OUTDIR}/build"/*
  cp -a "${BUILD_DIR}/"* "${OUTDIR}/build/"

  echo "[+] ItyFuzz ${CONTRACT} run${RUN} (timebox=${TIMEBOX}s)"

  (
    cd "$OUTDIR"
    # -d all: enable all detectors (matches your sanity test)
    timeout "$TIMEBOX" ityfuzz evm -d all -t "$TARGET" 2>stderr.log | tee stdout.log
  ) || true

  STDOUT="${OUTDIR}/stdout.log"

  # Detection oracle: ItyFuzz prints this when it reports bugs
  BUG_LINE_NO="$(grep -n -m1 -E "Found vulnerabilities!|================ Description ================" "$STDOUT" | cut -d: -f1 || true)"

  FOUND=0
  TTD_SEC="ND"

  if [[ -n "$BUG_LINE_NO" ]]; then
    FOUND=1
    HMS="$(sed -n "1,${BUG_LINE_NO}p" "$STDOUT" \
          | grep -E "run time: [0-9]+h-[0-9]+m-[0-9]+s" \
          | tail -n1 \
          | sed -n 's/.*run time: \([^,]*\),.*/\1/p')"
    if [[ -n "$HMS" ]]; then
      TTD_SEC="$(hms_to_sec "$HMS")"
    fi
  fi

  # BugArtifacts: count files in solutions/ (if any)
  BUG_ART=0
  if [[ -d "$OUTDIR/solutions" ]]; then
    BUG_ART="$(find "$OUTDIR/solutions" -type f | wc -l | tr -d ' ')"
  fi

  NOTES="snapshot-based; detectors=all; found-oracle=found_vuln_banner"
  if [[ "$FOUND" -eq 0 ]]; then
    NOTES="${NOTES}; timebox_or_no_bug"
  fi

  # Write per-run summary
  cat > "${OUTDIR}/summary.txt" <<EOF
TOOL=ityfuzz
CATEGORY=${CATEGORY}
CONTRACT=${CONTRACT}
RUN=${RUN}
FOUND=${FOUND}
TTD_sec=${TTD_SEC}
TIMEBOX_sec=${TIMEBOX}
BugArtifacts=${BUG_ART}
Notes=${NOTES}
EOF

  # Append to raw TSV
  append_tsv "ityfuzz" "$CATEGORY" "$CONTRACT" "$RUN" "$FOUND" "$TTD_SEC" "$TIMEBOX" "$BUG_ART" "$NOTES"
done

echo "[+] Done. Raw TSV: ${RAW_TSV}"
echo "[+] Results dir: ${RESULTS_DIR}"
