#!/bin/bash
f=inc/reading-time.php
echo "this_function_opener_left=$(grep -c 'This function' "$f")"
echo "removed_param_left=$(grep -c 'round_up' "$f")"
echo "wrong_type_left=$(grep -c 'WP_Post' "$f")"
if bash "$SKILLS_DIR/writing-docblocks/scripts/check-docblocks.sh" "$f" > /dev/null 2>&1; then echo "param_check=pass"; else echo "param_check=fail"; fi
