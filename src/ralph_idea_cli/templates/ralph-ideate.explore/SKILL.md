---
name: ralph-ideate.explore
description: Run the Ralph Ideate Loop - brainstorm, research, and evaluate ideas in a domain. Use when asked to explore or brainstorm ideas.
argument-hint: @<domain-path> ["custom prompt"] [--max-iterations N]
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch, Glob, Grep
disable-model-invocation: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: bash .claude/skills/ralph-ideate.explore/scripts/loop-context.sh
---

## Ralph Ideate - Automated Brainstorming Loop

You are running the Ralph Ideate Loop: an automated brainstorming cycle that evolves idea brainstorming into valid business opportunities. Your goal is not just to process candidates through phases, but to **persistently explore, find new angles, and push ideas toward viability** — even across 100+ iterations. Keep the creative momentum alive: explore new sectors, shift focus occasionally, revive discarded angles from fresh perspectives, and resist converging too early.

**IMPORTANT - Do not touch the state file**: The file `.claude/ralph-ideate.local.md` is managed exclusively by the bash scripts. You MUST NOT read, edit, or reference this file. The stop hook handles loop iteration and prompt replay automatically.

**IMPORTANT - Context management**: This loop runs for many iterations. To avoid hitting context limits:
- **Do NOT spawn subagents** (no Task tool). Do all research, writing, and evaluation inline in the main conversation. Subagent results accumulate in context and cause blowouts.
- **Read efficiently**: For `verified/` and `discarded/`, list filenames with Glob to know what exists, but only read files when you specifically need their content (e.g., checking if an idea was already tried). Don't re-read every file every iteration.
- **Keep iterations focused**: Research 2-6 ideas per iteration — enough to make progress but not so many that context bloats.

### First: Initialize the Loop

Parse `$ARGUMENTS` to extract:
- **Domain path**: The first non-flag, non-quoted argument (e.g., `ideate/saas-tools`). Users may use the `@` prefix for autocomplete — strip any leading `@` from the path.
- **Custom prompt** (optional): A quoted string providing brainstorming focus (e.g., `"Focus on B2B developer tools"`)
- **--max-iterations N** (optional): Maximum number of iterations (default: 10)

Run the setup script with the extracted values:
```bash
bash .claude/skills/ralph-ideate.explore/scripts/setup-ralph-ideate.sh --domain <domain-path> --max-iterations <N-or-10> "<custom-prompt-if-provided>"
```

If no custom prompt was provided, omit the prompt argument - the setup script will use a sensible default.

Then proceed with the first iteration below.

---

### Each Iteration: The Ralph Ideate Loop

**Reminder**: Never read or edit `.claude/ralph-ideate.local.md` - it is system-managed.

**Step 1: Read Current State**

1. Read `<domain>/DESCRIPTION.md` - understand scope, focus, constraints, and what makes a good opportunity
2. List and read all files in `<domain>/candidates/` - ideas under evaluation (these are your active work)
3. List filenames in `<domain>/verified/` - know what's already been verified (only read specific files if needed for context)
4. List filenames in `<domain>/discarded/` - know what's been rejected to avoid repeating (only read specific files if you need to check a particular rejection reason)

**Domain Description Updates**: If the user explicitly requests changes to the domain description (e.g., "update the description to...", "add a constraint about...", "the description should mention..."), update `<domain>/DESCRIPTION.md` accordingly and report the change in the iteration summary. Only update when explicitly asked — do not proactively modify the description based on observed patterns.

**Step 2: Determine Phase**

Based on the current state, decide what to do this iteration:

- **No or few candidates** → Go to **Phase 1: Ideation**
- **Candidates exist without "Pain Point Evidence" section** → Go to **Phase 2: Research**
- **Candidates have research but haven't been critically evaluated** → Go to **Phase 3: Creativity & Pivoting** or **Phase 4: Scrutiny**
- **Candidates have been scrutinized** → Go to **Phase 5: Decision**
- **Mix of states** → Prioritize: research unresearched candidates first, then scrutinize researched ones, then generate new ideas to keep the pipeline full

A good iteration touches multiple phases - generate some new ideas AND research/scrutinize existing ones. Don't only do one thing.

---

## Phase 1: Ideation

Generate 3-5 new candidate ideas. Create a markdown file for each in `<domain>/candidates/`.

**File naming**: `kebab-case-idea-name.md`

**File format**:
```markdown
# <Idea Name>

<Brief description of the core concept - what does this do?>

## Hypothesized Pain Point

<What specific problem does this solve? Who experiences it? Be specific.>

## Target Market

<Who are the customers? B2B/B2C? Industry? Size?>
```

**Creativity guidelines**:
- Explore new sectors, interpolate between existing ideas, try new angles
- Extrapolate to adjacent markets and near-term trends
- Avoid iterating on the same idea space - use creative techniques to think outside the box
- Check `discarded/` before creating - don't repeat rejected ideas (you may re-evaluate from a genuinely different angle, but don't rehash the same concept)

---

## Phase 2: Research

For each candidate that lacks a "Pain Point Evidence" section, conduct web research to validate the pain point.

**Core principle: Verified Pain Points First**

An idea is only valuable if it solves a real pain point - and "real" means **verified through research**, not assumed. Ask:
- Is this pain point verified? (Evidence of real people experiencing this?)
- Is it urgent? (Do they need it solved now?)
- Is it frequent? (Happens often enough to matter?)
- Are people already paying to solve it?

