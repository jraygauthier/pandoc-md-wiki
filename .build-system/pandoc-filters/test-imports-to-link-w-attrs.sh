#!/usr/bin/env bash
cd "$(dirname "$0")/../.." || exit 1

test_src_file="./Features/PlantUMLSupport/ImportedFileWithAttributes.md"
test_out_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/ImportedFileWithAttributes.html"
test_in_puml_file="./Features/PlantUMLSupport/Diagrams/SequenceExample.puml"
test_out_svg_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/Diagrams/SequenceExample.svg"

touch "$test_in_puml_file"
touch "$test_src_file"
make "$test_out_svg_file" "$test_out_file"
xdg-open "$test_out_file"
