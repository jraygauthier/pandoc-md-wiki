
PMW_MKF_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

MKF_CWD := $(shell pwd)

ifndef PANDOC_MD_WIKI_ROOT_DIR
  PANDOC_MD_WIKI_ROOT_DIR := $(PMW_MKF_DIR)
endif

ifndef PANDOC_MD_WIKI_CSS_DIR
  PANDOC_MD_WIKI_CSS_DIR := $(PANDOC_MD_WIKI_ROOT_DIR)/.style/css
endif

ifndef PANDOC_MD_WIKI_OUT_PARENT_DIR
  PANDOC_MD_WIKI_OUT_PARENT_DIR := $(abspath $(dir $(PANDOC_MD_WIKI_ROOT_DIR)))
endif

ifndef PANDOC_MD_WIKI_OUT_BASENAME_PREFIX
  PANDOC_MD_WIKI_OUT_BASENAME_PREFIX := $(shell basename "$(PANDOC_MD_WIKI_ROOT_DIR)")
endif

ifndef PANDOC_MD_WIKI_OUT_HTML_DIR
  PANDOC_MD_WIKI_OUT_HTML_DIR := $(PANDOC_MD_WIKI_OUT_PARENT_DIR)/$(PANDOC_MD_WIKI_OUT_BASENAME_PREFIX)-html
endif

# A directory alongside this one with the "-html suffix ".
SRC_ROOT_DIR := $(PANDOC_MD_WIKI_ROOT_DIR)
OUT_HTML_DIR := $(PANDOC_MD_WIKI_OUT_HTML_DIR)
OUTPUT_HTML_REL_DIR := $(shell realpath --relative-to "$(MKF_CWD)" "$(OUT_HTML_DIR)")

FN_SRC_REL_TO_ROOT = $(shell realpath --relative-to "$(shell dirname "$(SRC_ROOT_DIR)/$(1)")" "$(SRC_ROOT_DIR)")

EXCLUDED_DIR_FIND_ARGS := -not -path '*/.diagrams_cache/*' -not -path '*/.assets-puml/*'

SRC_MD := $(shell find . -mindepth 1 -type f -name '*.md' $(EXCLUDED_DIR_FIND_ARGS) -printf '%P\n')
OUT_HTML_FROM_MD := $(patsubst %.md,$(OUTPUT_HTML_REL_DIR)/%.html,$(SRC_MD))

SRC_PUML := $(shell find . -mindepth 1 -type f -name '*.puml' $(EXCLUDED_DIR_FIND_ARGS) -printf '%P\n')
OUT_HTML_SVG_FROM_PUML := $(patsubst %.puml,$(OUTPUT_HTML_REL_DIR)/%.svg,$(SRC_PUML))

SRC_SVG := $(shell find . -mindepth 1 -type f -name '*.svg' $(EXCLUDED_DIR_FIND_ARGS) -printf '%P\n')
OUT_HTML_SVG_FROM_SRC := $(patsubst %.svg,$(OUTPUT_HTML_REL_DIR)/%.svg,$(SRC_SVG))

SRC_PNG := $(shell find . -mindepth 1 -type f -name '*.png' $(EXCLUDED_DIR_FIND_ARGS) -printf '%P\n')
OUT_HTML_PNG_FROM_SRC := $(patsubst %.svg,$(OUTPUT_HTML_REL_DIR)/%.svg,$(SRC_SVG))

PANDOC_FILTER_DIR := $(PMW_MKF_DIR)/.build-system/pandoc-filters
PANDOC_SYNTAX_DIR := $(PMW_MKF_DIR)/.build-system/pandoc-syntax
# --syntax-definition="$(PANDOC_SYNTAX_DIR)/"

SRC_MD_PANDOC_OPTS := --from markdown
HTML_PANDOC_OPTS := --to html5 --standalone


.PHONY: \
	all \
	clean \
	html \
	ls-html \
	rls-html \
	clean-html \
	html-and-preview \
	preview-html \
	clean-html-only \
	html-svg-from-puml \
	clean-html-svg-from-puml \
	html-img-from-src \
	clean-html-img-from-src \
	html-svg-from-src \
	clean-html-svg-from-src \
	html-png-from-src \
	clean-html-png-from-src \
	force-clean-html-whole-dir \
	debug-vars

.PRECIOUS: $(OUTPUT_HTML_REL_DIR)/. $(OUTPUT_HTML_REL_DIR)%/.

all: \
	html

clean: \
	clean-html

html: html-img-from-src html-svg-from-puml $(OUT_HTML_FROM_MD)

html-and-preview: html preview-html

preview-html:
	xdg-open "$(OUTPUT_HTML_REL_DIR)/Home.html"

ls-html:
	ls -la "$(OUT_HTML_DIR)"

rls-html:
	ls -Rla "$(OUT_HTML_DIR)"

