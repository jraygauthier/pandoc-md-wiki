import yaml
import json

from .yaml_wiki_walker import categorize_wiki_pages_json_ready


def main() -> None:
    per_tag_md = categorize_wiki_pages_json_ready()

    per_tag_md_yaml_str = yaml.dump(per_tag_md)
    print(per_tag_md_yaml_str)

    per_tag_md_json_str = json.dumps(per_tag_md, indent=2, sort_keys=True)
    print(per_tag_md_json_str)

