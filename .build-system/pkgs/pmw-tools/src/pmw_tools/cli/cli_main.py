import click
import json
from pathlib import Path
from typing import Optional, IO
from pmw_tools.yaml_wiki_walker import (categorize_wiki_pages_json_ready)


@click.group()
def cli() -> None:
    pass


@cli.command
@click.option(
    "--cwd", "-C", "cwd_str",
    default=None,
    type=click.Path(
        exists=True,
        dir_okay=True, file_okay=False,
        writable=False, readable=True
    ),
    help=(
        "The input directory for this tool.\n"
        "Usually should be the wiki root."
    )
)
@click.option(
    "--output", "-o", "output_file_str",
    default="-",
    type=click.Path(
        exists=True,
        dir_okay=False, file_okay=True,
        writable=True, readable=False
    ),
    help=(
        "The output file for this tool.\n"
        "A writable json / yaml filename."
    )
)
def categorize(
        cwd_str: Optional[str], output_file_str: str) -> None:

    if cwd_str is None:
        cwd = Path.cwd()
    else:
        cwd = Path(cwd_str)

    categorized_d = categorize_wiki_pages_json_ready(cwd)

    assert output_file_str is not None
    with click.open_file(output_file_str, "w") as of:
        assert isinstance(of, IO)
        json.dump(
            categorized_d,
            of,
            sort_keys=True,
            indent=2,
            separators=(",", ": ")
        )


def run_cli() -> None:
    return cli()

