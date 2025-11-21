"""
Test conversion functions from Dexcom app
Run with: starlark test_conversions.star
"""

# ============================================================================
# Functions to test (copied from main app)
# ============================================================================

MMOL_L_CONVERSION_FACTOR = 0.0555

def format_mmol(value):
    """Format mmol/L value with one decimal place"""
    # Multiply by 10, round, then divide by 10 to get 1 decimal place
    value_times_10 = int(value * 10 + 0.5)  # Adding 0.5 for rounding
    integer_part = value_times_10 // 10
    decimal_part = value_times_10 % 10
    return str(integer_part) + "." + str(decimal_part)

def mg_to_mmol(mg_value):
    """Convert mg/dL to mmol/L"""
    return mg_value * MMOL_L_CONVERSION_FACTOR

# ============================================================================
# Test framework
# ============================================================================

def assert_eq(actual, expected, message = ""):
    """Assert that two values are equal"""
    if actual != expected:
        fail("ASSERTION FAILED: %s\nExpected: %s\nActual: %s" % (message, expected, actual))

def assert_near(actual, expected, tolerance = 0.01, message = ""):
    """Assert that a float value is near expected within tolerance"""
    diff = actual - expected
    if diff < 0:
        diff = -diff
    if diff > tolerance:
        fail("ASSERTION FAILED: %s\nExpected: %s (±%s)\nActual: %s\nDifference: %s" %
             (message, expected, tolerance, actual, diff))

# ============================================================================
# Test cases
# ============================================================================

def test_format_mmol_basic():
    """Test basic mmol formatting"""
    # Test whole numbers
    assert_eq(format_mmol(5.0), "5.0", "Format 5.0")
    assert_eq(format_mmol(10.0), "10.0", "Format 10.0")

    # Test with decimals
    assert_eq(format_mmol(5.5), "5.5", "Format 5.5")
    assert_eq(format_mmol(7.3), "7.3", "Format 7.3")
    print("✓ test_format_mmol_basic passed")

def test_format_mmol_rounding():
    """Test mmol formatting with rounding"""
    # Test rounding up
    assert_eq(format_mmol(5.55), "5.6", "Round 5.55 up to 5.6")
    assert_eq(format_mmol(5.56), "5.6", "Round 5.56 up to 5.6")
    assert_eq(format_mmol(5.59), "5.6", "Round 5.59 up to 5.6")

    # Test rounding down
    assert_eq(format_mmol(5.54), "5.5", "Round 5.54 down to 5.5")
    assert_eq(format_mmol(5.51), "5.5", "Round 5.51 down to 5.5")

    # Test edge case at .5
    assert_eq(format_mmol(5.55), "5.6", "Round 5.55 to 5.6")
    assert_eq(format_mmol(5.45), "5.5", "Round 5.45 to 5.5")
    print("✓ test_format_mmol_rounding passed")

def test_format_mmol_edge_cases():
    """Test edge cases for mmol formatting"""
    # Very small values
    assert_eq(format_mmol(0.1), "0.1", "Format 0.1")
    assert_eq(format_mmol(0.05), "0.1", "Round 0.05 to 0.1")

    # Large values
    assert_eq(format_mmol(25.0), "25.0", "Format 25.0")
    assert_eq(format_mmol(99.9), "99.9", "Format 99.9")
    print("✓ test_format_mmol_edge_cases passed")

def test_mg_to_mmol_conversion():
    """Test mg/dL to mmol/L conversion"""
    # Normal range conversions (70-180 mg/dL = 3.9-10.0 mmol/L)
    result = mg_to_mmol(70)
    assert_near(result, 3.885, 0.01, "70 mg/dL to mmol/L")

    result = mg_to_mmol(100)
    assert_near(result, 5.55, 0.01, "100 mg/dL to mmol/L")

    result = mg_to_mmol(120)
    assert_near(result, 6.66, 0.01, "120 mg/dL to mmol/L")

    result = mg_to_mmol(180)
    assert_near(result, 9.99, 0.01, "180 mg/dL to mmol/L")
    print("✓ test_mg_to_mmol_conversion passed")

def test_full_conversion_pipeline():
    """Test the full conversion from mg/dL to formatted mmol/L string"""
    # Test common glucose values
    test_cases = [
        (70, "3.9"),   # Low threshold
        (80, "4.4"),
        (90, "5.0"),
        (100, "5.6"),  # 100 * 0.0555 = 5.55, rounds to 5.6
        (110, "6.1"),
        (120, "6.7"),  # 120 * 0.0555 = 6.66, rounds to 6.7
        (140, "7.8"),
        (160, "8.9"),
        (180, "10.0"), # High threshold
        (200, "11.1"),
        (250, "13.9"),
    ]

    for mg_val, expected_str in test_cases:
        mmol_val = mg_to_mmol(mg_val)
        formatted = format_mmol(mmol_val)
        assert_eq(formatted, expected_str, "%d mg/dL should format to %s mmol/L" % (mg_val, expected_str))

    print("✓ test_full_conversion_pipeline passed")

# ============================================================================
# Main test runner
# ============================================================================

def run_all_tests():
    """Run all conversion tests"""
    print("\n" + "=" * 50)
    print("Running Conversion Function Tests")
    print("=" * 50 + "\n")

    test_format_mmol_basic()
    test_format_mmol_rounding()
    test_format_mmol_edge_cases()
    test_mg_to_mmol_conversion()
    test_full_conversion_pipeline()

    print("\n" + "=" * 50)
    print("✅ All conversion tests passed!")
    print("=" * 50)

# Run tests when executed
run_all_tests()