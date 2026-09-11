#!/bin/bash
# Gathers everything writing-pull-requests needs before it drafts anything:
# base branch, the diff, the size verdict, the template, the commit
# convention, and any issue reference. One call replaces six, so the
# description gets written from what the repo says rather than from the
# branch name.
#
# Usage: pr-context.sh [base-branch]
# Reads nothing from stdin. Writes a plain-text report to stdout.

set -uo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "Not a git repository. Ask the user for the change to describe."
	exit 1
fi

BASE="${1:-}"

if [ -z "$BASE" ]; then
	BASE=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
fi

if [ -z "$BASE" ]; then
	for candidate in main master develop trunk; do
		if git show-ref --verify --quiet "refs/heads/$candidate"; then
			BASE="$candidate"
			break
		fi
	done
fi

if [ -z "$BASE" ]; then
	echo "Could not determine the base branch. Pass it as the first argument."
	exit 1
fi

HEAD_REF=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ "$HEAD_REF" = "$BASE" ]; then
	echo "HEAD is $BASE, the base branch itself. There is no branch to describe."
	echo "Ask the user which branch or commit range they mean."
	exit 1
fi

echo "=== BASE ==="
echo "$BASE...$HEAD_REF"
echo

echo "=== PUSHABLE ==="
# The gate. Nothing gets drafted for a branch that cannot reach a remote, so
# this runs before the context worth gathering. BatchMode and
# GIT_TERMINAL_PROMPT stop a credential prompt hanging the call: there is no
# timeout binary on this machine to cap it with.
REMOTE=$(git remote | head -1)
if [ -z "$REMOTE" ]; then
	echo "NO: no git remote configured. Nothing to push to."
elif ! GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -oBatchMode=yes' \
	git push --dry-run "$REMOTE" "HEAD:$HEAD_REF" >/dev/null 2>&1; then
	echo "NO: dry-run push to $REMOTE failed. Reproduce with:"
	echo "  git push --dry-run $REMOTE HEAD:$HEAD_REF"
else
	echo "YES: dry-run push to $REMOTE succeeds."
	# gh auth status answers for the GitHub account, not for this remote, so a
	# non-GitHub remote would otherwise read as "PR can be opened from here".
	if ! git remote get-url "$REMOTE" 2>/dev/null | grep -q 'github\.com'; then
		echo "$REMOTE is not a github.com remote. gh cannot open the PR; use the host's own tool."
	elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
		echo "gh authenticated: the PR can be opened from here."
	else
		echo "gh missing or unauthenticated: the branch pushes, the PR must be opened by hand."
	fi
fi
echo

echo "=== SIZE ==="
# Three-dot compares against the merge base, which is what the PR will show.
STAT=$(git diff --shortstat "$BASE...HEAD" 2>/dev/null)
FILES=$(git diff --name-only "$BASE...HEAD" 2>/dev/null | grep -c .)
ADDED=$(git diff --numstat "$BASE...HEAD" 2>/dev/null | awk '{ if ($1 != "-") s += $1 } END { print s + 0 }')
REMOVED=$(git diff --numstat "$BASE...HEAD" 2>/dev/null | awk '{ if ($2 != "-") s += $2 } END { print s + 0 }')
CHANGED=$((ADDED + REMOVED))
echo "${STAT:-no changes}"
echo "changed lines: $CHANGED across $FILES files"

# Google's thresholds: 100 lines usually reasonable, 1000 usually too large,
# and spread counts separately from volume.
if [ "$CHANGED" -gt 1000 ]; then
	echo "VERDICT: over Google's 1000-line guidance. Propose a split unless an exception applies."
elif [ "$CHANGED" -gt 100 ]; then
	echo "VERDICT: above the 100-line comfortable size, under the 1000-line ceiling."
else
	echo "VERDICT: within the 100-line comfortable size."
fi
if [ "$FILES" -gt 50 ]; then
	echo "SPREAD: $FILES files. Google treats wide spread as its own size problem."
fi

# The two exceptions Google names, surfaced so they are not missed.
DELETED_FILES=$(git diff --diff-filter=D --name-only "$BASE...HEAD" 2>/dev/null | grep -c .)
RENAMED_FILES=$(git diff -M --diff-filter=R --name-only "$BASE...HEAD" 2>/dev/null | grep -c .)
[ "$DELETED_FILES" -gt 0 ] && echo "EXCEPTION: $DELETED_FILES whole-file deletions, which count as roughly one line of review each."
[ "$RENAMED_FILES" -gt 0 ] && echo "EXCEPTION: $RENAMED_FILES detected renames, which a reviewer verifies rather than reads."
echo

