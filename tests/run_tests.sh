#!/bin/bash

# Run tests with starlark-go
# Usage: ./run_tests.sh

echo "===================================="
echo "Running Dexcom App Tests"
echo "===================================="

# Check if starlark is installed
if ! command -v starlark &> /dev/null; then
    echo "❌ starlark command not found!"
    echo "Please install starlark-go:"
    echo "  go install go.starlark.net/cmd/starlark@latest"
    exit 1
fi

echo ""
echo "Using starlark from: $(which starlark)"
echo ""

# Track test results
FAILED=0
PASSED=0
TOTAL=0

# Find and run all .star test files
for test_file in *.star; do
    # Check if any .star files exist
    if [ ! -e "$test_file" ]; then
        echo "No .star test files found in current directory"
        exit 1
    fi

    TOTAL=$((TOTAL + 1))
    echo "Running $test_file..."

    if starlark "$test_file"; then
        echo "✅ $test_file passed"
        PASSED=$((PASSED + 1))
    else
        echo "❌ $test_file failed"
        FAILED=$((FAILED + 1))
    fi

    echo ""
done

echo ""
echo "===================================="
echo "Test Results: $PASSED/$TOTAL passed"
echo "===================================="

if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ $FAILED test(s) failed"
    exit 1
fi