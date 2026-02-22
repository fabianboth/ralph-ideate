---
name: ralph-ideate.create
description: Create a new investment brainstorming domain from a description - synthesizes DESCRIPTION.md with quality review.
argument-hint: [describe your investment brainstorming domain]
allowed-tools: Write, Edit, Bash(mkdir *), Bash(ls *), Bash(touch *), Glob
---

## Create a New Investment Brainstorming Domain

You are creating a new brainstorming domain for the Ralph Ideate system focused on investment opportunities. Your job is to take a rough description from the user and synthesize a high-quality domain with a comprehensive DESCRIPTION.md that can guide infinite investment exploration.

Follow the "do the work, ask only if necessary" pattern: synthesize the best possible result from the input. Only ask the user a question if there is a critical gap that cannot be reasonably defaulted.

### Step 1: Parse Input

The user provided: `$ARGUMENTS`

- **If empty**: Ask the user to describe what they want to explore. Example prompt: *"What investment space do you want to explore? Describe the asset classes, sectors, strategies, or themes you're interested in."*
- **If provided**: Treat the entire input as a free-form description of the investment brainstorming domain. Do NOT treat it as a domain name.

### Step 2: Synthesize Domain Description

**Less is more**: This description guides an infinite exploration loop (100+ iterations). Each section should provide just enough direction to be useful — a few high-signal bullet points beat an exhaustive list. Over-specifying constraints, criteria, or anti-patterns narrows the creative space and causes repetitive ideas. When in doubt, leave it out.

From the user's description, extract and synthesize:

1. **Domain title**: A clear, human-readable title for this investment exploration space
2. **One-line summary**: A concise description of what this domain covers
3. **Focus areas**: Key areas to explore — broad enough to sustain infinite exploration, specific enough to provide direction. Aim for 3-5 areas that open up many angles. Think across: asset classes, sectors, geographies, strategies, time horizons, and investment vehicles.
4. **Constraints**: Only hard boundaries that truly matter (if the user didn't mention any, note "None stated — explore freely"). Examples: risk tolerance limits, excluded asset classes, regulatory boundaries, minimum liquidity requirements. Fewer constraints = more creative freedom.
5. **Quality criteria**: A few key signals that distinguish strong investment opportunities from weak ones — not an exhaustive checklist. Focus on: thesis clarity, data availability, risk/reward profile, and timing.
6. **Additional domain-specific sections** (optional): If the domain has a defining characteristic that deserves its own section, add it naturally. For example, a "crypto DeFi" domain might add a "Red Flags for DeFi Investments" section. Don't force extra sections — only add them when they emerge naturally from the domain context.

**Auto-generate a domain name**: Extract 2-4 key terms from the description and compose a kebab-case identifier (e.g., `tech-growth-stocks`, `real-estate-reits`, `crypto-defi`, `dividend-income`). Keep it under ~40 characters.

**Check for conflicts**: Use Glob to check if `ideate/<domain-name>/` already exists. If it does, propose an alternative name or ask the user to confirm.

### Step 3: Quality Self-Review

Before writing, review your synthesized description against these criteria:

- **Focus breadth**: Are focus areas broad enough to sustain 100+ iterations without becoming repetitive? Do they span multiple asset classes, strategies, or time horizons to open up diverse investment angles?
- **Constraint minimalism**: Are there only hard boundaries that truly matter? Too many constraints kill creativity — remove any that are "nice to have" rather than essential.
- **Criteria clarity**: Do the quality criteria give a clear signal for what's strong vs weak? Are they concise enough to be useful without being an exhaustive checklist?
- **Extra sections**: If you added domain-specific sections, do they emerge naturally from the domain or are they forced? Remove anything that doesn't clearly add value.

If any gaps are found, strengthen the description before proceeding. If a critical gap exists that you genuinely cannot resolve from context (rare), ask the user ONE focused question.

### Step 4: Create Directory Structure

```bash
mkdir -p ideate/<domain-name>/candidates
mkdir -p ideate/<domain-name>/verified
mkdir -p ideate/<domain-name>/discarded
touch ideate/<domain-name>/candidates/.gitkeep
touch ideate/<domain-name>/verified/.gitkeep
touch ideate/<domain-name>/discarded/.gitkeep
```

### Step 5: Write DESCRIPTION.md

Write `ideate/<domain-name>/DESCRIPTION.md` following this format:

```markdown
# <Domain Title (Human-Readable)>

<Brief one-line description of the investment exploration space.>

## Focus

- <Investment sector, asset class, or strategy to explore>
- <Geographic or market focus>
- <Additional focus points as needed>

## Constraints

- <Risk tolerance, investment horizon, or regulatory constraint>
- <Additional constraints as needed>

## What Makes a Good Opportunity

- <Strong, specific thesis backed by data — not vague trends>
- <Favorable risk/reward with clear downside protection>
- <Additional investment quality signals as needed>

## <Optional: Domain-Specific Section>
(Only if a defining characteristic of this domain deserves its own section — e.g., "Red Flags for DeFi Investments" or "Key Macro Indicators to Watch". Omit if nothing emerges naturally.)
```

The three core sections (Focus, Constraints, What Makes a Good Opportunity) are always required. Additional sections should only appear when they emerge naturally from the domain context — don't force them.

Be concise — this file guides infinite investment exploration. Less is more.

### Step 6: Confirm

Tell the user the domain has been created and show the structure:
- `ideate/<domain-name>/DESCRIPTION.md`
- `ideate/<domain-name>/candidates/` (empty — ready for opportunities)
- `ideate/<domain-name>/verified/` (empty)
- `ideate/<domain-name>/discarded/` (empty)

Show the generated DESCRIPTION.md content so the user can review it.

Output these next steps verbatim at the end:
```text
Next steps:
- /ralph-ideate.explore @ideate/<domain-name>
- /ralph-ideate.refine @ideate/<domain-name>
```
