--[[

]]--

local FILE_TYPE_COL_IDX = 1

local doc_format_to_puml_out_filetype = {
  html5 = "svg",
  html = "svg",
  revealjs = "svg",
}

local user_output_type_to_puml_out_filetype = {
  html = "svg",
  png = "png",
  none = "svg", -- Use svg by default.
}

local filetype2mimetype = {
  svg = "image/svg",
  png = "image/png",
}

local function get_puml_output_filetype(user_output_type)
  local filetype = doc_format_to_puml_out_filetype[FORMAT] or "png"
  if user_output_type ~= nil then
    filetype = user_output_type_to_puml_out_filetype[user_output_type]
    assert( filetype ~= nil, "Invalid user output type!")
  end
  return filetype
end

local function get_mimetype(filetype)
  out_mimetype = filetype2mimetype[filetype]
  assert( out_mimetype ~= nil, "Unsupported file type!")
  return out_mimetype
end

local function fetch_resource_workaround(rel_filename)
  local resource_path = PANDOC_STATE.resource_path
  -- print(string.format(
  --   "resource_path: %s", table.concat(resource_path, ', ')))
  for _, rdir in ipairs(resource_path) do
    -- print(string.format("rdir: %s", rdir))
    filename = rdir .. "/" .. rel_filename
    -- print(string.format("filename: %s", filename))
    file = io.open (filename)
    if file ~= nil then
      content = file:read("*all")
      file:close()
      assert( content ~= nil, "Unexpected nil ressource file content!" )
      return content
    end
  end
end


