#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/MyVulnContracts"
TOOL="Mythril"
IMAGE="mythril/myth:latest"

# target (solo questo contratto)
CATEGORY="reentrancy"
CONTRACT_REL="reentrancy/reentrancy_simple.sol"
CONTRACT_NAME="reentrancy_simple"

TIMEBOX=600
RUNS=5

OUTBASE="$ROOT/results/mythril/$CATEGORY/$CONTRACT_NAME"
mkdir -p "$OUTBASE"

echo "==> Tool: $TOOL (Docker image: $IMAGE)"
echo "==> Contract: $CONTRACT_REL"
echo "==> Runs: $RUNS | Timebox: ${TIMEBOX}s"
echo "==> Output: $OUTBASE"
echo

for i in $(seq 1 "$RUNS"); do
  OUTDIR="$OUTBASE/run_$i"
  mkdir -p "$OUTDIR"

  # metadati (audit-friendly)
  {
    echo "tool=$TOOL"
    echo "docker_image=$IMAGE"
    echo "category=$CATEGORY"
    echo "contract_rel=$CONTRACT_REL"
    echo "contract_name=$CONTRACT_NAME"
    echo "run=$i"
    echo "timebox_sec=$TIMEBOX"
    echo -n "date="; date -Iseconds
  } > "$OUTDIR/meta.txt"

  echo "==> Run $i/$RUNS"

  TIME_TMP="$OUTDIR/time_stderr.tmp"

  set +e
  # NB: time scrive su stderr -> catturato in TIME_TMP
  { /usr/bin/time -f "%e" \
      timeout --signal=KILL "${TIMEBOX}s" \
        docker run --rm \
          -v "$ROOT":/workspace \
          "$IMAGE" \
          myth analyze "/workspace/$CONTRACT_REL" -o json \
          1> "$OUTDIR/stdout.log" \
          2> "$OUTDIR/stderr.log" ; } 2> "$TIME_TMP"
  EC=$?
  set -e

  echo "$EC" > "$OUTDIR/exit_code.txt"

  # status: timeout vs done
  if [ "$EC" -eq 124 ] || [ "$EC" -eq 137 ]; then
    echo "timeout" > "$OUTDIR/status.txt"
  else
    echo "done" > "$OUTDIR/status.txt"
  fi

  # runtime (TTD): ultima riga prodotta da time è il float
  tail -n 1 "$TIME_TMP" > "$OUTDIR/runtime_sec.txt"
  rm -f "$TIME_TMP"

  # report JSON (Mythril -o json stampa su stdout)
  cp "$OUTDIR/stdout.log" "$OUTDIR/report.json"

  # sanity marker: JSON valido?
  if python3 -m json.tool "$OUTDIR/report.json" >/dev/null 2>&1; then
    echo "json_ok" > "$OUTDIR/json_status.txt"
  else
    echo "json_broken" > "$OUTDIR/json_status.txt"
  fi

  echo "   exit_code=$EC status=$(cat "$OUTDIR/status.txt") ttd=$(cat "$OUTDIR/runtime_sec.txt") json=$(cat "$OUTDIR/json_status.txt")"
done

echo
echo "All runs completed."
echo "Output base: $OUTBASE"
BASH
