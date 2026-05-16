#!/usr/bin/env python3
"""Generate manifest.json for S3 upload.

Lists all rules under rules/, indexes by shift and component, computes checksums.
Output: manifest.json at repo root.
"""

import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).parent.parent
RULES_DIR = REPO_ROOT / "rules"
MANIFEST_PATH = REPO_ROOT / "manifest.json"


def main():
    version = os.environ.get("RAXIT_RULES_VERSION", "0.1.0")
    released_by = os.environ.get("RAXIT_RELEASED_BY", "local")
    reason = os.environ.get("RAXIT_RELEASE_REASON", "manual release")

    rules = []
    by_shift = {"scope": [], "sign": [], "stop": []}
    by_component = {}
    checksums = {}

    for rule_file in sorted(RULES_DIR.rglob("*.yml")):
        rel_path = rule_file.relative_to(REPO_ROOT).as_posix()
        rules.append(rel_path)

        with open(rule_file) as f:
            rule = yaml.safe_load(f)

        shift = rule.get("metadata", {}).get("shift")
        if shift in by_shift:
            by_shift[shift].append(rel_path)

        # Component = parent folder name
        component = rule_file.parent.name
        by_component.setdefault(component, []).append(rel_path)

        # Checksum
        with open(rule_file, "rb") as f:
            checksums[rel_path] = "sha256:" + hashlib.sha256(f.read()).hexdigest()

    manifest = {
        "version": version,
        "released_at": datetime.now(timezone.utc).isoformat(),
        "released_by": released_by,
        "reason": reason,
        "rules": rules,
        "indexes": {
            "by_shift": by_shift,
            "by_component": by_component,
        },
        "checksums": checksums,
        "compatibility": {
            "min_scanner_version": "1.0.0",
            "ast_grep_min_version": "0.42.0",
        },
    }

    with open(MANIFEST_PATH, "w") as f:
        json.dump(manifest, f, indent=2)

    print(f"Wrote {MANIFEST_PATH}")
    print(f"  version: {version}")
    print(f"  rules: {len(rules)}")
    print(f"  by_shift: scope={len(by_shift['scope'])}, sign={len(by_shift['sign'])}, stop={len(by_shift['stop'])}")
    print(f"  by_component: {', '.join(f'{k}={len(v)}' for k, v in by_component.items())}")


if __name__ == "__main__":
    main()