clean-html: clean-html-only clean-html-img
	find "$(OUT_HTML_DIR)" -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' -exec rm -r "{}" +

clean-html-only:
	rm -f $(OUT_HTML_FROM_MD)

force-clean-html-whole-dir:
	rm -rf "$(OUT_HTML_DIR)"

html-img: html-svg-from-puml html-img-from-src

clean-html-img: clean-html-svg-from-puml clean-html-img-from-src

html-svg-from-puml: $(OUT_HTML_SVG_FROM_PUML)

clean-html-svg-from-puml:
	rm -f $(OUT_HTML_SVG_FROM_PUML)

html-img-from-src: html-svg-from-src html-png-from-src

clean-html-img-from-src: clean-html-svg-from-src

html-svg-from-src: $(OUT_HTML_SVG_FROM_SRC)

clean-html-svg-from-src:
	rm -f $(OUT_HTML_SVG_FROM_SRC)

html-png-from-src: $(OUT_HTML_PNG_FROM_SRC)

clean-html-png-from-src:
	rm -f $(OUT_HTML_PNG_FROM_SRC)

debug-vars:
	@echo "PANDOC_MD_WIKI_ROOT_DIR='$(PANDOC_MD_WIKI_ROOT_DIR)'"
	@echo "PANDOC_MD_WIKI_CSS_DIR='$(PANDOC_MD_WIKI_CSS_DIR)'"
	@echo "PANDOC_MD_WIKI_OUT_PARENT_DIR='$(PANDOC_MD_WIKI_OUT_PARENT_DIR)'"
	@echo "PANDOC_MD_WIKI_OUT_BASENAME_PREFIX='$(PANDOC_MD_WIKI_OUT_BASENAME_PREFIX)'"
	@echo "PANDOC_MD_WIKI_OUT_HTML_DIR='$(PANDOC_MD_WIKI_OUT_HTML_DIR)'"
	@echo "MAKEFILE_LIST='$(MAKEFILE_LIST)'"
	@echo "PMW_MKF_DIR='$(PMW_MKF_DIR)'"
	@echo "SRC_ROOT_DIR='$(SRC_ROOT_DIR)'"
	@echo "OUT_HTML_DIR='$(OUT_HTML_DIR)'"
	@echo "OUTPUT_HTML_REL_DIR='$(OUTPUT_HTML_REL_DIR)'"
	@echo "SRC_MD='$(SRC_MD)'"
	@echo "OUT_HTML_FROM_MD='$(OUT_HTML_FROM_MD)'"
	@echo "SRC_PUML='$(SRC_PUML)'"
	@echo "OUT_HTML_SVG_FROM_PUML='$(OUT_HTML_SVG_FROM_PUML)'"


$(OUTPUT_HTML_REL_DIR)/.:
	mkdir -p "$@"

$(OUTPUT_HTML_REL_DIR)%/.:
	mkdir -p "$@"

.SECONDEXPANSION:

$(OUTPUT_HTML_REL_DIR)/%.html : %.md | $$(@D)/.
	@#echo "PANDOC_MD_WIKI_REL_PATH_FROM_PAGE_TO_ROOT_DIR='$(call FN_SRC_REL_TO_ROOT,$<)'"
	cd "$(@D)" \
	&& \
	PANDOC_MD_WIKI_REL_PATH_FROM_PAGE_TO_ROOT_DIR="$(call FN_SRC_REL_TO_ROOT,$<)" \
	pandoc \
	$(SRC_MD_PANDOC_OPTS) \
	-o "$(OUT_HTML_DIR)/$@" \
	$(HTML_PANDOC_OPTS) \
	--standalone \
	--extract-media "./media" \
	--resource-path ".:./media" \
	--metadata pagetitle="$<" \
	--highlight-style pygments \
	--css "$(PANDOC_MD_WIKI_CSS_DIR)/html.css" \
	--lua-filter="$(PANDOC_FILTER_DIR)/local-links-abs-to-rel.lua" \
	--lua-filter="$(PANDOC_FILTER_DIR)/local-links-to-target-ext.lua" \
	--lua-filter="$(PANDOC_FILTER_DIR)/imports-to-link.lua" \
	--lua-filter="$(PANDOC_FILTER_DIR)/puml-cb-to-img.lua" \
	"$(SRC_ROOT_DIR)/$<"

$(OUTPUT_HTML_REL_DIR)/%.svg : %.puml | $$(@D)/.
	plantuml -tsvg -o "$(MKF_CWD)/$(@D)/" "$<"

$(OUTPUT_HTML_REL_DIR)/%.svg : %.svg | $$(@D)/.
	cp "$<" "$@"

$(OUTPUT_HTML_REL_DIR)/%.png : %.png | $$(@D)/.
	cp "$<" "$@"
