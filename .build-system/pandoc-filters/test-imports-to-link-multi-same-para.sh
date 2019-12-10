#!/usr/bin/env bash
set -euf -o pipefail
cd "$(dirname "$0")/../.." || exit 1

test_src_file="./Features/PlantUMLSupport/ImportedFileMultipleSamePara.md"
test_out_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/ImportedFileMultipleSamePara.html"
test_in_puml_file="./Features/PlantUMLSupport/Diagrams/SequenceExample.puml"
test_out_svg_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/Diagrams/SequenceExample.svg"

touch "$test_in_puml_file"
touch "$test_src_file"
make "$test_out_svg_file" "$test_out_file"
xdg-open "$test_out_file"
