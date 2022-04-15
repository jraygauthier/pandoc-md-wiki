import json
from pathlib import Path
from typing import Any, Optional

import click
from pmw_tools.categorize import (PerTagPathsDict,
                                  categorize_wiki_files)


@click.group()
def cli() -> None:
    pass


def mk_cwd_option() -> Any:
    return click.option(
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


def mk_output_file_option() -> Any:
    return click.option(
        "--output", "-o", "output_file_str",
        default="-",
        type=click.Path(
            exists=False,
            dir_okay=False, file_okay=True,
            writable=True, readable=False
        ),
        help=(
            "The output file for this tool.\n"
            "A writable json / yaml filename."
        )
    )


def _save_as_json(data_d: PerTagPathsDict, output_file_str: str) -> None:
    assert output_file_str is not None
    with click.open_file(output_file_str, "w") as of:
        json.dump(
            data_d,
            of,
            sort_keys=True,
            indent=2,
            separators=(",", ": ")
        )


@cli.command()
@mk_cwd_option()
@mk_output_file_option()
def categorize(
        cwd_str: Optional[str], output_file_str: str) -> None:
    if cwd_str is None:
        cwd = Path.cwd()
    else:
        cwd = Path(cwd_str)

    categorized_d = categorize_wiki_files(cwd)
    _save_as_json(categorized_d, output_file_str)


def run_cli() -> None:
    return cli()
