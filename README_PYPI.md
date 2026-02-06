<div align="center">
    <img src="https://raw.githubusercontent.com/fabianboth/autonomous-review-loop/main/assets/review_loop.webp" alt="Autonomous Review Loop" width="450"/>
    <h1>Autonomous Review Loop</h1>
    <h3><em>Automate the review-fix-push cycle.</em></h3>
</div>

<p align="center">
    <strong>Pair your review bot with your coding agent: <code>reviewloop</code> delegates the entire review-fix-push cycle so you only step in when human judgment is needed.</strong>
</p>

<p align="center">
    <a href="https://github.com/fabianboth/autonomous-review-loop/actions/workflows/ci.yml"><img src="https://github.com/fabianboth/autonomous-review-loop/actions/workflows/ci.yml/badge.svg" alt="CI"/></a>
    <a href="https://pypi.org/project/reviewloop/"><img src="https://img.shields.io/pypi/v/reviewloop" alt="PyPI version"/></a>
    <a href="https://github.com/fabianboth/autonomous-review-loop/blob/main/LICENSE"><img src="https://img.shields.io/github/license/fabianboth/autonomous-review-loop" alt="License"/></a>
</p>

---

## Installation

```bash
uv tool install reviewloop
```

```bash
reviewloop init
```

## Getting Started

### Claude Code

Select **Claude Code** during `reviewloop init`. Then run this within your claude code session:

```text
/reviewloop
```

### Any Coding Agent

Select **Script based** during `reviewloop init`. This creates standalone scripts and a prompt file at `scripts/reviewloop/reviewPrompt.txt`. Feed it to any coding agent (Cursor, Windsurf, etc.) with `@scripts/reviewloop/reviewPrompt.txt` to start the loop.

## How It Works

1. Waits for CI to complete
2. Fetches inline comments and review comments
3. Fixes valid issues and asks you about ambiguous ones
4. Resolves threads and pushes
5. Repeats until no unresolved comments remain

## Features

- **Batched decision-making:** Aggregate review requests instead of triaging comments one by one.
- **Parallel work:** Continue other tasks while the loop runs in the background.
- **Multi-pass resolution:** Iterates automatically until clean.
- **Agent-agnostic:** Works with Claude Code, Cursor, Windsurf, or any coding agent.

## Documentation

For full documentation, troubleshooting, and advanced usage, visit the [GitHub repository](https://github.com/fabianboth/autonomous-review-loop).
