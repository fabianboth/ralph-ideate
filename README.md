<div align="center">
    <img src="https://raw.githubusercontent.com/fabianboth/ralph-ideate/main/assets/ralph_loop.webp" alt="Ralph Ideate" width="450"/>
    <h1>Ralph Ideate</h1>
    <h3><em>The Business Idea Machine</em></h3>
</div>

<p align="center">
    <strong><code>ralph-ideate</code> is an autonomous AI agent loop that ideates, extends, researches, scrutinizes, and repeats. It is the ralph loop for business ideas.</strong>
</p>

<p align="center">
    <a href="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml"><img src="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml/badge.svg" alt="CI"/></a>
    <a href="https://pypi.org/project/ralph-ideate/"><img src="https://img.shields.io/pypi/v/ralph-ideate?style=flat" alt="PyPI version"/></a>
    <a href="https://github.com/fabianboth/ralph-ideate/blob/main/LICENSE"><img src="https://img.shields.io/github/license/fabianboth/ralph-ideate" alt="License"/></a>
</p>

---

## Prerequisites

- [Python](https://www.python.org/) 3.12+
- [Claude Code](https://claude.ai/download), the AI coding agent that runs the skills
- [jq](https://jqlang.org/), for JSON parsing within bash

## Installation

```bash
uv tool install ralph-ideate
```

```bash
ralph-ideate init
```

This installs the skill files into `.claude/skills/` so Claude Code can discover them.

## Getting Started

### 1. Create a brainstorming domain

```text
/ralph-ideate.create B2B services that agentic AI can fully automate end-to-end
```

Describe what you want to brainstorm about. A domain name and `DESCRIPTION.md` are generated automatically.

### 2. Explore ideas

```text
/ralph-ideate.explore @ideate/agentic-ai-agencies
```

Starts the Ralph Ideate Loop. It generates candidates, researches pain points, evaluates viability, and moves ideas to `verified/` or `discarded/`.

### 3. Refine a domain description

```text
/ralph-ideate.refine @ideate/agentic-ai-agencies
```

Refine or discuss the search domain's `DESCRIPTION.md` with new insights (e.g. `should we focus more on B2B or B2C?`).

## Advanced Usage

### Explore options

```text
/ralph-ideate.explore @ideate/agentic-ai-agencies "Focus on B2B pain points" --max-iterations 20
```

| Option | Default | Description |
|--------|---------|-------------|
| `"custom prompt"` | auto-generated | Focus the brainstorming on a specific angle |
| `--max-iterations N` | `20` | Auto-stop after N iterations  |

You can simply write steering feedback or thoughts while iterations are ongoing and it will be picked up.

### Refine with inline edits

```text
/ralph-ideate.refine @ideate/agentic-ai-agencies add a constraint about B2B focus
```

Without arguments, runs a full quality review. With arguments, applies targeted changes.

## How It Works

Each iteration reads the domain state fresh and decides which phase to execute:

1. **Ideate** - Generate and capture new candidate ideas
2. **Research** - Validate pain points with real-world evidence
3. **Scrutinize** - Critically evaluate viability and differentiation
4. **Decide** - Verify, revise, or discard each candidate

Ideas progress through a structured pipeline:

```
ideate/<domain>/
├── DESCRIPTION.md    # Scope, focus, constraints
├── candidates/       # Ideas under evaluation
├── verified/         # Ideas that passed scrutiny
└── discarded/        # Rejected ideas with reasoning
```

## Features

- **Systematic exploration:** Covers ground broadly rather than pursuing singular solutions
- **Interactive steering:** Inject thoughts and feedback during active processing to redirect focus
- **Evidence-based validation:** Ideas must survive research with real user complaints, not assumptions
- **Multi-pass refinement:** Each iteration deepens understanding rather than forcing premature convergence

## Troubleshooting

### Skill not appearing in Claude Code

1. Check the skill file exists: `.claude/skills/ralph-ideate.create/SKILL.md`
2. Verify the frontmatter is valid YAML
3. Restart Claude Code

### "command not found: ralph-ideate"

Ensure uv tools are on your PATH:

```bash
uv tool install ralph-ideate
ralph-ideate init
```

## Acknowledgments

Ralph Ideate is inspired by [Ralph Loop](https://github.com/snarktank/ralph) and [Spec Kit](https://github.com/github/spec-kit). Read more about the motivation in the [idea machine blog post](https://fabianboth.dev/blog/idea-machine/).
