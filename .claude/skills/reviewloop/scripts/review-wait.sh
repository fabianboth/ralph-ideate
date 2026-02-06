#!/usr/bin/env bash
# Usage: ./review-wait.sh [--timeout=600]
set -euo pipefail

INITIAL_DELAY=10
POLL_INTERVAL=15
DEFAULT_TIMEOUT=600
RUNNING_STATES=(pending in_progress queued waiting requested)

die() {
    echo "Error: $1" >&2
    exit "${2:-1}"
}

check_dependencies() {
    command -v gh &>/dev/null || die "gh CLI is not installed. Install from https://cli.github.com/"
    command -v jq &>/dev/null || die "jq is not installed. Install from https://stedolan.github.io/jq/download/"
    gh auth status &>/dev/null || die "gh CLI is not authenticated. Run 'gh auth login' first."
}

get_pr_number() {
    local pr_number
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null) || die "No PR found for current branch"
    [[ -n "$pr_number" ]] || die "No PR found for current branch"
    echo "$pr_number"
}

# Returns aggregated state: if any check is running, returns that state; otherwise returns the last state
get_ci_state() {
    local pr_number="$1"
    local checks_json states
    checks_json=$(gh pr checks "$pr_number" --json name,state 2>&1) || die "Failed to fetch PR checks: $checks_json"

    # Get all check states
    states=$(echo "$checks_json" | jq -r '[.[] | .state] | if length == 0 then "" else .[] end' 2>/dev/null)

    [[ -z "$states" ]] && return

    # If any state is a running state, return it (priority: running > completed)
    local state
    while IFS= read -r state; do
        if is_running_state "$state"; then
            echo "$state"
            return
        fi
    done <<< "$states"

    # No running states found, return the last state
    echo "$states" | tail -n1
}

is_running_state() {
    local state="${1,,}"
    local s
    for s in "${RUNNING_STATES[@]}"; do
        [[ "$state" == "$s" ]] && return 0
    done
    return 1
}

parse_args() {
    TIMEOUT=$DEFAULT_TIMEOUT
    local arg value
    for arg in "$@"; do
        if [[ "$arg" == --timeout=* ]]; then
            value="${arg#--timeout=}"
            if [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -gt 0 ]]; then
                TIMEOUT="$value"
            else
                echo "Invalid timeout value, using default" >&2
            fi
        fi
    done
}

main() {
    parse_args "$@"
    check_dependencies

    local pr_number state start_time current_time elapsed
    pr_number=$(get_pr_number)

    echo "Waiting ${INITIAL_DELAY}s for CI to start..."
    sleep "$INITIAL_DELAY"

    state=$(get_ci_state "$pr_number")

    if [[ -z "$state" ]] || ! is_running_state "$state"; then
        echo "No CI checks in progress"
        exit 0
    fi

    echo "Waiting for CI checks on PR #${pr_number}..."
    start_time=$(date +%s)

    while true; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))

        if [[ $elapsed -ge $TIMEOUT ]]; then
            echo ""
            echo "Timeout after ${TIMEOUT}s"
            exit 1
        fi

        state=$(get_ci_state "$pr_number")

        if [[ -z "$state" ]] || ! is_running_state "$state"; then
            echo ""
            echo "CI completed${state:+ ($state)}"
            exit 0
        fi

        printf "."
        sleep "$POLL_INTERVAL"
    done
}

main "$@"
