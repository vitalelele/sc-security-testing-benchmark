#!/usr/bin/env bash
set -e

if [ $# -ne 4 ]; then
  echo "Usage: $0 <category> <contract.sol> <solc_version> <contract_name>"
  exit 1
fi

CATEGORY=$1
SOL_FILE=$2
SOLC_VER=$3
CONTRACT_NAME=$4

SRC_DIR="$HOME/MyVulnContracts/$CATEGORY"
OUT_DIR="$HOME/MyVulnContracts/build_ityfuzz/${SOL_FILE%.sol}"

mkdir -p "$OUT_DIR"

echo "[+] Compiling $SOL_FILE with solc $SOLC_VER"

docker run --rm \
  -u "$(id -u)":"$(id -g)" \
  -v "$SRC_DIR":/src \
  ethereum/solc:$SOLC_VER \
  --abi --bin "/src/$SOL_FILE" \
  -o /src/tmp --overwrite


mv "$SRC_DIR/tmp/$CONTRACT_NAME.abi" "$OUT_DIR/"
mv "$SRC_DIR/tmp/$CONTRACT_NAME.bin" "$OUT_DIR/"
rmdir "$SRC_DIR/tmp"

echo "[✓] Output in $OUT_DIR"
