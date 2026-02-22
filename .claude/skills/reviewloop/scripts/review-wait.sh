#!/usr/bin/env bash
# Usage: ./review-wait.sh [--timeout=600]
set -euo pipefail

INITIAL_DELAY=10
POLL_INTERVAL=15
DEFAULT_TIMEOUT=600
RUNNING_STATES=(pending in_progress queued waiting requested)
FAILURE_STATES=(failure error cancelled timed_out startup_failure action_required stale)
LAST_CHECKS_JSON=""

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

# Returns aggregated state with priority: failure > running > success
# Stores raw JSON in LAST_CHECKS_JSON for reuse by get_failed_checks
get_ci_state() {
    local pr_number="$1"
    LAST_CHECKS_JSON=$(gh pr checks "$pr_number" --json name,state 2>&1) || die "Failed to fetch PR checks: $LAST_CHECKS_JSON"

    local states
    states=$(echo "$LAST_CHECKS_JSON" | jq -r '[.[] | .state] | if length == 0 then "" else .[] end' 2>/dev/null | tr -d '\r')

    [[ -z "$states" ]] && return

    local state has_running=false
    while IFS= read -r state; do
        if is_failure_state "$state"; then
            echo "FAILED"
            return
        fi
        if is_running_state "$state"; then
            has_running=true
        fi
    done <<< "$states"

    if [[ "$has_running" == "true" ]]; then
        echo "running"
        return
    fi

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

is_failure_state() {
    local state="${1,,}"
    local s
    for s in "${FAILURE_STATES[@]}"; do
        [[ "$state" == "$s" ]] && return 0
    done
    return 1
}

failure_states_jq_filter() {
    local filter="["
    local first=true
    for s in "${FAILURE_STATES[@]}"; do
        [[ "$first" == "true" ]] && first=false || filter+=","
        filter+="\"$s\""
    done
    filter+="]"
    echo "$filter"
}

print_failed_checks() {
    local filter
    filter=$(failure_states_jq_filter)
    echo "CI failed. Failed checks:"
    echo "$LAST_CHECKS_JSON" | jq -r --argjson states "$filter" '.[] | select((.state | ascii_downcase) as $s | $states | index($s)) | "  - " + .name' 2>/dev/null | tr -d '\r'
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

    if [[ "$state" == "FAILED" ]]; then
        print_failed_checks
        exit 2
    fi

    if [[ -z "$state" ]] || [[ "$state" != "running" ]]; then
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

        if [[ "$state" == "FAILED" ]]; then
            echo ""
            print_failed_checks
            exit 2
        fi

        if [[ -z "$state" ]] || [[ "$state" != "running" ]]; then
            echo ""
            echo "CI completed${state:+ ($state)}"
            exit 0
        fi

        printf "."
        sleep "$POLL_INTERVAL"
    done
}

main "$@"
