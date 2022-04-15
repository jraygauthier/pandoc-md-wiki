from abc import ABC, abstractmethod
from pathlib import Path
from typing import Dict, List, Set, Any, Optional, Iterable, TypedDict
import yaml
import os
import re
from .yaml_frontmatter import load_page_yaml_frontmatter


class PathProps(TypedDict):
    dir: bool


PerTagPathsDict = Dict[str, Dict[str, PathProps]]
PerTagFilesDict = PerTagPathsDict
PerTagDirsDict = PerTagPathsDict

ORPHAN_KEY = ""


def load_pmw_yaml_file(filename: Path) -> Dict[str, Any]:
    try:
        with open(filename) as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        return {}


def get_pmw_tags(
        pmw_dict: Dict[str, Any], inherited_tags: Set[str]
) -> Set[str]:
    combined_tags = set(inherited_tags)

    try:
        tag_ops = pmw_dict["pmw"]["tags"]
    except KeyError:
        tag_ops = []

    for tag_op in tag_ops:
        tag = tag_op.lstrip("+-@")
        if tag_op.startswith("-@"):
            combined_tags.discard(tag)
        else:
            assert tag_op.startswith("+@") or tag_op.startswith("@")
            combined_tags.add(tag)

    return combined_tags


class PmwFilter(ABC):
    @abstractmethod
    def is_excluded_dir(self, path: Path) -> bool:
        pass

    @abstractmethod
    def is_included_file(self, path: Path) -> bool:
        pass

    @abstractmethod
    def is_page_file(self, path: Path) -> bool:
        pass


class PmwFilterDefault(PmwFilter):
    def __init__(self) -> None:
        self._page_exts = [
            [".md"]
        ]

        self._included_exts = self._page_exts + [
            [".svg"],
            [".png"],
            [".jpg"],
        ]

        self._excluded_dirnames = [
            ".git"
        ]

        self._excluded_dir_regexps = [
            r"^.*/.git/.*$",
        ]

    @staticmethod
    def _match_any_of_regexps(path: Path, regexps: Iterable[str]):
        for regexp in regexps:
            if re.match(regexp, str(path)) is not None:
                return True

        return False

    @staticmethod
    def _has_any_of_exts(
            path: Path, expected_ext_list: Iterable[List[str]]
    ) -> bool:
        actual_ext = path.suffixes

        for expected_ext in expected_ext_list:
            if len(expected_ext) > len(actual_ext):
                continue

            match = all(
                map(
                    lambda x: x[0] == x[1],
                    zip(
                        reversed(expected_ext),
                        reversed(actual_ext)
                    )
                )
            )
            if match:
                return True

        return False

    @staticmethod
    def _has_any_of_names(
            path: Path, expected_name_list: Iterable[str]
    ) -> bool:
        actual_ext = path.name

        for expected_name in expected_name_list:
            if actual_ext == expected_name:
                return True

        return False

    def is_excluded_dir(self, path: Path) -> bool:
        return (
            self._has_any_of_names(path, self._excluded_dirnames) or
            self._match_any_of_regexps(
                path, self._excluded_dir_regexps))

    def is_included_file(self, path: Path) -> bool:
        return self._has_any_of_exts(path, self._included_exts)

    def is_page_file(self, path: Path) -> bool:
        return self._has_any_of_exts(path, self._page_exts)


def categorize_wiki_files(
        root_dir: Optional[Path] = None,
        pmw_filter: Optional[PmwFilter] = None
) -> PerTagFilesDict:
    if root_dir is None:
        root_dir = Path.cwd()
    elif not root_dir.is_absolute():
        root_dir = Path.cwd().joinpath(root_dir)

    if pmw_filter is None:
        pmw_filter = PmwFilterDefault()

    per_dir_tags: Dict[str, Set[str]] = dict()
    per_file_tags: Dict[str, Set[str]] = dict()
    all_tags: Set[str] = set()

    for _root, dirs, files in os.walk(
            root_dir, topdown=True):
        root = Path(_root)

        if pmw_filter.is_excluded_dir(root):
            continue

        parent_dir = root.parent
        try:
            parent_dir_tags = per_dir_tags[str(parent_dir)]
        except KeyError:
            parent_dir_tags = set()

        pmw_filename = root.joinpath(".pmw.yaml")
        pmw_dict = load_pmw_yaml_file(pmw_filename)

        dir_tags = get_pmw_tags(pmw_dict, parent_dir_tags)

        per_dir_tags[str(root)] = dir_tags
        all_tags |= dir_tags

        for name in files:
            path = root.joinpath(name)
            if not pmw_filter.is_included_file(path):
                continue

            if pmw_filter.is_page_file(path):
                embedded_pmw_dict = load_page_yaml_frontmatter(path)
            else:
                # Non page file
                embedded_pmw_dict = {}

            file_tags = get_pmw_tags(embedded_pmw_dict, dir_tags)
            per_file_tags[str(path)] = file_tags
            all_tags |= file_tags

    per_tag_files: PerTagFilesDict = {}

    #
    # Add directories.
    #
    DIR_PROPS = PathProps(dir=True)
    for t in all_tags:
        filenames = per_tag_files.setdefault(t, {})
        for k, v in per_dir_tags.items():
            if t in v:
                relative_filename = Path(k).relative_to(root_dir)
                filenames[str(relative_filename)] = DIR_PROPS

    # Orphan (i.e: no tag) case.
    filenames = per_tag_files.setdefault(ORPHAN_KEY, {})
    for k, v in per_dir_tags.items():
        if not v:
            relative_filename = Path(k).relative_to(root_dir)
            filenames[str(relative_filename)] = DIR_PROPS

    #
    # Add files.
    #
    FILE_PROPS = PathProps(dir=False)
    for t in all_tags:
        filenames = per_tag_files.setdefault(t, {})
        for k, v in per_file_tags.items():
            if t in v:
                relative_filename = Path(k).relative_to(root_dir)
                filenames[str(relative_filename)] = FILE_PROPS

    # Orphan (i.e: no tag) case.
    filenames = per_tag_files.setdefault(ORPHAN_KEY, {})
    for k, v in per_file_tags.items():
        if not v:
            relative_filename = Path(k).relative_to(root_dir)
            filenames[str(relative_filename)] = FILE_PROPS

    return {
        k: v
        for k, v in sorted(per_tag_files.items())
    }
