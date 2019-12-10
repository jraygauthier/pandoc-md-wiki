#!/usr/bin/env bash
set -euf -o pipefail
cd "$(dirname "$0")/../.." || exit 1

test_src_file="./Features/PlantUMLSupport/Inline.md"
test_out_file="../pandoc-md-wiki-html/Features/PlantUMLSupport/Inline.html"

touch "$test_src_file"
make "$test_out_file"
xdg-open "$test_out_file"
