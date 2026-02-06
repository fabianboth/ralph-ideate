#!/usr/bin/env bash
set -euo pipefail

RALPH_STATE_FILE=".claude/ralph-ideate.local.md"

# Exit if no active loop
if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  exit 0
fi

# Parse frontmatter (YAML between ---)
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
DOMAIN_PATH=$(echo "$FRONTMATTER" | grep '^domain_path:' | sed 's/domain_path: *//')

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]] || [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Ralph Ideate: State file corrupted. Resetting loop..." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Stop if max iterations reached
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Ralph Ideate: Max iterations ($MAX_ITERATIONS) reached." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Continue loop: increment iteration
NEXT_ITERATION=$((ITERATION + 1))
TEMP_FILE="${RALPH_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$RALPH_STATE_FILE"

# Extract original prompt (everything after second ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")
if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Ralph Ideate: Prompt missing. Resetting loop..." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

DOMAIN_NAME=$(basename "$DOMAIN_PATH")

if [[ $MAX_ITERATIONS -gt 0 ]]; then
  SYSTEM_MSG="Ralph iteration $NEXT_ITERATION of $MAX_ITERATIONS | Domain: $DOMAIN_NAME"
else
  SYSTEM_MSG="Ralph iteration $NEXT_ITERATION | Domain: $DOMAIN_NAME"
fi

sleep 1
# Output JSON to block exit and continue loop
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'
exit 0
