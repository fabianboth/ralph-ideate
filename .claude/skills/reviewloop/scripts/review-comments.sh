#!/usr/bin/env bash
set -euo pipefail

GRAPHQL_QUERY='query($owner: String!, $repo: String!, $pr: Int!) { repository(owner: $owner, name: $repo) { pullRequest(number: $pr) { reviews(first: 100) { nodes { id databaseId author { login } body reactions(first: 100) { nodes { user { login } content } } } } reviewThreads(first: 100) { nodes { id isResolved comments(first: 1) { nodes { author { login } path line body } } } } } } }'

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

get_repo_info() {
    gh repo view --json owner,name 2>&1 || die "Failed to get repository info"
}

get_current_user() {
    gh api user -q '.login' 2>&1 || die "Failed to get current user"
}

run_graphql() {
    local owner="$1" repo="$2" pr="$3"
    gh api graphql -F "owner=$owner" -F "repo=$repo" -F "pr=$pr" -f "query=$GRAPHQL_QUERY" 2>&1 || die "GraphQL query failed"
}

print_thread() {
    local thread="$1" is_first="$2"

    [[ "$is_first" == "false" ]] && { echo ""; echo "---"; echo ""; }

    echo "## $(echo "$thread" | jq -r '.comments.nodes[0].path // "unknown"'):$(echo "$thread" | jq -r '.comments.nodes[0].line // "?"')"
    echo ""
    echo "**Thread ID:** \`$(echo "$thread" | jq -r '.id')\`"
    echo "**Author:** $(echo "$thread" | jq -r '.comments.nodes[0].author.login // "unknown"')"
    echo ""
    echo "$thread" | jq -r '.comments.nodes[0].body // ""'
}

print_review() {
    local review="$1" is_first="$2"

    [[ "$is_first" == "false" ]] && { echo ""; echo "---"; echo ""; }

    echo "**Review ID:** \`$(echo "$review" | jq -r '.id')\`"
    echo "**Author:** $(echo "$review" | jq -r '.author // "unknown"')"
    echo ""
    echo "$review" | jq -r '.body // ""'
}

main() {
    check_dependencies

    local repo_info owner repo pr_number current_user
    repo_info=$(get_repo_info)
    owner=$(echo "$repo_info" | jq -r '.owner.login')
    repo=$(echo "$repo_info" | jq -r '.name')
    pr_number=$(get_pr_number)
    current_user=$(get_current_user)

    local result pr_data
    result=$(run_graphql "$owner" "$repo" "$pr_number")
    pr_data=$(echo "$result" | jq '.data.repository.pullRequest')

    local unresolved_threads review_bodies thread_count review_count

    unresolved_threads=$(echo "$pr_data" | jq '[.reviewThreads.nodes[] | select(.isResolved == false and (.comments.nodes | length) > 0)]')

    # Get reviews user hasn't reacted to, strip HTML comments
    review_bodies=$(echo "$pr_data" | jq --arg user "$current_user" '
        [.reviews.nodes[]
            | select(.body != null and .body != "")
            | select(([.reactions.nodes[] | select(.user.login == $user and .content == "THUMBS_UP")] | length) == 0)
            | {id: .id, author: .author.login, body: (.body | gsub("<!--.*?-->"; "") | gsub("^\\s+|\\s+$"; ""))}
            | select(.body != "")
        ]')

    thread_count=$(echo "$unresolved_threads" | jq 'length')
    review_count=$(echo "$review_bodies" | jq 'length')

    mkdir -p .reviews

    if [[ "$thread_count" -eq 0 ]] && [[ "$review_count" -eq 0 ]]; then
        cat > .reviews/prComments.md << EOF
# Review Comments

**PR:** #${pr_number}

No unresolved comments.
EOF
        echo "No unresolved comments found on this PR"
        exit 0
    fi

    local resolve_cmd='gh api graphql -f query='\''mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'\'''
    local react_cmd='gh api graphql -f query='\''mutation { addReaction(input: {subjectId: "REVIEW_ID", content: THUMBS_UP}) { reaction { content } } }'\'''

    {
        cat << EOF
# Review Comments

**PR:** #${pr_number}
**Inline threads (unresolved):** ${thread_count}
**Review comments (unreacted):** ${review_count}

To resolve an inline thread after addressing it:
\`\`\`bash
${resolve_cmd}
\`\`\`

To mark a review as addressed (adds reaction):
\`\`\`bash
${react_cmd}
\`\`\`

EOF

        if [[ "$thread_count" -gt 0 ]]; then
            echo "---"
            echo ""
            echo "# Inline Comments (Unresolved)"
            echo ""

            local is_first=true
            while IFS= read -r thread; do
                print_thread "$thread" "$is_first"
                is_first=false
            done < <(echo "$unresolved_threads" | jq -c '.[]')
        fi

        if [[ "$review_count" -gt 0 ]]; then
            echo ""
            echo "---"
            echo ""
            echo "# Review Comments (${review_count})"
            echo ""

            local is_first=true
            while IFS= read -r review; do
                print_review "$review" "$is_first"
                is_first=false
            done < <(echo "$review_bodies" | jq -c '.[]')
        fi
    } > .reviews/prComments.md

    echo "Saved review comments to .reviews/prComments.md:"
    echo "  - ${thread_count} unresolved inline threads"
    echo "  - ${review_count} review comments"
}

main "$@"
