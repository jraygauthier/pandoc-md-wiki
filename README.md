Readme
======

A simple markdown wiki build tool based on [pandoc] tailored to the needs of
development teams.

This tool is very simple and includes a pretty generic *makefile* which is meant
to be included by a makefile at the root of the markdown wiki.

The main target builds a static html 5 web site to a companion directory
alongside the markdown wiki. This directory by default has the same name as the
markdown wiki with the target added as a suffix (in this case `-html`).

This tool includes the following [pandoc-filters]:

 -  `./.build-system/pandoc-filters/local-links-abs-to-rel.lua`

    Changes local links absolute with regard to the site's root directory
    to links relative to the current `.md` file.

 -  `./.build-system/pandoc-filters/local-links-to-target-ext.lua`

    Changes local links targeting `.md` files so that once rendered to html these
    links points to the `.html` version (or any other target format extension).

 -  `./.build-system/pandoc-filters/imports-to-link.lua`

    Allow this tool to support `@import` statement like the one found
    in [markdown-preview-enhanced].

    Support it currently limited. See [TODO.md] for more details.

 -  `./.build-system/pandoc-filters/puml-cb-to-img.lua`

    Allow this tool to convert code blocks marked as `puml` to be replaced by
    the image resulting from running this code through [plantuml].

 -  More to come. See [TODO.md] for some ideas.

For the moment, we use only [pandoc-lua-filters] as these are supported natively
and as such should incur less overhead then the haskell or python ones.

Another secondary goal of this tool is to be as compatible as possible with the
pandoc backed variant of the neat [markdown-preview-enhanced] tool which is
offered as an extension to both the [vscode] and [atom] IDEs.


Requirements
------------

You should find a `shell.nix` at the root of this repository which should
make [nix] the only requirement to run this tool.

You might also want to install [direnv] tool which streamline / automate the
loading of the nix environment as you enter the repository.

So, here's what you should install:

 -  [nix-install-instructions]
 -  [direnv-install-instructions]


Testing the tool
----------------

```bash
$ cd /path/to/pandoc-md-wiki
# ..
$ nix-shell
# ..
$ make html-and-preview
```

should build a static html 5 web site from the embedded markdown file of this
repositories and open its index in your default browser.

These markdown files are meant to showcase the capabilities of this tool.


Bootstrapping your own pandoc markdown wiki
-------------------------------------------

Here's the simplest setup you need. At the root of your wiki repository (e.g.:
`/path/to/my-wiki`) you should add the following files:

`shell.nix`:

```nix
{}:

let
  pandocMdWikiSrc = builtins.fetchTarball {
    url = "https://github.com/jraygauthier/pandoc-md-wiki/archive/0185bb3f0f42fe884a6f33baea07f05588a64813.tar.gz";
    # Get this info from the output of: `nix-prefetch-url --unpack $url` where `url` is the above.
    sha256 = "0n1srznampspcd5swpxifhis873iawvf51311pa7ycanif5fsry2";
  };

  pandocMdWikiShell = import (pandocMdWikiSrc + "/shell-external.nix") { };
in

pandocMdWikiShell
```

Here, `0185bb3f0f42fe884a6f33baea07f05588a64813` right of `url` should be
replaced by the latest *git revision* of this repository.

Here, the `0n1srznampspcd5swpxifhis873iawvf51311pa7ycanif5fsry2` value right of
`sha256` should be replaced by the output of `nix-prefetch-url --unpack $url`.
Alternatively, you can change a single of its digit and attempt entering the
nix shell environment where your will be offered with the proper value for
this field.


`Makefile`:

```Makefile
MKF_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Inputs for the included makefile.
PANDOC_MD_WIKI_ROOT_DIR := $(MKF_DIR)

# Exported via 'pandoc-md-wiki/shell.nix' 'shellHook'.
ifndef PANDOC_MD_WIKI_RELEASE_MAKEFILE
  $(error Missing 'PANDOC_MD_WIKI_RELEASE_MAKEFILE' env variable.)
endif
include $(PANDOC_MD_WIKI_RELEASE_MAKEFILE)
```

`Home.md`:

```md
My home page title
==================

Here is my home page content.
```

and optionally if you mean to use *direnv*:

`envrc`:

```bash
use nix
```

You should then be able to enter the nix environment:

```bash
$ cd /path/to/my-wiki
# If you are using direnv, you should instead call
# 'direnv allow' instead of `nix-shell`.
$ nix-shell
# ..
$ make html-and-preview
xdg-open "../zilia-ocular-doc-html/Home.html"
```

This should open the rendered version of your *home page* in your default browser.


