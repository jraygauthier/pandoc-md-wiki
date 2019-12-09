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
  if "Para" == el.t then
    for k, v in ipairs(el.content) do
      -- Look for import directive only when the paragraph begins with
      -- a cite element.
      if "Cite" == v.t and 1 == k then
        return contains_import_directive(v)
      else
        return false
      end
    end
  elseif "Cite" == el.t then
    for k, v in ipairs(el.content) do
      if "Str" == v.t and v.text == "@import" then
        assert(k == 1, "Import directive is expected to be the first element of paragraph.")
        return true
      end
    end
  else
    assert(false, "Unsupported element type!")
  end

  return false
end

local function get_quoted_str(el)
  assert( el.t == "Quoted" )
  local quoted_strs = {}
  for k, v in ipairs(el.content) do
    if "Str" == v.t then
      table.insert(quoted_strs, v.text)
    end
  end

  -- Strangely, pandoc does not insert the `Space` element
  -- in between `Str` like when printing the AST to json.
  -- We thus intersperse ourselves.
  out = table.concat(quoted_strs, " ")
  return out
end

function Para(el)
  if not contains_import_directive(el) then
    return nil
  end

  local src_uri = nil
  local attrs_import_str = ""

  local S_PARSING_IMPORT = 1
  local S_PARSING_URI = 2
  local S_PARSING_ATTRS = 3
  local state = S_PARSING_IMPORT

  local state_2_txt = {
    "Parsing import directives",
    "Parsing imported uri",
    "Parsing import attributes",
  }

  local function uri_parser(idx, el)
    if "Space" == el.t then
      -- Space between import and quoted uri.
    elseif "Quoted" == el.t then
      src_uri = get_quoted_str(el)
    else
      assert( false, "Unexpected type!" )
    end
  end

  local function attr_parser(idx, el)
    if "Str" == el.t then
      local str = el.text
      attrs_import_str = attrs_import_str .. str
    elseif "Space" == el.t then
      attrs_import_str = attrs_import_str .. " "
    elseif "Quoted" == el.t then
      local quoted_str = string.format("%q", get_quoted_str(el))
      attrs_import_str = attrs_import_str .. quoted_str
    end
  end

  local function import_parser(el)
    if "Para" == el.t then
      for k, v in ipairs(el.content) do
        --print(string.format("Para: k: %s, type(v): %s, v.t: %s", k, type(v), v.t))
        --print(string.format("Stringified: ''\n%s\n''", pandoc.utils.stringify(v)))
        if "Cite" == v.t then
          assert( contains_import_directive(v) )
          assert( S_PARSING_IMPORT == state )
          assert( 1 == k )
          state = S_PARSING_URI
        else
          if S_PARSING_URI == state then
            uri_parser(k, v)
            if src_uri then
              state = S_PARSING_ATTRS
            end
          elseif S_PARSING_ATTRS == state then
            attr_parser(k, v)
          end
        end
      end
    else
      assert( false, "Unexpected type!")
    end
  end

  import_parser(el)

  print(string.format("src_uri: %s", src_uri))
  print(string.format("whole_import_str: %s", attrs_import_str))

  local path_to_svg = string.gsub(src_uri, "%.puml", ".svg")
  print(string.format("path_to_svg: %s", path_to_svg))

  -- TODO: Use the basename of the src path with or without the puml
  -- extension as caption. Caption is the alt text in html output.
  -- `pandoc.Image (caption, src[, title[, attr]])`

  -- attr = pandoc.Attr({ width = "300px"})
  local el_img = pandoc.Image (src_uri, path_to_svg, "My Title")
  -- TODO: Diagnose this. For some obscure reason, as soon as I add some attr,
  --       the image is simply **not** part of the output.

  -- el_img.attr = { width=300}
  -- el_img.attr = { id="MyImg"}
  local el_out = pandoc.Para( el_img )
  return el_out
end
