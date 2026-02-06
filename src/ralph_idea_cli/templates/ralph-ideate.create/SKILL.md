---
name: ralph-ideate.create
description: Create a new brainstorming domain with structured directory and description file.
argument-hint: <domain-name>
allowed-tools: Write, Edit, Bash(mkdir *)
disable-model-invocation: true
---

## Create a New Brainstorming Domain

You are creating a new brainstorming domain for the Ralph Ideate system.

### Step 1: Sanitize Domain Name

The user provided: `$ARGUMENTS`

Sanitize the domain name:
- Convert to lowercase
- Replace spaces and underscores with hyphens
- Remove special characters (keep only alphanumeric and hyphens)
- Reject if it contains slashes (no nested paths)
- Reject if it starts with `--` (looks like a flag)
- Reject if empty after sanitization

Examples: `SaaS Tools` → `saas-tools`, `mobile_apps` → `mobile-apps`, `AI & ML` → `ai-ml`

### Step 2: Check for Existing Domain

Check if `src/<domain-name>/` already exists. If it does, warn the user and ask whether to overwrite or pick a different name.

### Step 3: Gather Domain Description

Ask the user to describe their brainstorming domain. You need to understand:

1. **Focus**: What is this domain about? What market or industry? What types of opportunities?
2. **Constraints**: What are the boundaries? (e.g., B2B only, must be software, budget limits)
3. **What Makes a Good Opportunity**: What evaluation criteria matter for this domain? What distinguishes a strong idea from a weak one?

Have a brief conversation to understand these aspects. Don't over-ask — a few focused questions are enough.

### Step 4: Create Directory Structure

```bash
mkdir -p src/<domain-name>/candidates
mkdir -p src/<domain-name>/verified
mkdir -p src/<domain-name>/discarded
```

### Step 5: Write DESCRIPTION.md

Write `src/<domain-name>/DESCRIPTION.md` following this format:

```markdown
# <Domain Title (Human-Readable)>

<Brief one-line description of what this domain covers.>

## Focus
- <Key focus area 1>
- <Key focus area 2>
- <Additional focus points as needed>

## Constraints
- <Constraint 1>
- <Constraint 2>
- <Additional constraints as needed>

## What Makes a Good Opportunity
- <Criterion 1>
- <Criterion 2>
- <Additional criteria as needed>
```

Fill in the sections based on the user's description. Be concise and specific — this file will guide the brainstorming exploration.

### Step 6: Confirm

Tell the user the domain has been created and show the structure:
- `src/<domain-name>/DESCRIPTION.md`
- `src/<domain-name>/candidates/` (empty — ready for ideas)
- `src/<domain-name>/verified/` (empty)
- `src/<domain-name>/discarded/` (empty)

Suggest they can now run `/ralph-ideate.explore src/<domain-name>` to start brainstorming.
