from __future__ import annotations

import os
import shutil
import stat
from importlib.resources import files
from pathlib import Path
from typing import Annotated

import typer

SKILL_FILES = [
    ".claude/skills/ralph-ideate.create/SKILL.md",
    ".claude/skills/ralph-ideate.explore/SKILL.md",
    ".claude/skills/ralph-ideate.explore/scripts/setup-ralph-ideate.sh",
    ".claude/skills/ralph-ideate.explore/scripts/loop-context.sh",
    ".claude/skills/ralph-ideate.refine/SKILL.md",
]

TEMPLATE_TO_SKILL: list[tuple[str, str]] = [
    ("ralph-ideate.create/SKILL.md", ".claude/skills/ralph-ideate.create/SKILL.md"),
    ("ralph-ideate.explore/SKILL.md", ".claude/skills/ralph-ideate.explore/SKILL.md"),
    (
        "ralph-ideate.explore/scripts/setup-ralph-ideate.sh",
        ".claude/skills/ralph-ideate.explore/scripts/setup-ralph-ideate.sh",
    ),
    (
        "ralph-ideate.explore/scripts/loop-context.sh",
        ".claude/skills/ralph-ideate.explore/scripts/loop-context.sh",
    ),
    ("ralph-ideate.refine/SKILL.md", ".claude/skills/ralph-ideate.refine/SKILL.md"),
]


def _templates_path() -> Path:
    source = files("ralph_idea_cli.templates")
    path = Path(str(source))
    if not path.is_dir():
        print("Error: template files not found. The ralph-ideate package may be corrupted — try reinstalling.")
        raise typer.Exit(code=1)
    return path


def _make_executable(path: Path) -> None:
    if os.name == "nt":
        return
    current = path.stat().st_mode
    path.chmod(current | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def _check_existing_files(target_dir: Path, force: bool) -> bool:
    existing = [f for f in SKILL_FILES if (target_dir / f).exists()]
    if not existing:
        return True
    print("The following files already exist:")
    for f in existing:
        print(f"  - {f}")
    if force:
        print("Overwriting (--force).")
        return True
    return typer.confirm("Overwrite?", default=False)


def _install_skills(target_dir: Path, templates: Path) -> list[str]:
    created: list[str] = []
    for template_rel, skill_rel in TEMPLATE_TO_SKILL:
        src = templates / template_rel
        dst = target_dir / skill_rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        if dst.suffix == ".sh":
            _make_executable(dst)
        created.append(skill_rel)
    return created


def _print_summary(created_files: list[str], target_dir: Path) -> None:
    print(f"\nInitialized ralph-ideate in {target_dir}\n")
    print("Created files:")
    for f in created_files:
        print(f"  {f}")


def _resolve_target_dir(project_name: str | None) -> Path:
    if project_name is None:
        name: str = typer.prompt("Project folder", default=".")
        if name == ".":
            return Path.cwd()
        target = Path.cwd() / name
        target.mkdir(parents=True, exist_ok=True)
        return target
    if project_name == ".":
        return Path.cwd()
    target = Path.cwd() / project_name
    target.mkdir(parents=True, exist_ok=True)
    return target


def init(
    project_name: Annotated[
        str | None, typer.Argument(help="Target directory name (defaults to current directory).")
    ] = None,
    force: Annotated[bool, typer.Option("--force", help="Overwrite existing files without confirmation.")] = False,
) -> None:
    target_dir = _resolve_target_dir(project_name)

    if not _check_existing_files(target_dir, force):
        print("Aborted.")
        raise typer.Exit(code=1)

    templates = _templates_path()
    created = _install_skills(target_dir, templates)
    _print_summary(created, target_dir)
