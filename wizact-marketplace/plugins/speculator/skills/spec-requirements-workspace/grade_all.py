#!/usr/bin/env python3
"""Grade all 8 requirements.md outputs."""

import json
import re
from pathlib import Path

def check_pattern(content, pattern_type):
    """Check if content contains the expected EARS pattern."""
    patterns = {
        "Ubiquitous": r"The system SHALL",
        "Event-Driven": r"WHEN .+ the system SHALL",
        "State-Driven": r"WHILE .+ the system SHALL",
        "Unwanted Behavior": r"IF .+ THEN the system SHALL",
        "Optional": r"WHERE .+ the system SHALL",
        "Mixed": None  # Special handling below
    }

    if pattern_type == "Mixed":
        # For mixed, check that content has multiple patterns
        count = sum(1 for p in ["Ubiquitous", "Event-Driven", "State-Driven", "Unwanted Behavior", "Optional"]
                   if check_pattern(content, p))
        return count >= 3  # At least 3 different patterns

    pattern = patterns.get(pattern_type)
    return bool(re.search(pattern, content, re.IGNORECASE)) if pattern else False

def grade_file(file_path, assertions, expected_pattern):
    """Grade a single requirements.md file."""
    if not file_path.exists():
        return {"error": "File not found", "expectations": [], "pass_rate": 0.0}

    content = file_path.read_text()
    results = []

    for assertion in assertions:
        passed = False
        evidence = ""

        if assertion["type"] == "pattern_check":
            if "all 5 EARS patterns" in assertion["text"]:
                # Check for all 5 patterns
                patterns_found = []
                for p in ["Ubiquitous", "Event-Driven", "State-Driven", "Unwanted Behavior", "Optional"]:
                    if check_pattern(content, p):
                        patterns_found.append(p)
                passed = len(patterns_found) == 5
                evidence = f"Found {len(patterns_found)}/5 patterns: {', '.join(patterns_found)}" if patterns_found else "No EARS patterns found"

            elif "Optional, Ubiquitous, and Unwanted Behavior" in assertion["text"]:
                # Check for specific 3 patterns
                opt = check_pattern(content, "Optional")
                ubiq = check_pattern(content, "Ubiquitous")
                unwanted = check_pattern(content, "Unwanted Behavior")
                passed = opt and ubiq and unwanted
                found = [p for p, check in [("Optional", opt), ("Ubiquitous", ubiq), ("Unwanted Behavior", unwanted)] if check]
                evidence = f"Found: {', '.join(found)}" if found else "Missing expected patterns"

            else:
                # Single pattern check
                passed = check_pattern(content, expected_pattern)
                evidence = f"Found {expected_pattern} pattern" if passed else f"Missing {expected_pattern} pattern"

        elif assertion["type"] == "structure_check":
            if "numbered requirements" in assertion["text"]:
                passed = bool(re.search(r"###\s+R\d+:", content))
                evidence = "Found R1, R2... format" if passed else "Missing numbered requirements"
            elif "Feasibility" in assertion["text"]:
                passed = "Feasibility Verification" in content
                evidence = "Found Feasibility section" if passed else "Missing Feasibility section"

        elif assertion["type"] == "metadata_check":
            if "EARS pattern field" in assertion["text"] or "Includes EARS pattern field" in assertion["text"]:
                passed = "**Pattern**:" in content
                evidence = "Found Pattern field" if passed else "Missing Pattern field"
            elif "dependencies" in assertion["text"].lower():
                passed = "**Dependencies**:" in content
                evidence = "Found Dependencies field" if passed else "Missing Dependencies field"
            elif "Properly maps" in assertion["text"] or "Proper dependency" in assertion["text"]:
                passed = "**Pattern**:" in content and "**Dependencies**:" in content
                evidence = "Found pattern and dependency tracking" if passed else "Missing metadata fields"

        elif assertion["type"] == "completeness_check":
            passed = "**Rationale**:" in content and "**Verification**:" in content
            evidence = "Found both fields" if passed else "Missing Rationale or Verification"

        elif assertion["type"] == "traceability_check":
            if "User stories" in assertion["text"]:
                passed = bool(re.search(r"###\s+US-\d+:", content))
                evidence = "Found User Stories" if passed else "Missing User Stories"
            elif "cross-references" in assertion["text"].lower():
                passed = bool(re.search(r"R\d+→R\d+", content)) or "Dependencies" in content
                evidence = "Found cross-references" if passed else "Missing cross-references"

        elif assertion["type"] == "coverage_check":
            if "both authenticated and expired" in assertion["text"]:
                passed = "authenticated" in content.lower() and "expired" in content.lower()
                evidence = "Covers both states" if passed else "Missing state coverage"
            elif "error scenarios" in assertion["text"]:
                passed = "error" in content.lower() or "fail" in content.lower()
                evidence = "Covers errors" if passed else "Missing error coverage"
            elif "optional feature toggles" in assertion["text"]:
                passed = "enable" in content.lower() or "disable" in content.lower() or "WHERE" in content
                evidence = "Covers toggles" if passed else "Missing toggle coverage"

        elif assertion["type"] == "validation_check":
            passed = "DAG" in content or "no cycles" in content.lower() or "Dependencies form" in content
            evidence = "Verified DAG" if passed else "Missing DAG verification"

        results.append({
            "text": assertion["text"],
            "passed": passed,
            "evidence": evidence
        })

    return {
        "expectations": results,
        "pass_rate": sum(1 for r in results if r["passed"]) / len(results) if results else 0
    }

