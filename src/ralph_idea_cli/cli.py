from __future__ import annotations

from importlib.metadata import version
from typing import Annotated

import typer

from ralph_idea_cli.init import init as init_command

app = typer.Typer(
    name="ralph-ideate",
    help="Ralph Ideate - automates the brainstorming cycle.",
    add_completion=False,
    invoke_without_command=True,
)
app.command(name="init", help="Initialize Ralph Ideate skills in a project.")(init_command)


def _version_callback(value: bool) -> None:
    if value:
        print(f"ralph-ideate v{version('ralph-ideate')}")
        raise typer.Exit


@app.callback()
def callback(
    ctx: typer.Context,
    _version: Annotated[
        bool | None,
        typer.Option("--version", callback=_version_callback, is_eager=True, help="Show version and exit."),
    ] = None,
) -> None:
    if ctx.invoked_subcommand is None:
        print(ctx.get_help())
        raise typer.Exit


def main() -> None:
    app()
