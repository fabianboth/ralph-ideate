<div align="center">
    <img src="https://raw.githubusercontent.com/fabianboth/ralph-ideate/main/assets/ralph_loop.webp" alt="Ralph Ideate" width="450"/>
    <h1>Ralph Ideate: The Idea Machine</h1>
</div>

<p align="center">
    <strong><code>ralph-ideate</code> is an autonomous AI agent loop that ideates, extends, researches, scrutinizes, and repeats. It is the ralph loop for brainstorming: business ideas, investment opportunities, prediction market bets, and more.</strong>
</p>

<p align="center">
    <a href="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml"><img src="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml/badge.svg" alt="CI"/></a>
    <a href="https://pypi.org/project/ralph-ideate/"><img src="https://img.shields.io/pypi/v/ralph-ideate?style=flat" alt="PyPI version"/></a>
    <a href="https://github.com/fabianboth/ralph-ideate/blob/main/LICENSE"><img src="https://img.shields.io/github/license/fabianboth/ralph-ideate" alt="License"/></a>
</p>

---

## Why Automate Ideation?

Most ideas start as hunches and die as forgotten notes. The gap between "that could work" and "here's why it does" is filled with research, critical evaluation, and iteration. Work that's tedious to do systematically by hand.

Ralph Ideate closes that gap. You define a domain to explore, and an AI loop takes over: generating candidates, researching evidence, scrutinizing viability, and deciding what survives. Each iteration builds on the last. You steer the direction; the loop does the legwork.

## Installation

```bash
uv tool install ralph-ideate
```

```bash
ralph-ideate init
```

During init you choose a brainstorming variant:

| Variant | Focus |
|---------|-------|
| **Startup Ideas** | Business ideas validated through pain point research |
| **Investment** | Investment opportunities, prediction market bets (Polymarket/Kalshi), stocks, crypto; validated through data analysis |

## Getting Started

All commands are Claude Code slash commands. You create a brainstorming domain under `ideate/`, explore it with the loop, and refine the domain description as you learn more.

### 1. Create a brainstorming domain

```text
/ralph-ideate.create B2B services that agentic AI can fully automate end-to-end
```

Or for investments:

```text
/ralph-ideate.create Mispriced Polymarket bets on US politics and tech events
```

### 2. Explore ideas

```text
/ralph-ideate.explore @ideate/<your_idea_folder>
```

### 3. Refine a domain description

```text
/ralph-ideate.refine @ideate/<your_idea_folder>
```

## How It Works

Each iteration reads the domain state fresh and decides which phase to execute:

1. **Ideate** - Generate and capture new candidate ideas
2. **Research** - Validate ideas with real-world evidence
3. **Scrutinize** - Critically evaluate viability and differentiation
4. **Decide** - Verify, revise, or discard each candidate

### Features

- **Systematic exploration:** Covers ground broadly rather than pursuing singular solutions
- **Interactive steering:** Inject thoughts and feedback during active processing to redirect focus
- **Evidence-based validation:** Ideas must survive research with real data, not assumptions
- **Multi-pass refinement:** Each iteration deepens understanding rather than forcing premature convergence

## Acknowledgments

Inspired by [Ralph Loop](https://github.com/snarktank/ralph) and [Spec Kit](https://github.com/github/spec-kit). Read more about the motivation in the [idea machine blog post](https://fabianboth.dev/blog/idea-machine/).

## Documentation

For full documentation, troubleshooting, and advanced usage, visit the [GitHub repository](https://github.com/fabianboth/ralph-ideate).