def main():
    workspace = Path(__file__).parent / "iteration-1"
    metadata_file = workspace / "eval_metadata_complete.json"

    with open(metadata_file) as f:
        metadata = json.load(f)

    results = {}
    all_with = []
    all_without = []

    for test_case in metadata["test_cases"]:
        eval_name = test_case["eval_name"]

        # Grade with_skill output
        with_skill_path = workspace / eval_name / "with_skill" / "outputs" / "requirements.md"
        with_skill_result = grade_file(with_skill_path, test_case["assertions"], test_case["expected_ears_pattern"])

        # Grade without_skill output
        without_skill_path = workspace / eval_name / "without_skill" / "outputs" / "requirements.md"
        without_skill_result = grade_file(without_skill_path, test_case["assertions"], test_case["expected_ears_pattern"])

        results[eval_name] = {
            "with_skill": with_skill_result,
            "without_skill": without_skill_result
        }

        all_with.append(with_skill_result["pass_rate"])
        all_without.append(without_skill_result["pass_rate"])

        # Write individual grading files
        with_skill_dir = workspace / eval_name / "with_skill"
        without_skill_dir = workspace / eval_name / "without_skill"

        (with_skill_dir / "grading.json").write_text(json.dumps(with_skill_result, indent=2))
        (without_skill_dir / "grading.json").write_text(json.dumps(without_skill_result, indent=2))

    # Write summary
    summary_path = workspace / "grading_summary.json"
    summary_path.write_text(json.dumps(results, indent=2))

    # Calculate averages
    avg_with = sum(all_with) / len(all_with) if all_with else 0
    avg_without = sum(all_without) / len(all_without) if all_without else 0

    print("=" * 60)
    print("GRADING COMPLETE - All 8 Test Cases")
    print("=" * 60)

    for eval_name, result in results.items():
        with_rate = result["with_skill"]["pass_rate"] * 100
        without_rate = result["without_skill"]["pass_rate"] * 100
        delta = with_rate - without_rate
        print(f"\n{eval_name}:")
        print(f"  With skill:    {with_rate:5.1f}%")
        print(f"  Without skill: {without_rate:5.1f}%")
        print(f"  Improvement:   +{delta:.1f}%")

    print("\n" + "=" * 60)
    print(f"OVERALL AVERAGES:")
    print(f"  With skill:    {avg_with*100:5.1f}%")
    print(f"  Without skill: {avg_without*100:5.1f}%")
    print(f"  Improvement:   +{(avg_with - avg_without)*100:.1f}%")
    print("=" * 60)
    print(f"\nSummary: {summary_path}")

if __name__ == "__main__":
    main()
