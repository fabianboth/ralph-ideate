---
name: reviewloop
description: Run the autonomous review loop to address PR comments, fix issues, and push changes iteratively until all comments are resolved.
disable-model-invocation: true
allowed-tools:
  - Bash(.claude/skills/reviewloop/scripts/review-wait.sh*)
  - Bash(.claude/skills/reviewloop/scripts/review-comments.sh*)
  - Bash(gh *)
---

## Autonomous Review Loop

This is an automated review loop. Follow these steps:

### 1. Wait for CI to complete

Run `.claude/skills/reviewloop/scripts/review-wait.sh` to poll for CI completion.

- Waits 10s for CI to start (in case called right after push)
- Polls every 15s until CI completes
- Times out after 10 minutes (configurable with `--timeout=SECONDS`)
- Exits immediately if no CI is in progress

### 2. Fetch and address comments

Once CI completes:

1. Run `.claude/skills/reviewloop/scripts/review-comments.sh` to fetch comments into `.reviews/prComments.md`
2. Review all comments critically - not all may be valid or apply to our codebase
3. **ASK BACK** the user for decisions if needed before implementing fixes
4. Address valid issues
5. For inline threads: resolve via the `gh api graphql` mutation shown in the file (whether addressed or rejected)
6. For general review comments: react with thumbs-up via the mutation shown in the file to mark as processed (even if no action was needed)

### 3. Verify and commit

1. Run `.claude/skills/reviewloop/scripts/review-comments.sh` again to verify no unresolved comments remain
2. Run your project's linting and type-checking commands to ensure code quality
3. Commit and push changes

### 4. Loop

Go back to step 1 - wait for the next review triggered by the push.

**Exit condition**: When `.claude/skills/reviewloop/scripts/review-comments.sh` shows no comments. Give a brief high-level summary of what was addressed.
