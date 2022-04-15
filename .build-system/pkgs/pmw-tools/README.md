Readme
======

A set of tools supporting `pandoc-md-wiki` document build system.

## `pmw-tools categorize`

```bash
$ cd "${WIKI_ROOT}"
$ pmw-tools categorize dirs -C "$PWD" -o "$PWD/.pmw.tagged-dirs.json"
# -> .pmw.tagged-dirs.json
$ pmw-tools categorize files -C "$PWD" -o "$PWD/.pmw.tagged-files.json"
# -> .pmw.tagged-files.json
```
