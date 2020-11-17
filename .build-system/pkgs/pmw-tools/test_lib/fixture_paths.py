from pathlib import Path


def get_test_data_root_dir() -> Path:
    return Path(__name__).parent.joinpath("data")


def get_wiki_test_case_root_dir() -> Path:
    return get_test_data_root_dir().joinpath("WikiCases")


def get_wiki_test_case_dir(case_name: str) -> Path:
    return get_wiki_test_case_root_dir().joinpath(case_name)
