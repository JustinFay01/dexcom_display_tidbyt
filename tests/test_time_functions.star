"""
Test time functions from Dexcom app
Run with: starlark test_time_functions.star
"""

# ============================================================================
# Functions to test (adapted from main app)
# ============================================================================

def parse_dexcom_timestamp(timestamp_str):
    """Parse Dexcom timestamp and return milliseconds since epoch
    Returns -1 if parsing fails"""
    if not timestamp_str:
        return -1

    # Extract milliseconds from "/Date(1234567890000)/" format
    start = timestamp_str.find("(")
    end = timestamp_str.find(")")

    if start == -1 or end == -1:
        return -1

    ms_str = timestamp_str[start + 1:end]

    # Handle timezone offset
    for sep in ["-", "+"]:
        if sep in ms_str:
            ms_str = ms_str.split(sep)[0]
            break

    # Convert to integer
    return int(ms_str)

def calculate_minutes_diff(ms_timestamp, now_ms):
    """Calculate difference in minutes between two millisecond timestamps"""
    diff_minutes = (now_ms - ms_timestamp) / 60000
    return int(diff_minutes)

# ============================================================================
# Test framework
# ============================================================================

def assert_eq(actual, expected, message = ""):
    """Assert that two values are equal"""
    if actual != expected:
        fail("ASSERTION FAILED: %s\nExpected: %s\nActual: %s" % (message, expected, actual))

def assert_in_range(value, min_val, max_val, message = ""):
    """Assert that a value is within a range"""
    if value < min_val or value > max_val:
        fail("ASSERTION FAILED: %s\nValue %s not in range [%s, %s]" %
             (message, value, min_val, max_val))

# ============================================================================
# Test cases
# ============================================================================

def test_parse_dexcom_timestamp_valid():
    """Test parsing valid Dexcom timestamps"""
    # Standard format
    result = parse_dexcom_timestamp("/Date(1700000000000)/")
    assert_eq(result, 1700000000000, "Parse standard timestamp")

    # With positive timezone offset
    result = parse_dexcom_timestamp("/Date(1700000000000+0500)/")
    assert_eq(result, 1700000000000, "Parse with positive timezone")

    # With negative timezone offset
    result = parse_dexcom_timestamp("/Date(1700000000000-0800)/")
    assert_eq(result, 1700000000000, "Parse with negative timezone")

    # Different timestamp values
    result = parse_dexcom_timestamp("/Date(1234567890123)/")
    assert_eq(result, 1234567890123, "Parse different timestamp")

    print("✓ test_parse_dexcom_timestamp_valid passed")

def test_parse_dexcom_timestamp_invalid():
    """Test parsing invalid Dexcom timestamps"""
    # Empty string
    result = parse_dexcom_timestamp("")
    assert_eq(result, -1, "Empty string returns -1")

    # Missing parentheses
    result = parse_dexcom_timestamp("/Date1700000000000/")
    assert_eq(result, -1, "Missing parentheses returns -1")

    # Missing closing parenthesis
    result = parse_dexcom_timestamp("/Date(1700000000000/")
    assert_eq(result, -1, "Missing closing parenthesis returns -1")

    # Malformed format
    result = parse_dexcom_timestamp("Not a timestamp")
    assert_eq(result, -1, "Malformed format returns -1")

    print("✓ test_parse_dexcom_timestamp_invalid passed")

def test_calculate_minutes_diff():
    """Test minute difference calculation"""
    # Test various time differences
    now_ms = 1700000000000

    # 5 minutes ago
    five_min_ago = now_ms - (5 * 60 * 1000)
    result = calculate_minutes_diff(five_min_ago, now_ms)
    assert_eq(result, 5, "5 minutes difference")

    # 1 hour ago
    one_hour_ago = now_ms - (60 * 60 * 1000)
    result = calculate_minutes_diff(one_hour_ago, now_ms)
    assert_eq(result, 60, "60 minutes (1 hour) difference")

    # 2.5 hours ago (should round down to 150 minutes)
    two_half_hours_ago = now_ms - (150 * 60 * 1000)
    result = calculate_minutes_diff(two_half_hours_ago, now_ms)
    assert_eq(result, 150, "150 minutes (2.5 hours) difference")

    # 30 seconds ago (should round down to 0 minutes)
    thirty_sec_ago = now_ms - (30 * 1000)
    result = calculate_minutes_diff(thirty_sec_ago, now_ms)
    assert_eq(result, 0, "30 seconds rounds to 0 minutes")

    # 90 seconds ago (should round down to 1 minute)
    ninety_sec_ago = now_ms - (90 * 1000)
    result = calculate_minutes_diff(ninety_sec_ago, now_ms)
    assert_eq(result, 1, "90 seconds rounds to 1 minute")

    print("✓ test_calculate_minutes_diff passed")

def test_edge_cases():
    """Test edge cases for time functions"""
    # Zero timestamp
    result = parse_dexcom_timestamp("/Date(0)/")
    assert_eq(result, 0, "Parse zero timestamp")

    # Very large timestamp
    result = parse_dexcom_timestamp("/Date(9999999999999)/")
    assert_eq(result, 9999999999999, "Parse very large timestamp")

    # Timestamp with extra characters in timezone
    result = parse_dexcom_timestamp("/Date(1700000000000-0800PST)/")
    assert_eq(result, 1700000000000, "Parse with extra timezone characters")

    # Negative time difference (future timestamp)
    now_ms = 1700000000000
    future = now_ms + (10 * 60 * 1000)  # 10 minutes in future
    result = calculate_minutes_diff(future, now_ms)
    assert_eq(result, -10, "Future timestamp gives negative minutes")

    print("✓ test_edge_cases passed")

# ============================================================================
# Main test runner
# ============================================================================

def run_all_tests():
    """Run all time function tests"""
    print("\n" + "=" * 50)
    print("Running Time Function Tests")
    print("=" * 50 + "\n")

    test_parse_dexcom_timestamp_valid()
    test_parse_dexcom_timestamp_invalid()
    test_calculate_minutes_diff()
    test_edge_cases()

    print("\n" + "=" * 50)
    print("✅ All time function tests passed!")
    print("=" * 50)

# Run tests when executed
run_all_tests()