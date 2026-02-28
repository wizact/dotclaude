#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
RULES_DIR="$SKILL_DIR/rules"
REFERENCE_FILE="$SKILL_DIR/REFERENCE.md"

echo "Compiling REFERENCE.md from rule files..."

# Start with header
cat > "$REFERENCE_FILE" << 'EOF'
# Python Developer - Complete Reference

Complete guide to production-ready Python development. All rules expanded with full context.

**Generated from individual rule files** - Edit rules/*.md, then run compile-reference.sh

## Table of Contents
1. [Type Safety (CRITICAL)](#type-safety-critical)
2. [Async Patterns (CRITICAL)](#async-patterns-critical)
3. [Error Handling (HIGH)](#error-handling-high)
4. [Testing (HIGH)](#testing-high)
5. [Code Style (MEDIUM)](#code-style-medium)
6. [Patterns (MEDIUM)](#patterns-medium)
7. [Performance (LOW)](#performance-low)
8. [Documentation (LOW)](#documentation-low)
9. [Setup & Tooling (LOW)](#setup--tooling-low)

---

EOF

# Function to extract rules by category
compile_category() {
    local category=$1
    local title=$2
    local priority=$3

    echo "" >> "$REFERENCE_FILE"
    echo "## $title ($priority)" >> "$REFERENCE_FILE"
    echo "" >> "$REFERENCE_FILE"

    # Find all rules in this category (sorted alphabetically)
    for rule_file in "$RULES_DIR/$category"-*.md; do
        if [[ -f "$rule_file" ]]; then
            # Extract rule name from filename
            rule_name=$(basename "$rule_file" .md)

            # Extract title from frontmatter
            rule_title=$(grep "^title:" "$rule_file" | sed 's/title: //')

            echo "### $rule_name: $rule_title" >> "$REFERENCE_FILE"
            echo "" >> "$REFERENCE_FILE"

            # Extract content (skip frontmatter)
            awk '/^---$/{if(++count==2) next} count>=2' "$rule_file" >> "$REFERENCE_FILE"

            echo "" >> "$REFERENCE_FILE"
            echo "---" >> "$REFERENCE_FILE"
            echo "" >> "$REFERENCE_FILE"
        fi
    done
}

# Compile each category
compile_category "type" "Type Safety" "CRITICAL"
compile_category "async" "Async Patterns" "CRITICAL"
compile_category "error" "Error Handling" "HIGH"
compile_category "test" "Testing" "HIGH"
compile_category "style" "Code Style" "MEDIUM"
compile_category "pattern" "Patterns" "MEDIUM"
compile_category "perf" "Performance" "LOW"
compile_category "doc" "Documentation" "LOW"
compile_category "setup" "Setup & Tooling" "LOW"

echo "✓ REFERENCE.md compiled successfully"
echo "  Location: $REFERENCE_FILE"
echo "  Total rules: $(find "$RULES_DIR" -name "*.md" | wc -l)"
