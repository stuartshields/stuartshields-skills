<!-- Last updated: 2026-08-31T12:20+11:00 -->

# Detection

Everything the skill reads before it writes. Run these rather than assuming.

## The base branch

```sh
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||'
```

Falls back to checking which of `main`, `master`, `develop` exists. Where the
PR already exists, `gh pr view --json baseRefName` is authoritative.

## The change

```sh
git diff --stat <base>...HEAD
git log --oneline --no-merges <base>...HEAD
git diff <base>...HEAD
```

Three dots compares against the merge base, which is what the PR will show. Two
dots reports unrelated commits from the base as part of your change.

`--stat` first: it gives the line count for the size check in step 5 and says
whether the full diff is readable in one pass.

## The template

Four locations, checked in this order:

```sh
ls .github/pull_request_template.md \
   pull_request_template.md \
   docs/pull_request_template.md \
   .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

GitHub also honours a `PULL_REQUEST_TEMPLATE` subdirectory inside the root or
`docs/`, and the filename is case-insensitive in practice. Where nothing turns
up, widen once:

```sh
find . -iname 'pull_request_template*' -not -path './node_modules/*' 2>/dev/null
```

Where the directory form holds several templates, they are selected by a
`template` query parameter on the PR URL. Pick by the kind of change and name
which you picked.

Templates only take effect once merged to the default branch, so a template
added on the current branch is not yet live. Use it anyway and say so.

## The commit convention

```sh
git log --format=%s -n 40 <base>
```

Conventional Commits shows as a `type:` or `type(scope):` prefix on most
subjects. A handful of stray `fix:` lines is not a convention. Match what is
there; do not introduce one the repo has not adopted.

## The issue reference

Three places, in order:

1. The branch name: `feature/PROJ-412-retry-webhooks`, `1234-fix-queue`.
2. A commit trailer: `Refs: #1234`, `Closes #1234`.
3. The user, where neither carries one and the change looks issue-driven.

**Closing keywords** GitHub recognises: `close`, `closes`, `closed`, `fix`,
`fixes`, `fixed`, `resolve`, `resolves`, `resolved`, each followed by `#<n>`,
or `owner/repo#<n>` across repositories.

Use one only where merging finishes the issue. On a partial change it closes
work still open, and nobody notices until the issue is missing from the board.

## Existing PR state

Where the PR is already open:

```sh
gh pr view --json title,body,baseRefName,files,additions,deletions
gh pr diff
```

Rewriting an existing description keeps anything a human added that the diff
still supports. Say what you removed and why.

## Sources

- https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository
- https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes
- https://www.conventionalcommits.org/en/v1.0.0/
