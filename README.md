<div align="center">
    <img src="https://raw.githubusercontent.com/fabianboth/ralph-ideate/main/assets/ralph_loop.webp" alt="Ralph Ideate" width="450"/>
    <h1>Ralph Ideate</h1>
    <h3><em>Automate the brainstorming cycle.</em></h3>
</div>

<p align="center">
    <strong>The cycle of ideate, extend, research, scrutinize, repeat - fully automated. <code>ralph-ideate</code> covers ground systematically so you can focus on steering, not grinding.</strong>
</p>

<p align="center">
    <a href="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml"><img src="https://github.com/fabianboth/ralph-ideate/actions/workflows/ci.yml/badge.svg" alt="CI"/></a>
    <a href="https://pypi.org/project/ralph-ideate/"><img src="https://img.shields.io/pypi/v/ralph-ideate" alt="PyPI version"/></a>
    <a href="https://github.com/fabianboth/ralph-ideate/blob/main/LICENSE"><img src="https://img.shields.io/github/license/fabianboth/ralph-ideate" alt="License"/></a>
</p>

---

## The Ralph Ideate Loop

The Ralph Ideate Loop is a structured brainstorming methodology that cycles through four phases:

1. **Ideate:** Generate and capture ideas
2. **Extend:** Build on and expand promising concepts
3. **Research:** Investigate and validate with real-world data
4. **Scrutinize:** Critically evaluate and challenge assumptions

Then repeat. Each pass deepens understanding rather than forcing premature convergence.

## Features

- **Infinite exploration:** Covers ground systematically rather than pursuing singular solutions
- **Interactive steering:** Inject thoughts and feedback during active processing to redirect focus
- **Verified validation:** Ideas progress through documented phases with structured assessment

## Usage

Ralph Ideate runs as [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills. In any repository with these skills installed:

### Create a brainstorming domain

```
/ralph-ideate.create saas-tools
```

This scaffolds the domain directory structure and guides you through writing a `DESCRIPTION.md` that defines scope, focus, constraints, and evaluation criteria.

### Explore ideas

```
/ralph-ideate.explore src/saas-tools --max-iterations 10
```

This starts the Ralph Ideate Loop — a continuous cycle that generates candidate ideas, researches pain points with real user evidence, critically evaluates viability, and moves ideas to `verified/` or `discarded/`. Each iteration reads the current state fresh and decides which phase to execute.

Omit `--max-iterations` to run indefinitely. Inject steering feedback between iterations to redirect focus.

### Domain structure

```
src/<domain>/
├── DESCRIPTION.md    # Scope, focus, constraints
├── candidates/       # Ideas under evaluation
├── verified/         # Ideas that passed scrutiny
└── discarded/        # Rejected ideas with reasoning
```

## Installation

```bash
uv tool install ralph-ideate
```
