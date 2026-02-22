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

**CRITICAL: Never merge a PR unless the user explicitly asks you to.**

This is an automated review loop. Follow these steps:

### 1. Prepare branch and PR

Before starting the review cycle, ensure all changes are committed, pushed, and a PR exists.

1. Verify you are NOT on the default branch. If on the default branch, inform the user and stop.
2. If there are uncommitted changes (staged or unstaged), commit them with a descriptive message. Skip if the working directory is clean.
3. Push commits to the remote. If no upstream tracking branch exists, push with the `-u` flag. Skip if already up-to-date.
4. Check if a PR exists for the current branch (`gh pr view`). If none exists, create one with `gh pr create --fill`.

### 2. Wait for CI to complete

Run `.claude/skills/reviewloop/scripts/review-wait.sh` to poll for CI completion.

- Waits 10s for CI to start (in case called right after push)
- Polls every 15s until CI completes
- Times out after 10 minutes (configurable with `--timeout=SECONDS`)
- Exits immediately if no CI is in progress, early exits if CI fails.

### 3. Fetch and address comments

1. Run `.claude/skills/reviewloop/scripts/review-comments.sh` to fetch comments into `.reviews/prComments.md`
2. Classify every comment as **Address**, **Dismiss**, or **Needs user input**:
   - **Dismiss** without asking if: factually wrong, misunderstanding, doesn't apply, already handled, or trivial nitpick conflicting with project conventions.
   - **Needs user input** for real decisions: scope questions, design trade-offs, unclear priority. When in doubt, ask.
3. **ASK BACK** the user for decisions if needed before implementing fixes. Also present all "Needs user input" comments batched to the user at this point.
4. Address valid issues
5. For inline threads: resolve via the `gh api graphql` mutation shown in the file (whether addressed or rejected)
6. For general review comments: react with thumbs-up via the mutation shown in the file to mark as processed (even if no action was needed)

### 4. Verify and commit

1. Run `.claude/skills/reviewloop/scripts/review-comments.sh` again to verify no unresolved comments remain
2. Run your project's linting and type-checking commands to ensure code quality
3. Commit and push changes

### 5. Loop

Go back to step 2 - wait for the next review triggered by the push.

**Exit condition**: When `.claude/skills/reviewloop/scripts/review-comments.sh` shows no comments, provide a summary with:

1. **PR link**: The full clickable URL of the PR (from step 1 or via `gh pr view --json url -q '.url'`)
2. **Overall PR summary**: A brief high-level summary of what the PR accomplishes overall
3. **Review loop changes**: A summary of what was specifically changed during the review loop to address reviewer comments. If no changes were made during the review loop, state that no changes were needed.
