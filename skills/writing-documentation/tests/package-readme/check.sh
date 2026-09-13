#!/bin/bash
f=README.md
if [[ ! -f "$f" ]]; then echo "readme_written=no"; exit 0; fi
echo "readme_written=yes"
echo "prose_findings=$(awk -f "$SKILLS_DIR/writing-documentation/scripts/prose-scan.awk" "$f" | wc -l | tr -d ' ')"
echo "first_person_in_opener=$(sed -n '1,/^## /p' "$f" | grep -cwE 'I|my')"
echo "sections_with_you=$(awk '/^## /{if(h!="")print y; h=$0; y=0} tolower($0) ~ /(^|[^a-z])you([^a-z]|$)/{y=1} END{if(h!="")print y}' "$f" | grep -c 1)"
echo "name_collision_named=$(grep -ciE 'taken|unrelated package|different package|wrong package' "$f")"
echo "limitation_named=$(grep -ciE 'CJK|does not|not supported' "$f")"
