#!/usr/bin/env bash
set -euf -o pipefail
cd "$(dirname "$0")/../.." || exit 1

test_src_file="./Features/ImageSupport/ImageLinkWithAttributes.md"
test_out_file="../pandoc-md-wiki-html/Features/ImageSupport/ImageLinkWithAttributes.html"
test_in_svg_file="./Features/ImageSupport/Images/ImageExample.svg"
test_out_svg_file="../pandoc-md-wiki-html/Features/ImageSupport/Images/ImageExample.svg"

touch "$test_in_svg_file"
touch "$test_src_file"
make "$test_out_svg_file" "$test_out_file"
xdg-open "$test_out_file"
