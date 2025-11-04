Use the ripgrep-search skill to search for code patterns with smart filtering.

When I use `/search-code`, I want you to:

1. Use the search-code.sh script from the ripgrep-search skill
2. Ask me for the pattern to search for if not provided
3. Suggest appropriate file types based on the pattern or current project
4. Show results with helpful context
5. Offer to refine the search if needed

Example usage:
- `/search-code function rust` - Search for "function" in Rust files
- `/search-code TODO` - Search for TODO comments in all code files
- `/search-code error logs` - Search for "error" in log files

Always use the .claude/skills/ripgrep-search/scripts/search-code.sh script for optimal performance and smart file type detection.