---
name: ralph-ideate.create
description: Create a new brainstorming domain - scaffolds directory structure and writes DESCRIPTION.md under ideate/.
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

Check if `ideate/<domain-name>/` already exists. If it does, warn the user and ask whether to overwrite or pick a different name.

### Step 3: Gather Domain Description

Ask the user to describe their brainstorming domain in a single prompt. They should cover what the domain is about, any constraints or boundaries, and what makes a good opportunity - all in one free-form description.

Example prompt: *"Describe your brainstorming domain - what's the focus, any constraints, and what makes a good idea in this space?"*

From the user's response, extract focus areas, constraints, and evaluation criteria to populate the structured DESCRIPTION.md. Do not ask multiple follow-up questions - derive the structure from a single response.

### Step 4: Create Directory Structure

```bash
mkdir -p ideate/<domain-name>/candidates
mkdir -p ideate/<domain-name>/verified
mkdir -p ideate/<domain-name>/discarded
```

### Step 5: Write DESCRIPTION.md

Write `ideate/<domain-name>/DESCRIPTION.md` following this format:

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

Fill in the sections based on the user's description. Be concise and specific - this file will guide the brainstorming exploration.

### Step 6: Confirm

Tell the user the domain has been created and show the structure:
- `ideate/<domain-name>/DESCRIPTION.md`
- `ideate/<domain-name>/candidates/` (empty - ready for ideas)
- `ideate/<domain-name>/verified/` (empty)
- `ideate/<domain-name>/discarded/` (empty)

Suggest they can now run `/ralph-ideate.explore ideate/<domain-name>` to start brainstorming.