echo "=== FILES ==="
git diff --stat "$BASE...HEAD" 2>/dev/null | tail -40
echo

echo "=== COMMITS ==="
git log --oneline --no-merges "$BASE...HEAD" 2>/dev/null | head -40
echo

echo "=== COMMIT CONVENTION ==="
# Conventional Commits shows as a type: or type(scope): prefix on most
# subjects. A handful of stray fix: lines is not a convention.
RECENT=$(git log --format=%s -n 40 "$BASE" 2>/dev/null)
TOTAL=$(printf '%s\n' "$RECENT" | grep -c .)
CONV=$(printf '%s\n' "$RECENT" | grep -cE '^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([^)]+\))?!?: ')
if [ "$TOTAL" -lt 5 ]; then
	echo "Only $TOTAL subjects on $BASE, too few to read a convention from. Ask the user, or match the branch."
elif [ "$CONV" -gt $((TOTAL / 2)) ]; then
	echo "Conventional Commits: yes ($CONV of $TOTAL recent subjects). Match the prefix."
else
	echo "Conventional Commits: no ($CONV of $TOTAL recent subjects). Do not introduce one."
fi
echo

echo "=== TEMPLATE ==="
TEMPLATE=""
for path in .github/pull_request_template.md pull_request_template.md docs/pull_request_template.md; do
	if [ -f "$path" ]; then
		TEMPLATE="$path"
		break
	fi
done
if [ -z "$TEMPLATE" ]; then
	for dir in .github/PULL_REQUEST_TEMPLATE docs/PULL_REQUEST_TEMPLATE PULL_REQUEST_TEMPLATE; do
		if [ -d "$dir" ]; then
			echo "Directory form at $dir, holding:"
			ls -1 "$dir"
			echo "Pick by the kind of change and say which you picked."
			TEMPLATE="$dir"
			break
		fi
	done
fi
if [ -z "$TEMPLATE" ]; then
	# Widen once before concluding there is none. Filenames are
	# case-insensitive in practice.
	FOUND=$(find . -maxdepth 3 -iname 'pull_request_template*' -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null | head -5)
	if [ -n "$FOUND" ]; then
		echo "Found outside the standard paths:"
		printf '%s\n' "$FOUND"
	else
		echo "None. Use the four-part body from SKILL.md step 4."
	fi
elif [ -f "$TEMPLATE" ]; then
	echo "Found: $TEMPLATE"
	echo "--- required sections ---"
	grep -nE '^#{1,4} ' "$TEMPLATE" || echo "(no headings; read the file in full)"
	echo "Fill every section. Where one does not apply, say why rather than deleting the heading."
fi
echo

echo "=== ISSUE REFERENCE ==="
BRANCH_ISSUE=$(printf '%s' "$HEAD_REF" | grep -oE '[A-Z]+-[0-9]+|(^|/)[0-9]{2,}' | head -1)
TRAILER=$(git log --format=%B "$BASE...HEAD" 2>/dev/null | grep -iE '^(refs|closes|fixes|resolves):? *#?[0-9]+' | head -3)
[ -n "$BRANCH_ISSUE" ] && echo "From the branch name: $BRANCH_ISSUE"
[ -n "$TRAILER" ] && { echo "From commit trailers:"; printf '%s\n' "$TRAILER"; }
[ -z "$BRANCH_ISSUE" ] && [ -z "$TRAILER" ] && echo "None found. Ask the user if the change is issue-driven."
echo "Closing keywords (close/closes/closed, fix/fixes/fixed, resolve/resolves/resolved)"
echo "only where merging finishes the issue. Otherwise reference it plainly."
echo

echo "=== EXISTING PR ==="
if command -v gh >/dev/null 2>&1; then
	gh pr view --json title,baseRefName,additions,deletions,url 2>/dev/null \
		|| echo "No open PR for this branch, or gh is not authenticated."
else
	echo "gh not installed. Skipping."
fi
echo

echo "=== NEXT ==="
echo "Read the diff itself before drafting: git diff $BASE...HEAD"
if [ "$CHANGED" -gt 800 ]; then
	echo "Large: read the files carrying logic, skip generated and vendored ones, and say in your reply that you did."
fi