Using the gnumake build system (aka Makefile)
---------------------------------------------

**TIP**: The provided make file supports tab completion (
`make [Hit tab key here to get the list of top level tagets]`) and provides
multiple top level targets, namely:

 -  `html`: build the wiki to html without preview.
 -  `clean-html`: clean the html output leaving any dot directories at the root
    of the output (including `.git`) but also any regular files which are not a
    target of the makefile (e.g.: `README.md`, `LICENSE`, `.gitignore`, etc).
 -  `ls-html`: list the files in the html output.
 -  `rls-html`: list recursively the files in the html output.
 -  `preview-html`: preview currently built html home page if any.
 -  `clean-html-only `: clean only the html files from the html output (i.e: not
    the diagrams).
 -  `clean-html-img`: clean only the html image files from the html output
    (including the generated ones).
 -  `clean-html-svg-from-puml-only`: clean only the svg generated from the puml
    diagrams.
 -  `clean`: clean all outputs.
 -  `all`: build all outputs.
 -  `force-clean-html-whole-dir`: clean the html output directory recursively.
 -  `debug-vars`: debug the build system's internal variables.
 -  etc.


Limitations
-----------

 -  As we're using gnumake to build the wiki and that this tool notoriously does not support
    spaces in file correctly, **do not use spaces in you filenames**.

    If your really do want to support this, you might instead use a more
    advanced build system such as [shake] or [scons].

    You might even go the full fledged static site generator way with the such
    as [hakyll], [jekyll] or [hugo].

    See [TODO.md] for potential improvements aimed at fixing this.


Related tools / systems
-----------------------

 -  [pandoc-scholar]

     -  [Formatting Open Science: agilely creating multiple document formats for
        academic manuscripts with Pandoc Scholar](
        https://pandoc-scholar.github.io/)

 -  [pandocomatic]

     -  [Chapter 6. Converting a directory tree of
        documents](https://heerdebeer.org/Software/markdown/pandocomatic/#converting-a-directory-tree-of-documents)

 -  [simple-template/pandoc]

     -  [Wiki](https://github.com/simple-template/pandoc/wiki)

 -  [hakyll]

 -  [jekyll]

 -  [hugo]

 -  [pdsite]

 -  [bookdown]

 -  [pp]

    A alternative approach by implementing a very powerful preprocessor.

 -  [Pandoc Extras]

     -  [Tools for Websites](https://github.com/jgm/pandoc/wiki/Pandoc-Extras#tools-for-websites)
     -  [Workflow](https://github.com/jgm/pandoc/wiki/Pandoc-Extras#workflow)


License
-------

`pandoc-md-wiki` is licensed under the [Apache License].

This license is very permissive, so feel free to fork this repository publicly
(or even privately if absolutely required) to make it more suitable to your own
use case.

Pull request to improve this tool are an even greater way to go though.


Contributing
------------

If you have nice changes that would improve this tool, we accept pull requests.

Take not however that the tool is meant as a *generic* wiki build system, so your
changes should meet this design criteria to be accepted (i.e: changes which are
too specific to a particular use case won't be accepted).


[TODO.md]: ./TODO.md

[Apache License]: ./LICENSE
[LICENSE]: ./LICENSE

[pandoc]: https://pandoc.org/
[pandoc-filters]: https://pandoc.org/filters.html
[pandoc-lua-filters]: https://pandoc.org/lua-filters.html
[markdown-preview-enhanced]: https://shd101wyy.github.io/markdown-preview-enhanced
[vscode]: https://code.visualstudio.com/
[atom]: https://atom.io/
[nix]: https://nixos.org/nix/
[direnv]: https://direnv.net/
[nix-install-instructions]: https://nixos.org/nix/download.html
[direnv-install-instructions]: https://direnv.net/docs/installation.html

[plantuml]: https://plantuml.com/

[shake]: http://hackage.haskell.org/package/shake
[scons]: https://www.scons.org/

[pandoc-scholar]: https://github.com/pandoc-scholar/pandoc-scholar
[pandocomatic]: https://heerdebeer.org/Software/markdown/pandocomatic/
[simple-template/pandoc]: https://github.com/simple-template/pandoc
[hakyll]: https://jaspervdj.be/hakyll/
[jekyll]: https://jekyllrb.com/
[hugo]: https://gohugo.io/
[pdsite]: http://pdsite.org/
[bookdown]: https://bookdown.org/yihui/bookdown/
[pp]: https://github.com/CDSoft/pp
[Pandoc Extras]: https://github.com/jgm/pandoc/wiki/Pandoc-Extras

