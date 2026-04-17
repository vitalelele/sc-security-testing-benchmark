#!/usr/bin/env python3
import json
import pathlib

ROOT_DIR = pathlib.Path(__file__).resolve().parents[2]
BASE = ROOT_DIR / "results" / "mythril" / "access_control"

print("contract\trun\tstatus\truntime\tissues\tswc_ids")

for contract_dir in sorted(p for p in BASE.iterdir() if p.is_dir()):
    for run_dir in sorted(
        contract_dir.glob("run_*"),
        key=lambda p: int(p.name.split("_")[1])
    ):
        status = (run_dir / "status.txt").read_text().strip()
        runtime = (run_dir / "runtime_sec.txt").read_text().strip()
        report = run_dir / "report.json"

        issues = []
        swcs = set()

        if report.exists() and report.stat().st_size > 0:
            try:
                data = json.loads(report.read_text(errors="replace"))
                issues = data.get("issues") or []
                for it in issues:
                    if it.get("swc-id"):
                        swcs.add(str(it["swc-id"]))
            except Exception:
                pass

        print(
            f"{contract_dir.name}\t"
            f"{run_dir.name}\t"
            f"{status}\t"
            f"{runtime}\t"
            f"{len(issues)}\t"
            f"{sorted(swcs)}"
        )
