import yaml
import io
from pathlib import Path
from typing import Iterator, Dict, Any


def load_page_yaml_frontmatter_line_gen(
        filename: Path) -> Iterator[str]:
    # TODO: We only support markdown frontmatter at this time.
    assert ".md" == filename.suffix

    with open(filename, 'r', encoding="utf-8") as f:
        line_it = enumerate(f)
        for i, l in line_it:
            if l.startswith("---"):
                break
            if i >= 0:
                return

        for i, l in line_it:
            if l.startswith("---") or l.startswith("..."):
                break
            else:
                yield l.rstrip('\r\n')


def load_page_yaml_frontmatter_str(filename: Path) -> str:
    ostream = io.StringIO()
    for l in load_page_yaml_frontmatter_line_gen(filename):
        ostream.write("{}\n".format(l))

    return ostream.getvalue()


def load_page_yaml_frontmatter(filename: Path) -> Dict[str, Any]:
    fm_str = load_page_yaml_frontmatter_str(filename)
    # print(fm_str)
    if not fm_str.strip():
        return dict()

    out = yaml.safe_load(fm_str)
    if not isinstance(out, dict):
        return dict()

    return out
