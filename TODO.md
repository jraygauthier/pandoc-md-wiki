Todo
====

Build system
------------

 -  A system of tag in yaml front matter allowing to build only part of the
    files.

    This would be useful in particular for building only part of the wiki meant
    for a particular audience (public, work, such or such group, etc).

    In directory dot yaml file would allow to add or remove tags to all document
    beneat this directory as if had been provided directly in the file's front
    matter (thus allowing a concept of private / public by default).

    A `+@tag` `-@tag` and `@tag` could be used (how about `#` tag instead of `@`
    ones?).

    Going even further, it would even be possible to tag sections of the files
    (i.e: a tag in the title would mean the whole section and its sub).

    Going again even further, pandoc native divs could be used to to tag arbitrary
    parts of the document.

    A filter would be responsible for processing the tags, maybe generating a
    custom make file.

    Some remaining questions:

     -  Name of the dot file.
     -  Kind of tag used.
     -  How to tag non md files individually (via dot file?).

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

    Alternatively, it might be better to simply make those from `*.md` files
    making use of the @import directive to compose the final documents. Nice
    things with this approach:

     -  In editor html preview of the resulting document.
     -  Granular control over how the document is transcluded.
     -  Can surround the transclusions with actual content.

    We could also decide to reuse the pandoc template format. Not sure tough
    if that can be of any use for the docx like binary formats.

### Html

 -  Error on nonexistent image links.

    See [Features/LinkSupport/Home](Features/LinkSupport/Home.md)

 -  Add tarball / zip targets of the html content.

 -  Add opt-out option of in output generated files:

    Encoded as a set of potentially overridable template files (using mustaches?)
    under `.html/generated`.

     -  Convenience `Makefile` which would have the all, clean, tarball, zip and
        individual file targets simply deferring to the original makefile.

     -  `shell.nix` / `.envrc` allowing users to use the make file.

        When companion source repo is found beside this one, its `shell.nix` would be
        used.

        Otherwise, When generated, the current git sha1 of the source repo would
        be taken allowing `shell.nix` to function without the companion source
        repo but also for reproducibility.

     -  `Readme.md` describing how to build this output, referencing to source
        repository, describing exactly how it was generated (source revision /
        clean or unclean) and could be generated again.

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
