# CLAUDE.md

Ralph Ideate - automates the brainstorming cycle using the Ralph Ideate Loop (ideate, extend, research, scrutinize, repeat).

## CRITICAL: File Editing on Windows

**When using Edit tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).**

## Project Structure

- `src/ralph_idea_cli/` — CLI package (typer-based), entry point in `cli.py`
- `src/ralph_idea_cli/templates/` — Bundled skill files installed by `ralph-ideate init`
- `specs/` — Feature specifications (speckit-managed)

## Tech Stack

- **Python**: 3.13+ with uv (CLI package + project tooling)
- **Bash**: 4.0+ for ideate loop scripts (bundled in `src/ralph_idea_cli/templates/`)
- **CLI Framework**: typer, readchar (interactive selection)
- **Linting/Formatting**: ruff
- **Type Checking**: pyright (strict mode)

## Commands

```bash
uv run ruff check
uv run ruff format
uv run pyright
```

## Code Style

- Self-explaining modular code: comment-free where possible (only comments when genuinely helpful)
- Bash scripts use strict mode (`set -euo pipefail`)
- Python 3.13+, line length 120, double quotes
- Strict type hints (pyright strict mode) - all methods must be typed
- Never suppress type/lint errors - fix them  (rare exceptions only)
- Avoid creating barrel exports via init files, always directly import instead

## Change Verification

Always verify code changes:

- Format code with `uv run ruff format`
- Verify changes with `uv run ruff check`
- Verify type checking with `uv run pyright`
