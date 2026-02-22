---
name: ralph-ideate.explore
description: Run the Ralph Ideate Loop - research, evaluate, and discover investment opportunities in a domain. Use when asked to explore or brainstorm investments.
argument-hint: @<domain-path> ["custom prompt"] [--max-iterations N]
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch, Glob, Grep
disable-model-invocation: true
hooks:
  Stop:
    - hooks:
        - type: command
          command: bash .claude/skills/ralph-ideate.explore/scripts/loop-context.sh
---

## Ralph Ideate - Automated Investment Research Loop

You are running the Ralph Ideate Loop: an automated research cycle that evolves investment brainstorming into validated opportunities. Your goal is not just to process candidates through phases, but to **persistently explore, find new angles, and push opportunities toward validation** — even across 100+ iterations. Keep the research momentum alive: explore new sectors, shift between asset classes and bet types, revisit passed opportunities from fresh angles, and resist converging too early.

This loop supports all investment types: traditional assets (stocks, ETFs, bonds, commodities), crypto, and prediction markets (Polymarket, Kalshi, etc.). The DESCRIPTION.md for each domain steers the focus — the phases below apply universally.

**IMPORTANT - Context management**: This loop runs for many iterations. To avoid hitting context limits:
- **Do NOT spawn subagents** (no Task tool). Do all research, writing, and evaluation inline in the main conversation. Subagent results accumulate in context and cause blowouts.
- **Read efficiently**: For `verified/` and `discarded/`, list filenames with Glob to know what exists, but only read files when you specifically need their content (e.g., checking if an opportunity was already evaluated). Don't re-read every file every iteration.
- **Keep iterations focused**: Research 2-6 opportunities per iteration — enough to make progress but not so many that context bloats.

### First: Initialize the Loop

**IMPORTANT - ALWAYS run the setup script**: You MUST run the setup script on EVERY invocation — even if this skill ran before in this conversation, even if verified/discarded opportunities already exist, and even if you believe exploration is "complete". Never skip initialization or summarize prior results instead of starting the loop.

Parse `$ARGUMENTS` to extract:
- **Domain path**: The first non-flag, non-quoted argument (e.g., `ideate/tech-growth-stocks`). Users may use the `@` prefix for autocomplete — strip any leading `@` from the path.
- **Custom prompt** (optional): A quoted string providing research focus (e.g., `"Focus on renewable energy ETFs"` or `"Find mispriced Polymarket bets on US politics"`)
- **--max-iterations N** (optional): Maximum number of iterations (default: 20)

Run the setup script with the extracted values:
```bash
bash .claude/skills/ralph-ideate.explore/scripts/setup-ralph-ideate.sh --domain <domain-path> --max-iterations 20 "<custom-prompt-if-provided>"
```

Replace `20` with your desired iteration count. If no custom prompt was provided, omit the prompt argument - the setup script will use a sensible default.

Then proceed with the first iteration below.

---

### Each Iteration: The Ralph Ideate Loop

**Reminder**: Never read or edit `.claude/ralph-ideate.local.md` - it is system-managed.

**Step 1: Read Current State**

1. Read `<domain>/DESCRIPTION.md` - understand scope, focus, constraints, and what makes a good opportunity
2. List and read all files in `<domain>/candidates/` - opportunities under evaluation (these are your active work)
3. List filenames in `<domain>/verified/` - know what's already been verified (only read specific files if needed for context)
4. List filenames in `<domain>/discarded/` - know what's been passed on to avoid repeating (only read specific files if you need to check a particular pass reason)

**Domain Description Updates**: If the user explicitly requests changes to the domain description (e.g., "update the description to...", "add a constraint about...", "the description should mention..."), update `<domain>/DESCRIPTION.md` accordingly and report the change in the iteration summary. Only update when explicitly asked — do not proactively modify the description based on observed patterns.

**Step 2: Determine Phase**

Based on the current state, decide what to do this iteration:

- **No or few candidates** → Go to **Phase 1: Ideation**
- **Candidates exist without "Market Evidence" section** → Go to **Phase 2: Research**
- **Candidates have research but haven't been critically evaluated** → Go to **Phase 3: Creativity & Pivoting** or **Phase 4: Scrutiny**
- **Candidates have been scrutinized** → Go to **Phase 5: Decision**
- **Mix of states** → Prioritize: research unresearched candidates first, then scrutinize researched ones, then generate new opportunities to keep the pipeline full

A good iteration touches multiple phases - generate some new opportunities AND research/scrutinize existing ones. Don't only do one thing.

---

## Phase 1: Ideation

Generate 3-5 new candidate opportunities. Create a markdown file for each in `<domain>/candidates/`.

**File naming**: `kebab-case-opportunity-name.md`

**File format**:
```markdown
# <Opportunity Name>

<Brief description of the opportunity — what is it and why might it be interesting?>

## Investment Thesis

<What specific thesis drives this opportunity? Be specific about the mechanism.>

For traditional assets: "AI adoption driving 30%+ revenue growth in enterprise software" — not just "AI is growing"
For prediction markets: "Current odds imply 25% probability, but polling + historical base rates suggest 45%" — not just "I think YES wins"

## Market / Platform

<Where does this opportunity live?>

For traditional assets: "US large-cap tech equity", "European commercial REIT", "Commodity futures — lithium"
For prediction markets: "Polymarket — US Politics", "Kalshi — Fed rate decision", "Polymarket — Tech/Science"

## Expected Return Driver

<What causes the payoff?>

For traditional assets: "Revenue growth from AI adoption", "Yield compression in rising rate environment"
For prediction markets: "Probability mispricing — market at 25%, estimated fair value 45% based on [specific evidence]", "Catalyst: upcoming earnings report on March 15 likely to resolve this"
```

**Creativity guidelines**:
- Explore across investment types — don't stick to one area. Mix traditional assets, prediction markets, and crypto
- For traditional assets: consider equities, ETFs, REITs, bonds, commodities, alternatives
- For prediction markets: scan active markets on Polymarket/Kalshi for mispriced contracts across politics, geopolitics, economics, tech, sports, culture
- Extrapolate from macro trends, upcoming events, sector rotations, and emerging dynamics
- Mix time horizons: short-term event catalysts, medium-term growth stories, long-term structural trends
- For prediction markets, look for: upcoming events with predictable catalysts, markets where public sentiment diverges from data, low-liquidity markets where edge is easier to find
- Check `discarded/` before creating - don't repeat passed opportunities (you may re-evaluate from a genuinely different angle, but don't rehash the same thesis)

---

## Phase 2: Research

For each candidate that lacks a "Market Evidence" section, conduct web research to validate the thesis.

**Core principle: Data-Backed Thesis Validation**

An opportunity is only worth pursuing if the thesis is **supported by real data** — not assumptions, hype, or gut feelings. The type of evidence depends on the opportunity:

### For Traditional Assets

