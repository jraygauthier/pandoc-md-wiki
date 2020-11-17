import pytest
import logging
from pprint import pformat
from pmw_tools.categorize import (categorize_wiki_files)
from pathlib import Path
from typing import Set
from test_lib.fixture_paths import get_wiki_test_case_dir


LOGGER = logging.getLogger(__name__)


def get_should_be_substr() -> str:
    return "should be"


def _find_should_be_line(root_dir: Path, page_path: Path) -> str:
    should_be_sstr = get_should_be_substr()
    absolute_path = root_dir.joinpath(page_path)
    with open(absolute_path) as f:
        for ln in f.readlines():
            if should_be_sstr in ln:
                return ln

    assert False, f"Cannot find the expected 'should be' line in '{page_path}'."


def _parse_should_be_set(root_dir: Path, page_path: Path) -> Set[str]:
    should_be_sstr = get_should_be_substr()
    known_tags = ["private", "public", "work"]
    shoud_be_ln = _find_should_be_line(root_dir, page_path)
    try:
        should_be_listing = shoud_be_ln.split(should_be_sstr)[1].strip()
    except IndexError as e:
        raise AssertionError from e

    return {t for t in known_tags if t in should_be_listing}


def test_no_root_tags_case():
    root_dir = get_wiki_test_case_dir("NoRootTagsCase")
    out = categorize_wiki_files(root_dir)

    LOGGER.info("out:\n%s", pformat(out))


@pytest.mark.parametrize("case_name, expected_known_tags", [
    ("NoRootTagsCase", {"private", "public"}),
    ("ComplexPrivateByDefaultCase", {"private", "public", "work"})
])
def test_categorize_wiki_files_all_cases(
        case_name: str, expected_known_tags: Set[str]):
    root_dir = get_wiki_test_case_dir(case_name)
    out = categorize_wiki_files(root_dir)

    LOGGER.info("out:\n%s", pformat(out))

    actual_known_tags = set()
    all_md_paths = set()
    for k, ps in out.items():
        actual_known_tags.add(k)
        for p in ps:
            all_md_paths.add(Path(p))

    assert actual_known_tags == expected_known_tags

    for md_p in all_md_paths:
        expected_tags = _parse_should_be_set(root_dir, md_p)
        for t in actual_known_tags:
            if t in expected_tags:
                assert str(md_p) in out[t], (
                    f"Md page '{md_p}' not tagged as '{t}' as expected.")
            else:
                assert str(md_p) not in out[t], (
                    f"Md page '{md_p}' wronfully tagged as '{t}'.")
