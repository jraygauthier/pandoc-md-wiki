
PMW_MKF_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

MKF_CWD := $(shell pwd)

ifndef PANDOC_MD_WIKI_ROOT_DIR
  PANDOC_MD_WIKI_ROOT_DIR := $(PMW_MKF_DIR)
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
OUT_HTML_DIR := $(PANDOC_MD_WIKI_OUT_HTML_DIR)
OUTPUT_HTML_REL_DIR := $(shell realpath --relative-to "$(MKF_CWD)" "$(OUT_HTML_DIR)")

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

SRC_MD_PANDOC_OPTS := --from markdown
HTML_PANDOC_OPTS := --to html5 --standalone --lua-filter="$(PANDOC_FILTER_DIR)/links-to-html.lua" --lua-filter="$(PANDOC_FILTER_DIR)/imports-to-link.lua"

.PHONY: \
	all \
	clean \
	clean-html-only \
	debug-vars \
	mk-output-dir-html \
	clean-html \
	html-svg-from-puml \
	html-svg-from-src \
	html \
	html-and-preview \
	preview-html

.PRECIOUS: $(OUTPUT_HTML_REL_DIR)/. $(OUTPUT_HTML_REL_DIR)%/.

all: \
	html

clean: \
	clean-html

debug-vars:
	@echo "PANDOC_MD_WIKI_ROOT_DIR='$(PANDOC_MD_WIKI_ROOT_DIR)'"
	@echo "PANDOC_MD_WIKI_OUT_PARENT_DIR='$(PANDOC_MD_WIKI_OUT_PARENT_DIR)'"
	@echo "PANDOC_MD_WIKI_OUT_BASENAME_PREFIX='$(PANDOC_MD_WIKI_OUT_BASENAME_PREFIX)'"
	@echo "PANDOC_MD_WIKI_OUT_HTML_DIR='$(PANDOC_MD_WIKI_OUT_HTML_DIR)'"
	@echo "MAKEFILE_LIST='$(MAKEFILE_LIST)'"
	@echo "PMW_MKF_DIR='$(PMW_MKF_DIR)'"
	@echo "OUT_HTML_DIR='$(OUT_HTML_DIR)'"
	@echo "OUTPUT_HTML_REL_DIR='$(OUTPUT_HTML_REL_DIR)'"
	@echo "SRC_MD='$(SRC_MD)'"
	@echo "OUT_HTML_FROM_MD='$(OUT_HTML_FROM_MD)'"
	@echo "SRC_PUML='$(SRC_PUML)'"
	@echo "OUT_HTML_SVG_FROM_PUML='$(OUT_HTML_SVG_FROM_PUML)'"


clean-html:
	rm -rf "$(OUT_HTML_DIR)"

clean-html-only:
	rm $(OUT_HTML_FROM_MD)

clean-html-svg-from-puml-only:
	rm $(OUT_HTML_SVG_FROM_PUML)

html-svg-from-puml: $(OUT_HTML_SVG_FROM_PUML)

html-svg-from-src: $(OUT_HTML_SVG_FROM_SRC)

html-png-from-src: $(OUT_HTML_PNG_FROM_SRC)

html-img-from-src: html-svg-from-src html-png-from-src

html: html-img-from-src html-svg-from-puml $(OUT_HTML_FROM_MD)

html-and-preview: html preview-html

preview-html:
	xdg-open "$(OUTPUT_HTML_REL_DIR)/Home.html"


$(OUTPUT_HTML_REL_DIR)/.:
	mkdir -p "$@"

$(OUTPUT_HTML_REL_DIR)%/.:
	mkdir -p "$@"

.SECONDEXPANSION:

$(OUTPUT_HTML_REL_DIR)/%.html : %.md | $$(@D)/.
	pandoc $(SRC_MD_PANDOC_OPTS) -o "$@" $(HTML_PANDOC_OPTS) --resource-path "$(@D)" --metadata pagetitle="$<" "$<"

$(OUTPUT_HTML_REL_DIR)/%.svg : %.puml | $$(@D)/.
	plantuml -tsvg -o "$(MKF_CWD)/$(@D)/" "$<"

$(OUTPUT_HTML_REL_DIR)/%.svg : %.svg | $$(@D)/.
	cp "$<" "$@"

$(OUTPUT_HTML_REL_DIR)/%.png : %.png | $$(@D)/.
	cp "$<" "$@"
