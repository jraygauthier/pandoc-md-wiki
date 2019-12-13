import pytest
from test_lib.fixture_paths import get_test_data_root_dir
from pmw_tools.yaml_frontmatter import load_page_yaml_frontmatter


@pytest.mark.parametrize("case_file", [
    "Level2Headers.md"
])
def test_yaml_frontmatter_cases(case_file: str):
    in_file = get_test_data_root_dir().joinpath(
        "YamlFrontMatterCases").joinpath(case_file)
    load_page_yaml_frontmatter(in_file)
