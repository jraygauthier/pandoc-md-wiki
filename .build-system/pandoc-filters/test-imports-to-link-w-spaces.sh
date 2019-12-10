#!/usr/bin/env bash
set -euf -o pipefail
cd "$(dirname "$0")/../.." || exit 1

test_src_file="./Features/PlantUMLSupport/ImportedFileWithSpaces.md"
test_out_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/ImportedFileWithSpaces.html"
test_in_puml_file="./Features/PlantUMLSupport/Diagrams/Activity_With_Spaces_Example.puml"
test_out_svg_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/Diagrams/Activity_With_Spaces_Example.svg"

touch "$test_in_puml_file"
touch "$test_src_file"
make "$test_out_svg_file" "$test_out_file"
# We have to do this here as the gnumake system does not support spaces itself.
cp "$test_out_svg_file" "$(echo "$test_out_svg_file" | tr '_' ' ')"

xdg-open "$test_out_file"
