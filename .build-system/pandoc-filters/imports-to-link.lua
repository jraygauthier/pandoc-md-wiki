--[[
A pandoc filter to transform `@import "./path/to/my.puml"`
expressions into images pointing to a rendered svg.

Note that the svg is assumed to have already been produced
from the source puml file (most likely by the build system /
makefile).

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

Note that attributes are supported as well:

```md
@import "./path/to/my.puml" {#my-id .my-class width="50%" title="My title" alt="My caption"}
```

should produce an equivalent to the following pandoc markdown
(see `link_attributes` extension):

```md
![My caption](./path/to/my.svg "My title") {#my-id .my-class width="50%"}
```

]]--

local function contains_import_directive(el)
  if "Para" == el.t then
    for k, v in ipairs(el.content) do
      -- Look for import directive only when the paragraph begins with
      -- a cite element.
      if "Cite" == v.t then
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


function count_import_directives(el)
  assert( "Para" == el.t, "Unsupported element type!" )
  local count = 0
  for k, v in ipairs(el.content) do
    if "Cite" == v.t and contains_import_directive(v) then
      count = count + 1
    end
  end
  return count
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


local function parse_import_directive(el)
  assert( "Para" == el.t, "Unexpected type!")

  return coroutine.wrap(function ()
    local PARSING_DONE = ipairs(el.content), a, #el.content
    local PARSING_INCOMPLETE = ipairs(el.content), {}, 0

    local function uri_parser(it, a, i)
      local src_uri = nil
      for k, el in it, a, i do
        if "Space" == el.t then
          -- Space between import and quoted uri.
        elseif "Quoted" == el.t then
          src_uri = get_quoted_str(el)
          return src_uri, it, a, k
        else
          assert( false, "Unexpected type!" )
        end
      end

      assert( false, "Parsing incomplete!")
      return src_uri, PARSING_INCOMPLETE
    end

    local function attr_parser(it, a, i)
      local attr_str = nil

      for k, el in it, a, i do
        if "Str" == el.t then
          local str = el.text

          if string.match(str, "{") then
            attr_str = ""
          end

          attr_str = attr_str .. str

          if string.match(str, "}") then
            return attr_str, it, a, k
          end
        elseif attr_str and "Space" == el.t then
          attr_str = attr_str .. " "
        elseif attr_str and "Quoted" == el.t then
          local quoted_str = string.format("%q", get_quoted_str(el))
          attr_str = attr_str .. quoted_str
        end
      end

      if not attr_str then
        return "", PARSING_DONE
      end

      assert( false, "Parsing incomplete!")
      return nil, PARSING_INCOMPLETE
    end

    local function import_parser(it, a, i)
      for k, el in it, a, i do
        if "Cite" == el.t then
          assert( contains_import_directive(el) )
          -- assert( 1 == k )
          return true, it, a, k
        elseif "Space" == el.t then
          -- Ok, space before the cite inline.
        elseif "SoftBreak" == el.t then
          -- Ok, line break between 2 import directives.
        else
          -- print(string.format("Elmt: %s", pandoc.utils.stringify(el)))
          assert( false, string.format("Unexpected element type: '%s'!", el.t) )
        end
      end

      assert( false, "Parsing incomplete!")
      return nil, PARSING_INCOMPLETE
    end

    local import_count = count_import_directives(el)

    local it, a, i = ipairs(el.content)
    for import_idx=1, import_count do
      _, it, a, i = import_parser(it, a, i)
      local src_uri
      src_uri, it, a, i = uri_parser(it, a, i)
      assert( src_uri )
      local attrs_str
      attrs_str, it, a, i = attr_parser(it, a, i)
      assert( attrs_str )

      coroutine.yield({
        src_uri = src_uri,
        attrs_str = attrs_str
      })
    end
  end)
end


local function parse_import_attrs_raw_str(str)

  local function matches(in_str)
    return coroutine.wrap(function ()
      for k, v in string.gmatch(in_str, '([a-zA-Z0-9-_]+)=([a-zA-Z0-9-_]+)') do
        coroutine.yield(k, v)
      end

      for k, v in string.gmatch(in_str, '([a-zA-Z0-9-_]+)="([^"]+)"') do
        coroutine.yield(k, v)
      end

      for v in string.gmatch(in_str, '%#([a-zA-Z0-9-_]+)') do
        local k = "id"
        coroutine.yield(k, v)
      end

      for v in string.gmatch(in_str, '%.([a-zA-Z0-9-_]+)') do
        local k = "class"
        coroutine.yield(k, v)
      end
    end)
  end

  local id = nil
  local classes = {}
  local attrs = {}

  for k, v in matches(str) do
    if "id" == k then
      assert( not id, "Attr id already specified and was %s!", v)
      id = v
    elseif "class" == k then
      table.insert(classes, v)
    else
      assert( not attrs[k], string.format("Key: '%s' already specified and has value: '%s'!", k, attrs[k]))
      attrs[k] = v
    end

    --print(string.format("import_attrs: k: %s, v: %s", k, v))
  end

  --print(string.format("id: %s", id))
  return pandoc.Attr(id, classes, attrs)
end


local function mk_image(src_uri, import_attrs)
  local path_to_svg = string.gsub(src_uri, "%.puml", ".svg")
  -- print(string.format("path_to_svg: %s", path_to_svg))

  -- Copy table and remove attributes that should not be
  -- included as image attributes.
  img_attr = pandoc.Attr(
    import_attrs.identifier,
    import_attrs.classes,
    {table.unpack(import_attrs.attributes)})

  img_attr.attributes.alt = nil
  img_attr.attributes.title = nil

  for k, v in pairs(img_attr.attributes) do
    -- print(string.format("img_attr: k: %s, v: %s", k, v))
  end


  local img_alt = import_attrs.attributes.alt
  if not img_alt then
    -- Fallback to using the source uri as caption when no 'alt' text
    -- is specified via import attributes.
    img_alt = src_uri
  end
  local img_title = import_attrs.attributes.title

  -- `pandoc.Image (caption, src[, title[, attr]])`
  return pandoc.Image (img_alt, path_to_svg, img_title, img_attr)
end

function Para(el)
  if not contains_import_directive(el) then
    return nil
  end

  elmts_out = {}
  for import in parse_import_directive(el) do
    -- print(string.format("import.src_uri: %s", import.src_uri))
    -- print(string.format("import.attrs_str: %s", import.attrs_str))

    import_attrs = parse_import_attrs_raw_str(import.attrs_str)

    local el_img = mk_image(import.src_uri, import_attrs)
    table.insert(elmts_out, pandoc.Para( el_img ))
  end

  assert( 1 <= #elmts_out )

  return elmts_out
end
