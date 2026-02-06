---
name: ralph-ideate.refine
description: Refine and improve a brainstorming domain description. Reviews quality and applies targeted improvements.
argument-hint: @<domain-path> [refinement instructions]
allowed-tools: Read, Write, Edit, Glob, Grep
---

## Refine a Brainstorming Domain Description

You are refining the DESCRIPTION.md of an existing Ralph Ideate brainstorming domain. Your job is to improve the domain description — either by applying specific changes the user requested, or by performing a full quality review and suggesting improvements.

Follow the "do the work, ask only if necessary" pattern: apply changes and improve the description directly. Only ask the user a question (max 5 total) if there is a critical gap that cannot be reasonably defaulted.

### Step 1: Parse Input

The user provided: `$ARGUMENTS`

- **If empty (no arguments at all)**: List available domains under `ideate/` using Glob to find all `ideate/*/DESCRIPTION.md` files. Show the list and ask the user to pick one.
- **If domain path only** (e.g., `ideate/my-domain`): Perform a full quality review of that domain's description.
- **If domain path + refinement instructions** (e.g., `ideate/my-domain add anti-patterns for partial automation`): Apply the specific requested changes to that domain's description.

Extract:
- **Domain path**: The first argument that looks like a path (contains `/` or starts with `ideate/`). Users may use the `@` prefix for autocomplete — strip any leading `@` from the path.
- **Refinement instructions**: Everything after the domain path (may be empty)

### Step 2: Read Current Description

Read `<domain-path>/DESCRIPTION.md`.

If the file does not exist, inform the user and suggest they create the domain first with `/ralph-ideate.create`.

### Step 3: Apply Changes or Review

**If refinement instructions were provided:**

Apply the user's requested changes to the description. This might include:
- Adding new sections (e.g., anti-patterns, additional focus areas)
- Modifying existing criteria or constraints
- Strengthening weak areas
- Adding specificity to vague descriptions
- Removing or updating outdated guidance

After applying changes, proceed to Step 4 for quality review.

**If no refinement instructions (full quality review):**

**Less is more**: This description guides an infinite exploration loop (100+ iterations). Each section should have just enough direction to be useful — a few high-signal bullet points beat an exhaustive list. Over-specifying narrows the creative space and causes repetitive ideas.

Review the current DESCRIPTION.md against these quality criteria:

1. **Focus breadth**: Are focus areas broad enough to sustain 100+ iterations without becoming repetitive? Do they open up diverse angles rather than funneling into a narrow set?
2. **Constraint minimalism**: Are there only hard boundaries that truly matter? Too many constraints kill creativity — flag any that are "nice to have" rather than essential.
3. **Criteria clarity**: Do the quality criteria give a clear signal for strong vs weak ideas without being an exhaustive checklist?
4. **Extra sections**: If domain-specific sections exist, do they emerge naturally from the domain context or are they forced? Flag any that don't clearly add value.
5. **Overall balance**: Does the description provide enough direction for the loop to be productive, while leaving enough space for creative exploration across 100+ iterations?

For each gap found, suggest a specific improvement with concrete wording the user can accept or modify.

### Step 4: Quality Review & Follow-up

After applying changes or completing the initial review, check the description against quality criteria:

- Focus areas broad enough to sustain 100+ iterations without becoming repetitive?
- Only essential constraints included? (fewer = more creative freedom)
- Quality criteria concise and high-signal?
- Extra sections natural and valuable, not forced?
- Overall: enough direction to be productive, enough space for infinite exploration?

If critical gaps remain that you cannot reasonably resolve:
- Ask targeted follow-up questions (maximum 5 total across the session)
- Each question should have a clear default you'd use if the user doesn't answer
- Follow the "do the work, ask only if necessary" principle — most gaps should be resolvable without asking

### Step 5: Write & Report

Write the updated `<domain-path>/DESCRIPTION.md` with all improvements applied.

Summarize what was changed:
- List each modification made (added section, strengthened criteria, etc.)
- Explain why each change improves the description
- Note any remaining suggestions the user may want to consider in the future

If this was a full-quality review with no changes needed, inform the user that the description is already strong and explain why it meets quality criteria.
