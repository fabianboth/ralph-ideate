#!/usr/bin/env bash
set -euo pipefail

PROMPT_PARTS=()
MAX_ITERATIONS=20
DOMAIN_PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Ralph Ideate - Setup the brainstorming exploration loop

USAGE:
  setup-ralph-ideate.sh --domain <path> [--max-iterations N] [PROMPT...]

OPTIONS:
  --domain <path>          Path to domain directory (required)
  --max-iterations <n>     Maximum iterations before auto-stop (default: 20, 0 = unlimited)
  -h, --help               Show this help message

DESCRIPTION:
  Initializes the Ralph Ideate loop state file for continuous brainstorming.
  The stop hook will prevent exit and feed the prompt back each iteration.

EXAMPLES:
  setup-ralph-ideate.sh --domain ideate/saas-tools "Explore ideas"
  setup-ralph-ideate.sh --domain ideate/saas-tools --max-iterations 20 "Focus on B2B tools"
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --max-iterations requires a number argument" >&2
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations must be a positive integer or 0, got: $2" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --domain)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --domain requires a path argument" >&2
        exit 1
      fi
      DOMAIN_PATH="$2"
      shift 2
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$DOMAIN_PATH" ]]; then
  echo "Error: --domain is required" >&2
  exit 1
fi

# Strip trailing slash and /DESCRIPTION.md if provided
DOMAIN_PATH="${DOMAIN_PATH%/}"
DOMAIN_PATH="${DOMAIN_PATH%/DESCRIPTION.md}"

if [[ ! -f "$DOMAIN_PATH/DESCRIPTION.md" ]]; then
  echo "Error: No DESCRIPTION.md found at '$DOMAIN_PATH/DESCRIPTION.md'" >&2
  echo "" >&2
  echo "  Create a domain first with: /ralph-ideate.create <domain-name>" >&2
  exit 1
fi

USER_PROMPT="${PROMPT_PARTS[*]:-}"

# Build the loop prompt with @DESCRIPTION.md reference
DESCRIPTION_REF="@${DOMAIN_PATH}/DESCRIPTION.md"
if [[ -n "$USER_PROMPT" ]]; then
  LOOP_PROMPT="${DESCRIPTION_REF} ${USER_PROMPT}"
else
  LOOP_PROMPT="${DESCRIPTION_REF} Explore and brainstorm ideas for this domain. Follow the phases in the skill instructions."
fi

mkdir -p .claude

# Write state file using printf to avoid heredoc expansion issues with user prompt
{
  echo "---"
  echo "active: true"
  echo "iteration: 1"
  printf "max_iterations: %s\n" "$MAX_ITERATIONS"
  printf "domain_path: %s\n" "$DOMAIN_PATH"
  printf 'started_at: "%s"\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "---"
  echo ""
  printf "%s\n" "$LOOP_PROMPT"
} > .claude/ralph-ideate.local.md

DOMAIN_NAME=$(basename "$DOMAIN_PATH")

cat <<EOF
Ralph Ideate loop activated!

Domain: $DOMAIN_NAME ($DOMAIN_PATH)
Iteration: 1
Max iterations: $(if [[ "$MAX_ITERATIONS" -gt 0 ]]; then echo "$MAX_ITERATIONS"; else echo "unlimited"; fi)

The stop hook will feed the prompt back after each iteration.

EOF
