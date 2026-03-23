#!/usr/bin/env python3
"""Grade requirements.md outputs against assertions."""

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
        "Optional": r"WHERE .+ the system SHALL"
    }
    return bool(re.search(patterns.get(pattern_type, ""), content, re.IGNORECASE))

def check_structure(content, check_type):
    """Check structural elements."""
    checks = {
        "numbered_requirements": r"###\s+R\d+:",
        "user_stories": r"###\s+US-\d+:",
        "feasibility": r"##\s+Feasibility Verification"
    }
    pattern = checks.get(check_type)
    return bool(re.search(pattern, content)) if pattern else False

def grade_file(file_path, assertions, expected_pattern):
    """Grade a single requirements.md file."""
    if not file_path.exists():
        return {"error": "File not found"}

    content = file_path.read_text()
    results = []

    for assertion in assertions:
        passed = False
        evidence = ""

        if assertion["type"] == "pattern_check":
            passed = check_pattern(content, expected_pattern)
            evidence = f"Found {expected_pattern} pattern" if passed else f"Missing {expected_pattern} pattern"

        elif assertion["type"] == "structure_check":
            if "numbered requirements" in assertion["text"]:
                passed = check_structure(content, "numbered_requirements")
                evidence = "Found R1, R2... format" if passed else "Missing numbered requirements"
            elif "Feasibility" in assertion["text"]:
                passed = check_structure(content, "feasibility")
                evidence = "Found Feasibility section" if passed else "Missing Feasibility section"

        elif assertion["type"] in ["metadata_check", "completeness_check", "traceability_check", "coverage_check", "validation_check"]:
            # Simplified checks
            if "EARS pattern field" in assertion["text"]:
                passed = "**Pattern**:" in content
                evidence = "Found Pattern field" if passed else "Missing Pattern field"
            elif "Rationale and Verification" in assertion["text"]:
                passed = "**Rationale**:" in content and "**Verification**:" in content
                evidence = "Found both fields" if passed else "Missing Rationale or Verification"
            elif "dependencies" in assertion["text"].lower():
                passed = "**Dependencies**:" in content
                evidence = "Found Dependencies field" if passed else "Missing Dependencies field"
            elif "User stories link" in assertion["text"]:
                passed = check_structure(content, "user_stories")
                evidence = "Found User Stories" if passed else "Missing User Stories"
            elif "both authenticated and expired" in assertion["text"]:
                passed = "authenticated" in content.lower() and "expired" in content.lower()
                evidence = "Covers both states" if passed else "Missing state coverage"
            elif "DAG" in assertion["text"]:
                passed = "Dependencies form DAG" in content or "no cycles" in content.lower()
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
    metadata_file = workspace / "eval_metadata_summary.json"

    with open(metadata_file) as f:
        metadata = json.load(f)

    results = {}

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

        # Write individual grading files
        with_skill_dir = workspace / eval_name / "with_skill"
        without_skill_dir = workspace / eval_name / "without_skill"

        (with_skill_dir / "grading.json").write_text(json.dumps(with_skill_result, indent=2))
        (without_skill_dir / "grading.json").write_text(json.dumps(without_skill_result, indent=2))

    # Write summary
    summary_path = workspace / "grading_summary.json"
    summary_path.write_text(json.dumps(results, indent=2))

    print("Grading complete!")
    print(f"Summary: {summary_path}")

    # Print quick results
    for eval_name, result in results.items():
        with_rate = result["with_skill"]["pass_rate"] * 100
        without_rate = result["without_skill"]["pass_rate"] * 100
        print(f"{eval_name}:")
        print(f"  With skill: {with_rate:.0f}%")
        print(f"  Without skill: {without_rate:.0f}%")

if __name__ == "__main__":
    main()
