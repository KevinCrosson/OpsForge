#!/usr/bin/env python3
"""
OpsForge Status JSON Validator
------------------------------
This script validates the Docs/status.json file to ensure:
- Correct JSON structure
- Required keys exist (module, short, mid, long)
- Values are integers between 0 and 100
- No duplicate module names

Usage:
    python Scripts/Metadata/validate_status_json.py

Exit Codes:
    0 → Validation passed
    1 → Validation failed
"""

import json
import os
import sys

# ------------------------------------------------------------
# Step 1: Define validation rules
# ------------------------------------------------------------
REQUIRED_KEYS = {"module", "short", "mid", "long"}  # keys each entry must contain
MIN_VALUE = 0                                       # minimum allowed percentage
MAX_VALUE = 100                                     # maximum allowed percentage

# Path to the status.json file
status_file = os.path.join("Docs", "status.json")

# ------------------------------------------------------------
# Step 2: Load JSON file
# ------------------------------------------------------------
try:
    with open(status_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"❌ ERROR: {status_file} not found.")
    sys.exit(1)
except json.JSONDecodeError as e:
    print(f"❌ ERROR: Invalid JSON format in {status_file}: {e}")
    sys.exit(1)

# ------------------------------------------------------------
# Step 3: Validate structure
# ------------------------------------------------------------
if not isinstance(data, list):
    print("❌ ERROR: status.json must contain a list of module objects.")
    sys.exit(1)

modules_seen = set()  # track module names to detect duplicates
errors = []           # collect validation errors

for idx, item in enumerate(data, start=1):
    # Ensure all required keys exist
    missing_keys = REQUIRED_KEYS - item.keys()
    if missing_keys:
        errors.append(f"Entry {idx} missing keys: {missing_keys}")
        continue

    # Validate module name
    module = item["module"]
    if module in modules_seen:
        errors.append(f"Duplicate module name: {module}")
    else:
        modules_seen.add(module)

    # Validate numeric values for short, mid, long
    for key in ["short", "mid", "long"]:
        value = item[key]
        if not isinstance(value, int):
            errors.append(
                f"Module {module}: {key} must be an integer, got {type(value).__name__}"
            )
        elif not (MIN_VALUE <= value <= MAX_VALUE):
            errors.append(
                f"Module {module}: {key} must be between {MIN_VALUE} and {MAX_VALUE}, got {value}"
            )

# ------------------------------------------------------------
# Step 4: Report results
# ------------------------------------------------------------
if errors:
    print("❌ Validation failed with the following issues:")
    for err in errors:
        print(f"   - {err}")
    sys.exit(1)
else:
    print("✅ status.json validation passed successfully.")
    sys.exit(0)