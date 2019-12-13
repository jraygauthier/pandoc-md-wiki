Readme
======

`pandoc-md-wiki-vscode-tools`: a set of [vscode] tools, recipes and advices
meant to **improve your workflow** when *maintaining* and *building* your markdown
static site using [pandoc-md-wiki].


Activating vscode support
-------------------------

These tools can be automatically made available when you enter your
[pandoc-md-wiki] wiki's nix environment through `nix-shell` by activating the
`withVscodeSupport` option in the `shell.nix` file at the root of your wiki:

```nix
# ..
  pandocMdWikiShell = import (pandocMdWikiSrc + "/shell-external.nix") {
    # ..
    withVscodeSupport = true;
  };
# ..
```


Launching vscode from the nix-shell environment
-----------------------------------------------

Note that for these tools to work well, your should launch your
vscode instance from within your wiki's nix-shell environment:

```bash
$ cd /path/to/my/wiki
$ nix-shell # Or automatically via direnv.
$ code .
# ..
```


Vscode tasks
------------

### `pandoc-md-wiki-vscode-make-html-and-preview-selected-page`

Implement a build of the html output (i.e: `make html`) and preview the result
for the currently selected page in your default browser by opening a new tab.

As part of your [pandoc-md-wiki] repository, your should create a
`./.vscode/tasks.json` file with the following content:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build all and preview current page",
            "type": "shell",
            "command": "pandoc-md-wiki-vscode-make-html-and-preview-selected-page",
            "args": [
                "${workspaceFolder}",
                "${workspaceFolder}-html",
                "${relativeFile}",
            ],

            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
```

Once done, you should be able to select a file and the *file explorer* and
launch the build by hitting the: `Ctrl + Shift + b` *keyboard shortcut* or by
invoking the command `Tasks: Run Build Task` from the *command palette*.

TODO
----

 -  A tool that automatically create the initial content of the `./.vscode`
    folder (that is, only when files are not already present).

 -  Document the direnv extension.

 -  Document a proper [pandoc] / [pandoc-md-wiki] compatible setup for the
    [shd101wyy.markdown-preview-enhanced extension].

 -  Document a proper setup for the [jebbs.plantuml extension] extension.

 -  Document a proper setup for the [joaompinto.vscode-graphviz extension] extension.

 -  Document misc related extensions:

     -  [mushan.vscode-paste-image extension]
     -  [ban.spellright extension]

 


[vscode]: https://code.visualstudio.com/
[pandoc-md-wiki]: https://github.com/jraygauthier/pandoc-md-wiki

[pandoc]: https://pandoc.org/

[shd101wyy.markdown-preview-enhanced extension]: https://shd101wyy.github.io/markdown-preview-enhanced/#/
[jebbs.plantuml extension]: https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml
[joaompinto.vscode-graphviz extension]: https://marketplace.visualstudio.com/items?itemName=joaompinto.vscode-graphviz
[Rubymaniac.vscode-direnv extension]: https://marketplace.visualstudio.com/items?itemName=Rubymaniac.vscode-direnv
[mushan.vscode-paste-image extension]: https://marketplace.visualstudio.com/items?itemName=mushan.vscode-paste-image
