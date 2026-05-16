#!/usr/bin/env bash
# Clone each fixture, run all rules, compare findings to expected.
# Exits non-zero if any fixture deviates from expected.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES_DIR="$REPO_ROOT/fixtures/_cloned"
MANIFEST="$REPO_ROOT/fixtures/manifest.yaml"
SGCONFIG="$REPO_ROOT/sgconfig.yml"

mkdir -p "$FIXTURES_DIR"

# Require ast-grep + yq + jq
for tool in ast-grep yq jq git; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "ERROR: $tool not installed"
        exit 1
    }
done

fail_count=0
pass_count=0

# Read fixture names
fixture_names=$(yq -r '.fixtures[].name' "$MANIFEST")

for name in $fixture_names; do
    echo ""
    echo "=== Fixture: $name ==="

    source=$(yq -r ".fixtures[] | select(.name == \"$name\") | .source" "$MANIFEST")
    pin_ref=$(yq -r ".fixtures[] | select(.name == \"$name\") | .pin_ref" "$MANIFEST")
    classification=$(yq -r ".fixtures[] | select(.name == \"$name\") | .classification" "$MANIFEST")

    target_dir="$FIXTURES_DIR/$name"
    if [ ! -d "$target_dir/.git" ]; then
        echo "  Cloning $source ($pin_ref)..."
        git clone --depth 1 --branch "$pin_ref" "$source" "$target_dir" 2>&1 | tail -2
    else
        echo "  Already cloned, fetching latest..."
        (cd "$target_dir" && git fetch origin "$pin_ref" 2>&1 | tail -2 && git reset --hard "origin/$pin_ref" 2>&1 | tail -1)
    fi

    # Run ast-grep
    findings_json="$FIXTURES_DIR/${name}-findings.json"
    ast-grep scan --json --config "$SGCONFIG" "$target_dir" 2>/dev/null > "$findings_json" || true

    # Aggregate findings by rule_id
    actual=$(jq -r 'group_by(.ruleId) | map({(.[0].ruleId): length}) | add // {}' "$findings_json")

    # Compare to expected
    expected=$(yq -o=json ".fixtures[] | select(.name == \"$name\") | .expected_findings // {}" "$MANIFEST")

    echo "  Classification: $classification"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"

    if [ "$(echo "$actual" | jq -S .)" = "$(echo "$expected" | jq -S .)" ]; then
        echo "  ✓ PASS"
        pass_count=$((pass_count + 1))
    else
        echo "  ✗ FAIL — findings differ from expected"
        echo "  Diff:"
        diff <(echo "$expected" | jq -S .) <(echo "$actual" | jq -S .) || true
        fail_count=$((fail_count + 1))
    fi
done

echo ""
echo "===================="
echo "Pass: $pass_count"
echo "Fail: $fail_count"
echo "===================="

if [ "$fail_count" -gt 0 ]; then
    exit 1
fi
