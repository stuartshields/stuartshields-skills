#!/bin/bash
r="$1"
echo "tiers=$(grep -c '^### P[0-2]' "$r")"
echo "none_markers=$(grep -c '^- none' "$r")"
echo "closing_ask=$(grep -ci 'want me to fix' "$r")"
echo "followups_section=$(grep -ci 'suggested follow-ups' "$r")"
