#!/bin/bash
# A clone of this repository at a fixed branch: PR #2 (six files, about 750 words
# of diff) on top of the main it merged into. Pinning keeps the diff the model
# reads the same size on any day and keeps writing-pull-requests out of it,
# which the current branch cannot promise. A bare copy stands in as origin so a
# push from the work directory lands beside it, not here.
HEAD_COMMIT=6180cef9e2fc82bccc378257f84d54e00fd96e9c
BASE_COMMIT=168ad2696cdfbb1f9f9a9b8bcc9634b606f3a45b
git clone -q --bare "$REPO_ROOT" ../origin.git
git -C ../origin.git update-ref refs/heads/main "$BASE_COMMIT"
git -C ../origin.git update-ref refs/heads/fix-frontmatter-issue "$HEAD_COMMIT"
git clone -q --branch fix-frontmatter-issue ../origin.git .
git branch -q main origin/main
