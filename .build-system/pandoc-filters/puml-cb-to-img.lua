--[[

]]--

local FILE_TYPE_COL_IDX = 1
local MIME_TYPE_COL_IDX = 2

local filetypes = {
  html5 = { "svg", "image/svg" },
  html = { "svg", "image/svg" },
  revealjs = { "svg", "image/svg" },
}
local filetype = filetypes[FORMAT][FILE_TYPE_COL_IDX] or "png"
local mimetype = filetypes[FORMAT][MIME_TYPE_COL_IDX] or "image/png"


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

function CodeBlock(block)
    if not (block.classes[1] == "puml" or block.classes[1] == "plantuml") then
      return nil -- Leave unchanged.
    end

    cmd_value = block.attributes["cmd"]
    -- print(string.format("cmd_value: %s", cmd_value))

    assert(
      cmd_value == nil or cmd_value == "true",
      "Unsupported `cmd` value: `%s`!", cmd_value)

    output_type = block.attributes["output"]
    assert(
      output_type == nil or output_type == "html" or output_type == "none",
      "Unsupported `output` value: `%s`!", output_type)

    code_block_attr = block.attributes["code_block"]
    assert(
      code_block_attr == nil or code_block_attr == "true",
      "Unsupported `code_block` value: `%s`!", output_type)

    left_column_width = block.attributes["column-left-width"]

    local column_split =
      array_has_value(block.classes, "column-split")
        or left_column_width ~= nil

    -- print(string.format("column_split: %s", column_split))

    if left_column_width == nil then
      left_column_width = "50%"
    end

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
        output_type == "none" or code_block_attr == "true") then
      show_code_block = true
      show_output = false
    end

    if block.attributes["hide"] == "true" then
      show_code_block = false
    end

    code_text = block.text
    local img
    local fname
    img, fname = puml_to_img_cached(code_text, filetype)
    -- print(string.format("puml_to_img_cached: img: %s", not not img))

    code_block = block
    output_image = pandoc.Image({pandoc.Str("puml")}, fname)
    output_para = pandoc.Para{ output_image }

    -- print(string.format("fname: %s", fname))
    -- print(string.format("show_code_block: %s", show_code_block))
    -- print(string.format("show_output: %s", show_output))

    assert(
      show_code_block or show_output,
      "Cannot show nothing!" )

    if show_code_block and show_output then
      top_div_attr = nil
      left_div_attr = nil
      right_div_attr = nil
      if column_split then
        top_div_attr = pandoc.Attr(
          nil, {"columns"})

        left_div_attr = pandoc.Attr(
          nil, {"column"}, {width = left_column_width})

        right_div_attr = pandoc.Attr(
          nil, {"column"})
      end
      code_div = pandoc.Div(code_block, left_div_attr)
      output_div = pandoc.Div(output_para, right_div_attr)

      combined_block = pandoc.Div({code_div, output_div}, top_div_attr)
      return combined_block
    end

    if show_code_block then
      return code_block
    end

    if show_output then
      return pandoc.Para{ output_image }
    end
end
