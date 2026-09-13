#!/bin/bash
r="$1"
echo "fenced=$(grep -c '^`\{3,\}markdown' "$r")"
echo "title_given=$(grep -ciE '^(## |\*\*)?title' "$r")"
echo "skip_line=$(grep -c '\*\*Skip\*\*' "$r")"
echo "not_run_stated=$(grep -ci 'not run' "$r")"
echo "banned_opener=$(grep -cE '^(This PR|This change)' "$r")"
echo "commits_added=$(git rev-list --count "origin/$(git rev-parse --abbrev-ref HEAD)..HEAD" 2>/dev/null || echo unknown)"
