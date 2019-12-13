import pytest
import logging
from typing import Optional, Dict, Set
from pprint import pformat
from pmw_tools.categorize import (categorize_wiki_files, ORPHAN_KEY)
from pathlib import Path
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

    assert False, (
        f"Cannot find the expected 'should be' line in '{page_path}'."
    )


def _parse_should_be_set(
        root_dir: Path, page_path: Path) -> Set[str]:
    should_be_sstr = get_should_be_substr()
    known_tags = ["private", "public", "work"]
    shoud_be_ln = _find_should_be_line(root_dir, page_path)
    try:
        should_be_listing = shoud_be_ln.split(should_be_sstr)[1].strip()
    except IndexError as e:
        raise AssertionError from e

    out = {
        t for t in known_tags if t in should_be_listing}
    if not out:
        out = {ORPHAN_KEY}

    return out


def test_no_root_tags_case():
    root_dir = get_wiki_test_case_dir("NoRootTagsCase")
    out = categorize_wiki_files(root_dir)

    LOGGER.info("out:\n%s", pformat(out))


@pytest.mark.parametrize("case_name, expected_known_tags", [
    ("NoRootTagsCase", {"private", "public", ORPHAN_KEY}),
    ("ComplexPrivateByDefaultCase", {"private", "public", "work", ORPHAN_KEY})
])
def test_categorize_wiki_files_all_cases(
        case_name: str, expected_known_tags: Set[Optional[str]]):
    root_dir = get_wiki_test_case_dir(case_name)
    out = categorize_wiki_files(root_dir)

    LOGGER.info("out:\n%s", pformat(out))

    actual_known_tags = set()
    all_files: Dict[Path, Set[str]] = dict()
    for tag, ps in out.items():
        actual_known_tags.add(tag)
        for path, props in ps.items():
            is_dir = props["dir"]
            full_path = root_dir.joinpath(path)
            assert is_dir == full_path.is_dir()
            if is_dir is True:
                continue

            tags = all_files.setdefault(Path(path), set())
            tags.add(tag)

    assert actual_known_tags == expected_known_tags

    for file_p, file_p_tags in all_files.items():
        expected_tags = _parse_should_be_set(root_dir, file_p)
        for t in actual_known_tags:
            if t in expected_tags:
                assert str(file_p) in out[t], (
                    f"Md page '{file_p}' not tagged as '{t}' as expected. "
                    f"Currently tagged as: {file_p_tags}"
                )
            else:
                assert str(file_p) not in out[t], (
                    f"Md page '{file_p}' wronfully tagged as '{t}'. "
                    f"Currently tagged as: {file_p_tags}"
                )