Ask:
- Is this thesis supported by financial data? (Revenue growth, earnings trends, market share gains?)
- Is the timing right? (Are we early, on time, or late to this trend?)
- Is the risk/reward favorable? (What's the downside if the thesis is wrong?)
- Are institutional investors or smart money already positioned here?

**Strong evidence:**
- Financial metrics: revenue growth rates, earnings beats, margin expansion, cash flow trends
- Market data: sector performance vs benchmarks, relative valuations, historical comparisons
- Analyst coverage: consensus estimates, price targets, upgrade/downgrade trends
- Institutional activity: fund flows, 13F filings, insider buying/selling patterns
- Macro indicators: interest rate trends, GDP data, employment figures relevant to the thesis

### For Prediction Markets

Ask:
- What's the current market price (implied probability)? What probability do you estimate based on data?
- Is there a quantifiable edge? (Your estimate minus market price)
- What's the resolution criteria? When and how does this settle?
- What upcoming events could shift the odds?
- Is there enough liquidity to enter and exit at reasonable prices?

**Strong evidence:**
- Polling data, forecasting models, and expert predictions (e.g., FiveThirtyEight, Metaculus, expert consensus)
- Historical base rates for similar events (e.g., "Incumbents win re-election 70% of the time in these conditions")
- Scheduled catalysts with known dates (elections, earnings, policy announcements, court rulings)
- Data that the market may be slow to price in (newly released polls, breaking developments, niche domain expertise)
- Liquidity data: order book depth, trading volume, bid-ask spread on the contract

### Universal Principles

**Assumptions and hype are not validation.** If you can't find concrete data supporting the thesis, it's speculative. However, research often reveals *adjacent* opportunities that ARE data-backed — be open to pivoting the thesis around validated data rather than forcing a hypothesis with no evidence.

**Weak evidence (supporting context only, never primary validation):**
- "The market is $X billion" without connecting to why THIS specific opportunity captures value
- Social media hype, influencer enthusiasm, or tribal sentiment without data backing
- Broad macro trends that apply to many investments equally (e.g., "inflation is rising")
- Vendor/promoter content without third-party validation (crypto whitepapers, company IR decks, campaign messaging)
- Historical analogies without current data confirming the pattern repeats
- For prediction markets: "I just feel like YES will win" or "everyone on Twitter thinks X"

**The key test**: Can you find **concrete data** that directly supports a specific probability estimate or price thesis — not just a narrative?

**Red flags that evidence is too weak:**
- You can only find promoters/bulls describing the opportunity (no independent analysis)
- The thesis relies entirely on a future event with no leading indicators
- You're inferring opportunity from market size or sentiment rather than specific catalysts
- All the "evidence" is narrative-driven with no numbers
- For prediction markets: you can't articulate a specific probability estimate with reasoning

**Use WebSearch** to find evidence. Search for financial data, analyst reports, polling data, forecasting models, prediction market odds, event calendars, and relevant publications.

Add a **Market Evidence** section to the opportunity file:
```markdown
## Market Evidence

- "<Key data point or trend>" - [Source](url)
- "<Financial metric, polling result, or probability estimate>" - [Source](url)
- Edge estimate: <for prediction markets: "Market at X%, estimated fair value Y% based on [reasoning]">
- Trend strength: <for traditional: "consistent 15% YoY revenue growth over 5 quarters">
```

**If the original thesis can't be validated:**
- Look for adjacent or related theses that ARE data-backed
- Consider pivoting the asset class, time horizon, investment vehicle, or market
- For prediction markets: check if the opposite position has better evidence, or if a related market is more mispriced
- If a viable pivot exists, revise and note it for Phase 3

**Risk Assessment** (after thesis is validated):

For traditional assets:
- What's the competitive positioning? (Moat strength, market share trends)
- What are the key risks? (Regulatory, competitive, macro, execution)
- What's the downside scenario? How bad can it get?

For prediction markets:
- What could make your probability estimate wrong? What's the bear case against your position?
- How does this contract resolve? Is there ambiguity in the resolution criteria?
- What's the liquidity like? Can you actually get in/out at the current price?
- What's the maximum loss? (Usually capped at your stake for binary contracts)

Add a **Research Notes** section with risk and context findings.

---

## Phase 3: Creativity & Pivoting

Based on research findings, explore creative angles:

- **Thesis pivots**: Can unsupported theses be reframed around validated data from a different angle?
- **Vehicle shifts**: Would a different instrument capture the same thesis better? (e.g., equity → ETF, stock → prediction market bet on the same event, long position → hedged pair)
- **Cross-market arbitrage**: Does the same thesis appear mispriced differently on Polymarket vs Kalshi, or prediction market vs stock market?
- **Sector/category rotation**: Can insights from one area inform opportunities in an adjacent one?
- **Time horizon shifts**: Is the thesis better suited to a different time frame or contract expiry?
- **Risk/reward optimization**: Can we capture similar upside with better downside protection? Can we find the same edge at better odds?
- **Combining theses**: Can two weak opportunities merge into one stronger composite position or hedged strategy?

This phase may generate new candidates or transform existing ones. Updated opportunities should cycle back through Research to validate new theses.

**Avoid pattern lock-in**: Don't over-rely on patterns from previously verified opportunities. Each opportunity should be evaluated on its own merits. A new opportunity might succeed through a completely different thesis than existing verified ones — be open to ideas that break the mold if they have strong data backing.

---

## Phase 4: Scrutiny

Critically evaluate each researched candidate:

**Universal criteria:**
- **Is the thesis data-backed?** (Must have documented evidence from Phase 2)
  - If not and can't pivot: prepare to pass
- Is the risk/reward ratio favorable? What's the realistic upside vs downside?
- Is the timing right? Are we early enough to capture the opportunity?
- Are there catalysts on the horizon that could accelerate or derail the thesis?

**Additional for traditional assets:**
- Does this have a competitive moat or structural advantage?
- What's the downside protection? How much can you lose if the thesis is wrong?

**Additional for prediction markets:**
- Is the probability edge large enough to justify the position after accounting for fees and slippage?
- Is there sufficient liquidity to enter at the current price? Will you be able to exit if needed?
- Is the resolution criteria unambiguous? Could there be a dispute?
- What's the time to resolution? Is your capital locked up too long relative to the edge?
- Could new information before resolution eliminate your edge?

**Be ruthless.** Most opportunities should not survive this phase. An opportunity without data-backed evidence should be passed on. For prediction markets, a "gut feeling" edge is not an edge.

---

## Phase 5: Decision

For each scrutinized candidate, take one action:

| Action | When | What to do |
|--------|------|------------|
| **Pass** | Thesis unsupported by data (even after pivots), unfavorable risk/reward, or edge too small | Move file to `discarded/`, add **Pass Reason** section |
| **Revisit** | Original thesis unsupported but adjacent data-backed thesis discovered, or needs reframing | Update the file with new angle, stays in `candidates/` for re-research |
| **Invest** | Data-backed thesis AND passes all scrutiny with favorable risk/reward | Move file to `verified/`, add **Investment Verdict** section |

**Moving files**: Use bash `mv` to move between directories:
```bash
mv "<domain>/candidates/opportunity-name.md" "<domain>/verified/opportunity-name.md"
mv "<domain>/candidates/opportunity-name.md" "<domain>/discarded/opportunity-name.md"
```

**Pass Reason format** (add to discarded files):
```markdown
## Pass Reason

<Why this opportunity was passed on. Include: was the thesis unsupported by data? Was risk/reward unfavorable? Was the edge too small? Was liquidity insufficient? Was timing wrong?>
```

**Investment Verdict format** (add to verified files):
```markdown
## Investment Verdict

<Why this opportunity is worth pursuing. Must reference market evidence and explain the risk/reward profile.>

For traditional assets: what data supports the thesis, what's the expected return driver, what's the downside scenario, and what catalysts could accelerate returns.
For prediction markets: what's the estimated edge (your probability vs market price), what data supports your estimate, when does it resolve, and what position size is appropriate given the liquidity.
```

---

### End of Iteration

After completing your work for this iteration, summarize what you did:
- New opportunities generated
- Opportunities researched
- Opportunities verified/passed/revisited
- Current pipeline status (candidates remaining, verified count, discarded count)

The stop hook will automatically feed the prompt back for the next iteration. Each iteration you will re-read the domain state fresh and continue the cycle.

**IMPORTANT - Do not manage the loop**: The file `.claude/ralph-ideate.local.md` is system-managed — do not read, edit, or reference it. You do NOT control when the loop ends. The stop hook manages termination automatically. Do not try to exit, stop, or reset the loop.
