--[[
A pandoc filter to transform `@import "./path/to/my.puml"`
into images pointing to a rendered svg.

Basically, a `@import "./path/to/my.puml"` expression
will be transformed into the following markdown link:

```md
![./path/to/my.puml](./path/to/my.svg)
```

the `./path/to/my.puml` shown as the alt text in a html
output:

```html
<img src="./path/to/my.svg" alt="./path/to/my.puml" />
```
]]--

local function contains_import_directive(el)
  local import_detected = false
  pandoc.walk_block(el, {
    Str = function(el)
      if el.text == "@import" then
        import_detected = true
      end
      return nil -- Keep as was.
    end })

  -- print(string.format("import_detected=%s", import_detected))
  return import_detected
end

function Para(el)
  if not contains_import_directive(el) then
    return nil
  end

  return pandoc.walk_block(el, {
    Str = function(el)
      -- print(string.format("Type: %s, Content: %s", el.t, el.text))
      if el.text == "@import" then
        return {} -- Drop this inline.
      else
        -- Keep the inline. This is our path to the puml file. It will be
        -- transformed to an image by the `Quoted` function.
        return nil
      end
    end,

    Quoted = function(el)
      content_str = pandoc.utils.stringify(el)
      -- print(string.format("Type: %s, Content: ''\n%s\n''", el.t, content_str))
      path_to_puml_str = el.content[1].text
      path_to_svg = string.gsub(path_to_puml_str, "%.puml", ".svg")
      -- TODO: Use the basename of the src path with or without the puml
      -- extension as caption. Caption is the alt text in html output.
      -- `pandoc.Image (caption, src[, title[, attr]])`
      out = pandoc.Image (path_to_puml_str, path_to_svg)
      return out
    end,

    Inline = function(el)
      -- print(string.format("Type: %s, Content: ''\n%s\n''", el.t, pandoc.utils.stringify(el)))
      return {} -- Drop this inline.
    end,
  })

end
