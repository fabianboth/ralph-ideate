from __future__ import annotations

from dataclasses import dataclass, field

import questionary


def _empty_templates() -> list[tuple[str, str]]:
    return []


@dataclass(frozen=True)
class Variant:
    id: str
    name: str
    description: str
    extra_templates: list[tuple[str, str]] = field(default_factory=_empty_templates)


_VARIANT_SKILL_TEMPLATES: list[tuple[str, str]] = [
    ("ralph-ideate.create/SKILL.md", ".claude/skills/ralph-ideate.create/SKILL.md"),
    ("ralph-ideate.explore/SKILL.md", ".claude/skills/ralph-ideate.explore/SKILL.md"),
    ("ralph-ideate.refine/SKILL.md", ".claude/skills/ralph-ideate.refine/SKILL.md"),
]

VARIANTS: list[Variant] = [
    Variant(
        id="startup-ideas",
        name="Startup Ideas",
        description="Brainstorm startup and business ideas",
        extra_templates=_VARIANT_SKILL_TEMPLATES,
    ),
    Variant(
        id="investment",
        name="Investment",
        description="Brainstorm investment opportunities",
        extra_templates=_VARIANT_SKILL_TEMPLATES,
    ),
]

_VARIANT_BY_ID: dict[str, Variant] = {v.id: v for v in VARIANTS}


def get_variant_by_id(variant_id: str) -> Variant | None:
    return _VARIANT_BY_ID.get(variant_id)


def get_all_variant_ids() -> list[str]:
    return [v.id for v in VARIANTS]


def select_variant() -> Variant:
    choices = [questionary.Choice(title=f"{v.name} — {v.description}", value=v.id) for v in VARIANTS]
    selected_id: str = questionary.select("Select a brainstorming variant:", choices=choices).unsafe_ask()
    return _VARIANT_BY_ID[selected_id]
