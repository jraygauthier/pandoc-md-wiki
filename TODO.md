Todo
====

Build system
------------

 -  Alternative build system

    Possibly: shake, scons, etc.

     -  Supporting spaces in file paths.

 -  Experiment with finding a good default ordering for pages
    when outputting to a linear document (e.g.: pdf, docx, epub)
    via a lua filter that would create a tree of link.


### Gnumake

 -  Support graphviz dot files.
 -  Support haskell diagrams.

 -  Build to linear pdf / docx

    Requiring user provided listing of files.

    Most likely through a well known yaml dot file in the sources of the wiki.


### Pandoc html recipe

 -  Error on nonexistent image links.

    See [Features/LinkSupport/Home](Features/LinkSupport/Home.md)

### Html clean

 -  `clean-html` -> Remove directory when empty.


Filters
-------

 -  Inline dot support.
 -  Inline haskell diagrams.
 -  Inline vega / vega-lite diagram.
 -  Code chunk support filter
 -  TikZ support.
 -  Vega support.

### `local-links-to-target-ext.lua`

 -  Links to section not handled.

### `puml-cb-to-img.lua`

 -  Capture image related attributes and forward others to the image element.
 -  Support force render as code block (`code_block=true`).


### `imports-to-link.lua`

 -  Support graphviz dot files.
 -  Support haskell diagrams.
 -  Support importing another markdown page.
 -  Support importing common images formats.
 -  Support erd diagrams (selective code chunk).
 -  Support importing pdf files.
 -  Support force render as code block (`code_block=true`).

 -  Support file as code chunk.

    Should need a by default mecanism that allow for a chunk-wise accept
    to prevent arbitrary code to endanger a machine.

    A set of *trusted* uri can be used too to prevent too much verbosity.
