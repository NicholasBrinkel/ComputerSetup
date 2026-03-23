#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILE="${SCRIPT_DIR}/parse-test-inputs.json"
PARSER="${SCRIPT_DIR}/../parse.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail_count=0
pass_count=0

while IFS= read -r test_case; do
    input=$(echo "$test_case" | jq -r '.key')
    expected=$(echo "$test_case" | jq -c '.value')

    actual=$("$PARSER" "$input" 2>/dev/null || echo '{"intent":"Invalid"}')
    actual=$(echo "$actual" | jq -c .)

    if [[ "$actual" == "$expected" ]]; then
        echo -e "${GREEN}PASS${NC}: $input"
        ((pass_count++))
    else
        echo -e "${RED}FAIL${NC}: $input"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((fail_count++))
    fi
done < <(jq -c 'to_entries[]' "$TEST_FILE")

echo ""
echo "Results: $pass_count passed, $fail_count failed"

[[ $fail_count -eq 0 ]]
