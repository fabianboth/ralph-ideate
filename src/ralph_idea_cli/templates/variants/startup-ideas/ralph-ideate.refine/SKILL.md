---
name: ralph-ideate.refine
description: Refine and improve a brainstorming domain description. Reviews quality and applies targeted improvements.
argument-hint: @<domain-path> [refinement instructions]
allowed-tools: Read, Write, Edit, Glob, Grep
---

## Refine a Brainstorming Domain Description

You are refining the DESCRIPTION.md of an existing Ralph Ideate brainstorming domain. Your job is to improve the domain description — either by applying specific changes the user requested, discussing the domain, or performing a full quality review.

For **specific instructions**, apply changes directly. For **open-ended input or quality reviews**, present your findings and use clarification questions to align with the user before making changes.

### Step 1: Parse Input

The user provided: `$ARGUMENTS`

- **If empty (no arguments at all)**: List available domains under `ideate/` using Glob to find all `ideate/*/DESCRIPTION.md` files. Show the list and ask the user to pick one.
- **If domain path only** (e.g., `ideate/my-domain`): Perform a full quality review of that domain's description.
- **If domain path + user input** (e.g., `ideate/my-domain add anti-patterns for partial automation` or `ideate/my-domain why are we discarding all ideas`): Address the user's input in the steps below.

Extract:
- **Domain path**: The first argument that looks like a path (contains `/` or starts with `ideate/`). Users may use the `@` prefix for autocomplete — strip any leading `@` from the path.
- **User input**: Everything after the domain path (may be empty)

### Step 2: Read Current State

Read `<domain-path>/DESCRIPTION.md`.

If the file does not exist, inform the user and suggest they create the domain first with `/ralph-ideate.create`.

If the user asked a question, raised a discussion topic, or provided open-ended input, also read the domain state (list files in `candidates/`, `verified/`, `discarded/` and read relevant files) to understand the current situation.

### Step 3: Apply Changes

If the user provided **specific, direct instructions** (e.g., "add a constraint about B2B focus", "remove the anti-patterns section"), apply them now. This might include:
- Adding new sections (e.g., anti-patterns, additional focus areas)
- Modifying existing criteria or constraints
- Strengthening weak areas
- Adding specificity to vague descriptions
- Removing or updating outdated guidance

If the input is open-ended, a question, or no input was provided, skip this step.

### Step 4: Quality Review

**Less is more**: This description guides an infinite exploration loop (100+ iterations). Each section should have just enough direction to be useful — a few high-signal bullet points beat an exhaustive list. Over-specifying narrows the creative space and causes repetitive ideas.

Check the description against these quality criteria:

1. **Focus breadth**: Are focus areas broad enough to sustain 100+ iterations without becoming repetitive? Do they open up diverse angles rather than funneling into a narrow set?
2. **Constraint minimalism**: Are there only hard boundaries that truly matter? Too many constraints kill creativity — flag any that are "nice to have" rather than essential.
3. **Criteria clarity**: Do the quality criteria give a clear signal for strong vs weak ideas without being an exhaustive checklist?
4. **Extra sections**: If domain-specific sections exist, do they emerge naturally from the domain context or are they forced? Flag any that don't clearly add value.
5. **Overall balance**: Does the description provide enough direction for the loop to be productive, while leaving enough space for creative exploration across 100+ iterations?

If the user asked a question or raised a discussion topic, factor it into the review. For example, if they ask "why are we discarding all ideas", consider whether the description's constraints are too narrow or the quality criteria too strict.

**For open-ended input or quality reviews**: Present your findings and observations to the user before making changes. Do not apply improvements unilaterally — use Step 5 to align on what to change.

### Step 5: Clarify

Use interactive clarification questions to align with the user (maximum 5 total across the session):

- Present **one question at a time** — never reveal upcoming questions.
- For multiple-choice questions (2-4 options):
  - Analyze all options and determine the **most suitable option** based on best practices, creative breadth, and alignment with the domain context.
  - Present your **recommended option prominently**: `**Recommended:** Option [X] - <reasoning>`
  - Then render all options as a Markdown table.
  - Add: `Reply with the option letter, accept the recommendation by saying "yes", or provide your own short answer.`
- For short-answer questions:
  - Provide your **suggested answer**: `**Suggested:** <your proposed answer> - <brief reasoning>`
  - Add: `Accept the suggestion by saying "yes", or provide your own answer.`
- After each accepted answer, apply the clarification to the description immediately.
- Stop asking when: all gaps are resolved, the user signals completion ("done", "good"), or you reach 5 questions.

### Step 6: Write & Report

Write the updated `<domain-path>/DESCRIPTION.md` with all improvements applied.

Summarize what was changed:
- List each modification made (added section, strengthened criteria, etc.)
- Explain why each change improves the description
- If the user asked a question, answer it here with context from the domain state and quality review
- Note any remaining suggestions the user may want to consider in the future

If this was a full-quality review with no changes needed, inform the user that the description is already strong and explain why it meets quality criteria.

Output this next step verbatim at the end:
```
Next step:
- /ralph-ideate.explore @<domain-path>
```
