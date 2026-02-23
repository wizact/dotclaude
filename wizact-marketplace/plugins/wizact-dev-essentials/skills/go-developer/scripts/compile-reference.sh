#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
RULES_DIR="$SKILL_DIR/rules"
REFERENCE_FILE="$SKILL_DIR/REFERENCE.md"

echo "Compiling REFERENCE.md from rule files..."

# Start with header
cat > "$REFERENCE_FILE" << 'EOF'
# Go Developer - Complete Reference

Complete guide to production-ready Go development. All rules expanded with full context.

**Generated from individual rule files** - Edit rules/*.md, then run compile-reference.sh

## Table of Contents
1. [Architecture (CRITICAL)](#architecture-critical)
2. [Security (CRITICAL)](#security-critical)
3. [Testing (HIGH)](#testing-high)
4. [Error Handling (HIGH)](#error-handling-high)
5. [Code Organization (MEDIUM)](#code-organization-medium)
6. [Performance (MEDIUM)](#performance-medium)
7. [Patterns (LOW)](#patterns-low)

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
compile_category "arch" "Architecture" "CRITICAL"
compile_category "security" "Security" "CRITICAL"
compile_category "test" "Testing" "HIGH"
compile_category "error" "Error Handling" "HIGH"
compile_category "org" "Code Organization" "MEDIUM"
compile_category "perf" "Performance" "MEDIUM"
compile_category "pattern" "Patterns" "LOW"

echo "✓ REFERENCE.md compiled successfully"
echo "  Location: $REFERENCE_FILE"
echo "  Total rules: $(find "$RULES_DIR" -name "*.md" | wc -l)"
