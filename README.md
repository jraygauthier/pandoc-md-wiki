Readme
======

A simple markdown wiki build tool based on [pandoc] tailored to needs of
development teams.

This tool is very simple and includes a pretty generic *makefile* which is meant
to be included by a makefile at the root of the markdown wiki.

The main target builds a static html 5 web site to a companion directory
alongside the markdown wiki. This directory by default has the same name as the
markdown wiki with the target added as a suffix (in this case `-html`).

This tool includes the following [pandoc-filters]:

 -  TODO: List and describe the provided filters.

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

TODO: Document this.


Limitations
-----------

 -  As we're using gnumake to build the wiki and that this tool notoriously does not support
    spaces in file correctly, **do not use spaces in you filenames**.

    If your really do want to support this, you might instead use a more
    advanced build system such as [shake] or [scons].

    You might even go the full fledged static site generator way with the such
    as [hakyll], [jekyll] or [hugo].


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

[shake]: http://hackage.haskell.org/package/shake
[scons]: https://www.scons.org/
[hakyll]: https://jaspervdj.be/hakyll/
[jekyll]: https://jekyllrb.com/
[hugo]: https://gohugo.io/
