#!/bin/bash
f=docs/HANDOFF.md
echo "lines=$(wc -l < "$f" | tr -d ' ')"
echo "dated_heading=$(grep -cE '^## .*20[0-9]{2}-' "$f")"
echo "key_files_section=$(grep -c '^## Key files' "$f")"
echo "test_command_named=$(grep -c 'npm test' "$f")"
echo "stale_path_left=$(grep -c 'src/optimise.js' "$f")"
