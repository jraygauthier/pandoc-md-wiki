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

 -  Build to linear pdf

    Requiring user provided listing of files.

 -  Build to linear docx

    Requiring user provided listing of files.


Filters
-------

 -  Inline plantuml support.
 -  Inline dot support.
 -  Inline haskell diagrams.
 -  Inline vega / vega-lite diagram.
 -  Code chunk support filter
 -  TikZ support.
 -  Vega support.

### `links-to-html.lua`

 -  Only local wiki links should have their extension changed to `html`.
 -  Local wiki links when without extension should be given the `html` one by default.


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
