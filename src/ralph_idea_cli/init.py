from __future__ import annotations

import os
import shutil
import stat
from importlib.resources import files
from pathlib import Path
from typing import Annotated

import typer

from ralph_idea_cli.variants import Variant, get_all_variant_ids, get_variant_by_id, select_variant

SHARED_SKILL_FILES = [
    ".claude/skills/ralph-ideate.create/SKILL.md",
    ".claude/skills/ralph-ideate.explore/SKILL.md",
    ".claude/skills/ralph-ideate.explore/scripts/setup-ralph-ideate.sh",
    ".claude/skills/ralph-ideate.explore/scripts/loop-context.sh",
    ".claude/skills/ralph-ideate.refine/SKILL.md",
]

SHARED_TEMPLATE_TO_SKILL: list[tuple[str, str]] = [
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


def _all_skill_files(variant: Variant) -> list[str]:
    return SHARED_SKILL_FILES + [skill_rel for _, skill_rel in variant.extra_templates]


def _check_existing_files(target_dir: Path, variant: Variant, force: bool) -> bool:
    all_files = _all_skill_files(variant)
    existing = [f for f in all_files if (target_dir / f).exists()]
    if not existing:
        return True
    print("The following files already exist:")
    for f in existing:
        print(f"  - {f}")
    if force:
        print("Overwriting (--force).")
        return True
    return typer.confirm("Overwrite?", default=False)


def _install_templates(target_dir: Path, templates_root: Path, mappings: list[tuple[str, str]]) -> list[str]:
    created: list[str] = []
    for template_rel, skill_rel in mappings:
        src = templates_root / template_rel
        dst = target_dir / skill_rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        if dst.suffix == ".sh":
            _make_executable(dst)
        created.append(skill_rel)
    return created


def _install_skills(target_dir: Path, templates: Path, variant: Variant) -> list[str]:
    created = _install_templates(target_dir, templates, SHARED_TEMPLATE_TO_SKILL)
    if variant.extra_templates:
        variant_templates = templates / "variants" / variant.id
        created += _install_templates(target_dir, variant_templates, variant.extra_templates)
    return created


def _print_summary(created_files: list[str], target_dir: Path, variant: Variant) -> None:
    print(f"\nInitialized ralph-ideate ({variant.name}) in {target_dir}\n")
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


def _resolve_variant(variant_flag: str | None) -> Variant:
    if variant_flag is not None:
        variant = get_variant_by_id(variant_flag)
        if variant is None:
            available = ", ".join(get_all_variant_ids())
            print(f"Error: unknown variant '{variant_flag}'. Available variants: {available}")
            raise typer.Exit(code=1)
        return variant
    return select_variant()


def init(
    project_name: Annotated[
        str | None, typer.Argument(help="Target directory name (defaults to current directory).")
    ] = None,
    variant: Annotated[
        str | None, typer.Option("--variant", help="Brainstorming variant to install (skips interactive selection).")
    ] = None,
    force: Annotated[bool, typer.Option("--force", help="Overwrite existing files without confirmation.")] = False,
) -> None:
    target_dir = _resolve_target_dir(project_name)
    selected_variant = _resolve_variant(variant)

    if not _check_existing_files(target_dir, selected_variant, force):
        print("Aborted.")
        raise typer.Exit(code=1)

    templates = _templates_path()
    created = _install_skills(target_dir, templates, selected_variant)
    _print_summary(created, target_dir, selected_variant)
