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
/ralph-ideate.create B2B services that agentic AI can fully automate end-to-end
```

### 2. Explore ideas

```text
/ralph-ideate.explore @ideate/agentic-ai-agencies
```

### 3. Refine a domain description

```text
/ralph-ideate.refine @ideate/agentic-ai-agencies
```

## How It Works

Each iteration reads the domain state fresh and decides which phase to execute:

1. **Ideate** - Generate and capture new candidate ideas
2. **Research** - Validate pain points with real-world evidence
3. **Scrutinize** - Critically evaluate viability and differentiation
4. **Decide** - Verify, revise, or discard each candidate

## Features

- **Systematic exploration:** Covers ground broadly rather than pursuing singular solutions
- **Interactive steering:** Inject thoughts and feedback during active processing to redirect focus
- **Evidence-based validation:** Ideas must survive research with real user complaints, not assumptions
- **Multi-pass refinement:** Each iteration deepens understanding rather than forcing premature convergence

## Acknowledgments

Inspired by [Ralph](https://github.com/snarktank/ralph) by [snarktank](https://github.com/snarktank).

## Documentation

For full documentation, troubleshooting, and advanced usage, visit the [GitHub repository](https://github.com/fabianboth/ralph-ideate).