local function fetch_resource(rel_filename)
  -- Broken code. Should report an issue to pandoc repo.
  -- There is no way to recover from lua, it fails on
  -- the haskell side.
  -- [pandoc/MediaBag.hs:fetch](https://github.com/jgm/pandoc/blob/8ed749702ff62bc41a88770c7f93a283a20a2a42/src/Text/Pandoc/Lua/Module/MediaBag.hs#L117)
  -- Using `fetch_resource_workaround` in the meantime.
  local fetch_status
  local mt
  local img
  fetch_status, mt, content =
   pcall(function ()
     -- error("My Error")
     return pandoc.mediabag.fetch(rel_filename, ".")
   end)
  -- print(string.format(
  --   "fetch: fetch_status: %s, mt: %s",
  --   fetch_status, mt))
  if not fetch_status then
    return nil
  end

  return content
end

local function puml_to_img(puml_code, out_filetype)
    local out_img = pandoc.pipe("plantuml", {"-t" .. out_filetype, "-p"}, puml_code)
    return out_img
end

local function puml_to_img_cached(puml_code, out_filetype)
  local fname = pandoc.sha1(puml_code) .. "." .. out_filetype

  local mimetype = get_mimetype(out_filetype)
  local img
  _, img = pandoc.mediabag.lookup(fname)
  -- print(string.format("lookup: img: %s", not not img))
  if img == nil then
    img = fetch_resource_workaround(fname)
    -- print(string.format("fetch_resource_workaround: img: %s", not not img))
    if img ~= nil then
      pandoc.mediabag.insert(fname, mimetype, img)
    end
  end

  if img == nil then
    img = puml_to_img(puml_code, out_filetype)
    -- print(string.format("puml_to_img: img: %s", not not img))
    pandoc.mediabag.insert(fname, mimetype, img)
  end

  return img, fname
end

local function array_has_value(array, value)
    for i, v in ipairs(array) do
      if v == value then
        return true
      end
    end

    return false
end

local function array_concat(a, b)
  o = {table.unpack(a)}
  for _, v in pairs(b) do
    table.insert(o, v)
  end
  return o
end


local function table_merge(a, b)
  -- When a key has the same name in both tables
  -- we will keep the b value.
  o = {}
  for k, v in pairs(a) do
    o[k] = v
  end
  for k, v in pairs(b) do
    o[k] = v
  end
  return o
end

local function attr_extend_classes(attr, xs)
  attr.classes =
    array_concat(attr.classes, xs)
end

local function attr_extend_attributes(attr, xs)
  attr.attributes =
    table_merge(attr.attributes, xs)
end

local function attr_set_width(attr, value)
  attr.attributes.width = value
end

local function div_extend_content(div, xs)
  div.content =
    array_concat(div.content, xs)
end

function CodeBlock(block)
    if not (block.classes[1] == "puml" or block.classes[1] == "plantuml") then
      return nil -- Leave unchanged.
    end

    local code_block = block

    local content_div_attr = pandoc.Attr(
      nil, {"pmw", "plantuml-content"})

    local code_div_attr = pandoc.Attr(
      nil, {"pmw", "plantuml-code"})


    code_block_attr = block.attributes["code_block"]
    assert(
      code_block_attr == nil or code_block_attr == "true",
      "Unsupported `code_block` value: `%s`!", output_type)

    -- When only code block is requested we return early
    -- so as to avoid calling planuml which might fail
    -- as the code might be erroneous.
    if code_block_attr == "true" then
      local content_div = pandoc.Div({}, content_div_attr)
      local code_div = pandoc.Div(code_block, code_div_attr)
      div_extend_content(content_div, {code_div})
      --return content_div
      -- TODO: Reconsider at some point. For the time
      -- being, we will leave it untouched.
      return nil
    end


    cmd_value = block.attributes["cmd"]
    -- print(string.format("cmd_value: %s", cmd_value))

    assert(
      cmd_value == nil or cmd_value == "true",
      "Unsupported `cmd` value: `%s`!", cmd_value)

    output_type = block.attributes["output"]
    assert(
      output_type == nil
        or output_type == "html"
        or output_type == "png"
        or output_type == "none",
      "Unsupported `output` value: `%s`!", output_type)

    left_column_width = block.attributes["column-left-width"]

    local column_split =
      array_has_value(block.classes, "column-split")
        or left_column_width ~= nil

    -- print(string.format("column_split: %s", column_split))

    local cmd_mode = false
    local show_code_block = false
    local show_output = true

    if column_split then
      -- When column split is specified, we will have the
      -- sensible default to show both the code and the
      -- output as this is most certainly what is required.
      show_code_block = true
      show_output = true
    end

    if output_type == "none" then
      show_output = false
    end

    if cmd_value == "true" then
      cmd_mode = true
      show_code_block = true
    end

    if not cmd_mode and (
        output_type == "none") then
      show_code_block = true
      show_output = false
    end

    if block.attributes["hide"] == "true" then
      show_code_block = false
    end

    local code_text = block.text
    local puml_output_type = get_puml_output_filetype(output_type)

    local img
    local fname
    img, fname = puml_to_img_cached(code_text, puml_output_type)
    -- print(string.format("puml_to_img_cached: img: %s", not not img))

    local output_image = pandoc.Image({pandoc.Str("puml")}, fname)
    local output_para = pandoc.Para{ output_image }

    -- print(string.format("fname: %s", fname))
    -- print(string.format("show_code_block: %s", show_code_block))
    -- print(string.format("show_output: %s", show_output))

    assert(
      show_code_block or show_output,
      "Cannot show nothing!" )

    local output_div_attr = pandoc.Attr(
      nil, {"pmw", "plantuml-output"})

    if show_code_block and show_output and column_split then
      attr_extend_classes(content_div_attr, {"columns"})
      attr_extend_classes(code_div_attr, {"column"})
      attr_extend_classes(output_div_attr, {"column"})

      --print(string.format("left_column_width: %s", left_column_width))
      if left_column_width ~= nil then
        attr_set_width(code_div_attr, left_column_width)
      end
    end

    local content_div = pandoc.Div({}, content_div_attr)
    local code_div = pandoc.Div(code_block, code_div_attr)
    local output_div = pandoc.Div(output_para, output_div_attr)

    if show_code_block and show_output then
      div_extend_content(content_div, {code_div, output_div})
      return content_div
    end

    if show_code_block then
      div_extend_content(content_div, {code_div})
      return content_div
    end

    if show_output then
      div_extend_content(content_div, {output_div})
      return content_div
    end
end