**Strong evidence (prioritize these):**
- Forum complaints, Reddit threads, or community discussions where people describe the problem *in their own words*
- App store reviews mentioning frustration with existing solutions or gaps
- Negative reviews of competitors that highlight unmet needs
- Social media posts, tweets, or LinkedIn discussions about the struggle
- Job postings that hint at manual workarounds or inefficiencies

**Gut feelings and assumptions are not validation.** If you can't find real people complaining about this problem, the pain point is hypothetical. However, research often reveals *adjacent* pain points that ARE real — be open to rescoping around verified problems rather than forcing a hypothesis with no evidence.

**Weak evidence (supporting context only, never primary validation):**
- Statistics that describe a condition but don't connect to the solution (e.g., "X million people have depression" does NOT validate demand for a depression chatbot)
- Broad statistics that apply to many categories equally (e.g., "businesses waste time on admin")
- "The market is $X billion" does NOT validate an opportunity — big markets have big competition
- Industry reports without user voice — numbers don't prove people *want* your solution
- Consultant/vendor marketing content describing problems (they have incentive to inflate pain)

**The key test**: Can you find **actual people** (not vendors, not consultants) **in their own words** describing this specific frustration?

**Red flags that evidence is too weak:**
- You can only find vendors describing the problem (not customers)
- Statistics are so broad they'd apply to any solution
- You're inferring pain from market size rather than user complaints

**Use WebSearch** to find evidence. Search for Reddit threads, forum posts, review sites, social media discussions related to the pain point.

Add a **Pain Point Evidence** section to the idea file:
```markdown
## Pain Point Evidence

- "<Direct quote or paraphrased complaint>" - [Source](url)
- "<Another user complaint>" - [Source](url)
- Volume: <indicator, e.g., "50+ Reddit threads", "common 1-star review theme">
```

**If the original pain point can't be verified:**
- Look for adjacent or related pain points that ARE real
- Consider rescoping the idea around a verified pain point
- If a viable pivot exists, revise and note it for Phase 3

**Competitive Landscape** (after pain point is validated):
- Does something similar already exist?
- What's the competitive landscape?
- Are there failed attempts? Why did they fail?
- **If competitors exist, try harder**: Competition validates demand but doesn't automatically disqualify an idea. Look for underserved segments, unmet needs, or gaps. Try different angles — different perspectives, business models, niches. But any differentiation must be validated with research, not assumed.

Add a **Research Notes** section with competitive findings.

---

## Phase 3: Creativity & Pivoting

Based on research findings, explore creative angles:

- **Pain point pivots**: Can unverified ideas be reframed around a related REAL pain point?
- **Better solutions**: Can verified pain points be solved in a fundamentally better way?
- **Scope shifts**: Should we narrow (niche) or expand (platform)?
- **Gap bridging**: Are there underserved segments or unmet needs?
- **Business model innovation**: Could a different model create an advantage?
- **Combining ideas**: Can two weak ideas merge into one strong one?

This phase may generate new candidates or transform existing ones. Updated ideas should cycle back through Research to validate new hypotheses.

**Avoid pattern lock-in**: Don't over-rely on patterns from previously verified ideas. Each idea should be evaluated on its own merits. Past successes (or failures) are useful heuristics but shouldn't constrain creative exploration. A new idea might succeed through a completely different model than existing verified ideas — be open to ideas that break the mold if they have strong pain point evidence.

---

## Phase 4: Scrutiny

Critically evaluate each researched candidate:

- **Is the pain point verified?** (Must have documented evidence from Phase 2)
  - If not and can't pivot: prepare to discard
- Is the problem significant enough to pay for?
- Is the proposed solution viable?
- What are the major risks and blockers?
- Does this differentiate from existing solutions?

**Be ruthless.** Most ideas should not survive this phase. An idea without a verified pain point should be discarded.

---

## Phase 5: Decision

For each scrutinized candidate, take one action:

| Action | When | What to do |
|--------|------|------------|
| **Discard** | No verifiable pain point (even after pivots), fundamentally flawed, or solution already exists well | Move file to `discarded/`, add **Rejection Reason** section |
| **Revise** | Original pain point unverified but adjacent pain point discovered, or needs refinement | Update the file with new angle, stays in `candidates/` for re-research |
| **Verify** | Verified pain point AND passes all scrutiny | Move file to `verified/`, add **Verdict** section |

**Moving files**: Use bash `mv` to move between directories:
```bash
mv "<domain>/candidates/idea-name.md" "<domain>/verified/idea-name.md"
mv "<domain>/candidates/idea-name.md" "<domain>/discarded/idea-name.md"
```

**Rejection Reason format** (add to discarded files):
```markdown
## Rejection Reason

<Why this idea was rejected. Include: was the pain point unverified? Was the solution unviable? Did competitors already solve it?>
```

**Verdict format** (add to verified files):
```markdown
## Verdict

<Why this idea is worth pursuing. Must reference verified pain point evidence and explain differentiation.>
```

---

### End of Iteration

After completing your work for this iteration, summarize what you did:
- New ideas generated
- Ideas researched
- Ideas verified/discarded/revised
- Current pipeline status (candidates remaining, verified count, discarded count)

The stop hook will automatically feed the prompt back for the next iteration. Each iteration you will re-read the domain state fresh and continue the cycle.
