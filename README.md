<div align="center">
    <img src="https://raw.githubusercontent.com/fabianboth/ralph-ideate/main/assets/ralph_loop.webp" alt="Ralph Ideate" width="450"/>
    <h1>Ralph Ideate</h1>
    <h3><em>Automate the brainstorming cycle.</em></h3>
</div>

<p align="center">
    <strong>Ideate, extend, research, scrutinize, repeat - fully automated. <code>ralph-ideate</code> covers ground systematically so you can focus on steering, not grinding.</strong>
</p>

<p align="center">
    <a href="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml"><img src="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml/badge.svg" alt="CI"/></a>
    <a href="https://pypi.org/project/ralph-ideate/"><img src="https://img.shields.io/pypi/v/ralph-ideate" alt="PyPI version"/></a>
    <a href="https://github.com/fabianboth/ralph-ideate/blob/main/LICENSE"><img src="https://img.shields.io/github/license/fabianboth/ralph-ideate" alt="License"/></a>
</p>

---

## Installation

```bash
uv tool install ralph-ideate
```

```bash
ralph-ideate init
```

## Getting Started

### 1. Create a brainstorming domain

```text
/ralph-ideate.create saas-tools
```

This scaffolds a domain directory and guides you through writing a `DESCRIPTION.md` that defines scope, focus, and evaluation criteria.

### 2. Explore ideas

```text
/ralph-ideate.explore ideate/saas-tools
```

This starts the Ralph Ideate Loop - a continuous cycle that generates candidates, researches pain points with real user evidence, critically evaluates viability, and moves ideas to `verified/` or `discarded/`.

Optionally pass a custom prompt and iteration limit:

```text
/ralph-ideate.explore ideate/saas-tools "Focus on B2B pain points" --max-iterations 20
```

| Option | Default | Description |
|--------|---------|-------------|
| `"custom prompt"` | auto-generated | Focus the brainstorming on a specific angle |
| `--max-iterations N` | `10` | Auto-stop after N iterations (`0` = unlimited) |

Inject steering feedback between iterations to redirect focus.

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
