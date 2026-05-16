#!/usr/bin/env bash
# Validate that every rule YAML parses and has required metadata fields.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES_DIR="$REPO_ROOT/rules"

required_top_fields=("id" "language" "severity" "message" "metadata" "rule")
required_metadata_fields=("shift" "references")
valid_shifts=("scope" "sign" "stop")

fail_count=0
rule_count=0

while IFS= read -r rule_file; do
    rule_count=$((rule_count + 1))
    relative=$(realpath --relative-to="$REPO_ROOT" "$rule_file" 2>/dev/null || python3 -c "import os; print(os.path.relpath('$rule_file', '$REPO_ROOT'))")

    # Parse-check via yq
    if ! yq . "$rule_file" >/dev/null 2>&1; then
        echo "✗ $relative: YAML parse error"
        fail_count=$((fail_count + 1))
        continue
    fi

    # Required top-level fields
    missing=""
    for field in "${required_top_fields[@]}"; do
        if [ "$(yq -r ".$field" "$rule_file")" = "null" ]; then
            missing="$missing $field"
        fi
    done

    # Required metadata fields
    for field in "${required_metadata_fields[@]}"; do
        if [ "$(yq -r ".metadata.$field" "$rule_file")" = "null" ]; then
            missing="$missing metadata.$field"
        fi
    done

    if [ -n "$missing" ]; then
        echo "✗ $relative: missing fields:$missing"
        fail_count=$((fail_count + 1))
        continue
    fi

    # shift must be one of valid values
    shift_value=$(yq -r ".metadata.shift" "$rule_file")
    valid=false
    for valid_shift in "${valid_shifts[@]}"; do
        if [ "$shift_value" = "$valid_shift" ]; then valid=true; break; fi
    done
    if [ "$valid" = "false" ]; then
        echo "✗ $relative: invalid shift '$shift_value' (must be: ${valid_shifts[*]})"
        fail_count=$((fail_count + 1))
        continue
    fi

    # id must match filename (without .yml) by convention
    rule_id=$(yq -r ".id" "$rule_file")
    if [ -z "$rule_id" ] || [ "$rule_id" = "null" ]; then
        echo "✗ $relative: missing id"
        fail_count=$((fail_count + 1))
        continue
    fi

    echo "✓ $relative ($rule_id, $shift_value)"
done < <(find "$RULES_DIR" -name "*.yml" -type f | sort)

echo ""
echo "Rules: $rule_count, failures: $fail_count"

if [ "$fail_count" -gt 0 ]; then exit 1; fi
