#!/usr/bin/env bash
set -euo pipefail

# Check for required dependency
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed." >&2
  echo "Install with: apt-get install jq  (Debian/Ubuntu)" >&2
  echo "              brew install jq      (macOS)" >&2
  echo "              choco install jq     (Windows)" >&2
  exit 1
fi

RALPH_STATE_FILE=".claude/ralph-ideate.local.md"

# Exit if no active loop
if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  exit 0
fi

# Parse frontmatter (YAML between --- delimiters)
ITERATION=""
MAX_ITERATIONS=""
DOMAIN_PATH=""

while IFS=': ' read -r key value; do
  case "$key" in
    iteration) ITERATION="$value" ;;
    max_iterations) MAX_ITERATIONS="$value" ;;
    domain_path) DOMAIN_PATH="$value" ;;
  esac
done < <(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]] || [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Ralph Ideate: State file corrupted. Resetting loop..." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Stop if max iterations reached
if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
  echo "Ralph Ideate: Max iterations ($MAX_ITERATIONS) reached." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Continue loop: increment iteration using mktemp for safe atomic update
NEXT_ITERATION=$((ITERATION + 1))
TEMP_FILE=$(mktemp "${RALPH_STATE_FILE}.XXXXXX") || {
  echo "Error: Failed to create temporary file" >&2
  exit 1
}
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$RALPH_STATE_FILE"

# Extract original prompt (everything after second ---) and pass through unchanged
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")
if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Ralph Ideate: Prompt missing. Resetting loop..." >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

DOMAIN_NAME=$(basename "$DOMAIN_PATH")

SYSTEM_MSG="Ralph iteration $NEXT_ITERATION of $MAX_ITERATIONS | Domain: $DOMAIN_NAME"

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
