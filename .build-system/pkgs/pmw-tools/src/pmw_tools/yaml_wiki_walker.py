from pathlib import Path
from typing import Iterator, Dict, List, Set, Any, Optional
import yaml
import io
import os
import re


def load_md_yaml_frontmatter_line_gen(
        filename: Path) -> Iterator[str]:
    with open(filename, 'r', encoding="utf-8") as f:
        line_it = enumerate(f.readlines())
        for i, l in line_it:
            if l.startswith("---"):
                break
            if i > 0:
                return

        for i, l in line_it:
            if l.startswith("---") or l.startswith("..."):
                break
            else:
                yield l.rstrip('\r\n')


def load_md_yaml_frontmatter_str(filename: Path) -> str:
    ostream = io.StringIO()
    for l in load_md_yaml_frontmatter_line_gen(filename):
        ostream.write("{}\n".format(l))

    return ostream.getvalue()


def load_md_yaml_frontmatter(filename: Path) -> Dict[str, Any]:
    try:
        fm_str = load_md_yaml_frontmatter_str(filename)
        # print(fm_str)
        if not fm_str.strip():
            return dict()

        out = yaml.safe_load(fm_str)
        if not isinstance(out, dict):
            return dict()

        return out
    except FileNotFoundError:
        return {}


def load_pmw_yaml_file(filename: Path) -> Dict[str, Any]:
    try:
        with open(filename) as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        return {}


def get_pmw_tags(
        pmw_dict: Dict[str, Any], inherited_tags: Set[str]
) -> Set[str]:
    dir_tags = set(inherited_tags)

    try:
        dir_tag_ops = pmw_dict["pmw"]["tags"]
    except KeyError:
        dir_tag_ops = []

    for tag_op in dir_tag_ops:
        tag = tag_op.lstrip("+-@")
        if tag_op.startswith("-@"):
            dir_tags.discard(tag)
        else:
            assert tag_op.startswith("+@") or tag_op.startswith("@")
            dir_tags.add(tag)

    return dir_tags


def is_excluded_dir(path: Path) -> bool:
    return re.match(r"^./.git/.*$", str(path)) is not None


def is_included_file(path: Path) -> bool:
    return re.match(r"^.*\.md$", path.name) is not None


def _categorize_wiki_pages(
        root_dir: Optional[Path]
) -> Dict[str, Set[str]]:
    if root_dir is None:
        root_dir = Path(".")

    for sub in root_dir.iterdir():
        if sub.is_dir():
            if is_excluded_dir(sub):
                continue
            categorize_wiki_pages(sub)
        else:
            pass

    return {}


def categorize_wiki_pages(
        root_dir: Optional[Path] = None
) -> Dict[str, Set[str]]:
    if root_dir is None:
        root_dir = Path(".")

    per_dir_tags: Dict[str, Set[str]] = dict()
    per_md_tags: Dict[str, Set[str]] = dict()
    all_tags: Set[str] = set()

    for _root, dirs, files in os.walk(
            root_dir, topdown=True):
        root = Path(_root)

        if is_excluded_dir(root):
            continue

        parent_dir = root.parent
        try:
            parent_dir_tags = per_dir_tags[str(parent_dir)]
        except KeyError:
            parent_dir_tags = set()

        pmw_filename = root.joinpath(".pmw.yaml")
        # print(pmw_filename)
        pmw_dict = load_pmw_yaml_file(pmw_filename)

        dir_tags = get_pmw_tags(pmw_dict, parent_dir_tags)
        # print(dir_tags)
        per_dir_tags[str(root)] = dir_tags
        all_tags |= dir_tags

        for name in files:
            path = root.joinpath(name)
            if not is_included_file(path):
                continue

            # print(path)
            md_pmw_dict = load_md_yaml_frontmatter(path)

            md_tags = get_pmw_tags(md_pmw_dict, dir_tags)
            per_md_tags[str(path)] = md_tags
            all_tags |= md_tags
            # print(md_tags)

    # print(all_tags)
    # print(per_dir_tags)
    # print(per_md_tags)

    per_tag_md: Dict[str, Set[str]] = {}
    for t in all_tags:
        md_filenames = per_tag_md.setdefault(t, set())
        for k, v in per_md_tags.items():
            if t in v:
                md_filenames.add(k)

    return per_tag_md


def categorize_wiki_pages_json_ready(
    root_dir: Optional[Path] = None
) -> Dict[str, List[str]]:
    per_tag_md: Dict[str, List[str]] = dict()
    for k, v in categorize_wiki_pages(root_dir).items():
        per_tag_md.setdefault(k, list(v))
    return per_tag_md
