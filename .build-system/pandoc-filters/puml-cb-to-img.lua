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

local function puml_to_img(puml_code, out_filetype)
    local out_img = pandoc.pipe("plantuml", {"-t" .. out_filetype, "-p"}, puml_code)
    return out_img
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


    local cmd_mode = false
    local show_code_block = false
    local show_output = true

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

    -- print(string.format("show_code_block: %s", show_code_block))

    left_column_width = block.attributes["column-left-width"]

    local column_split =
      array_has_value(block.classes, "column-split")
        or left_column_width ~= nil

    -- print(string.format("column_split: %s", column_split))

    if left_column_width == nil then
      left_column_width = "50%"
    end

    -- print(string.format("show_output: %s", show_output))

    assert(
      show_code_block or show_output,
      "Cannot show nothing!" )

    code_text = block.text
    local fname = pandoc.sha1(code_text) .. "." .. filetype
    local img = puml_to_img(code_text, filetype)
    pandoc.mediabag.insert(fname, mimetype, img)

    code_block = block
    output_image = pandoc.Image({pandoc.Str("puml")}, fname)
    output_para = pandoc.Para{ output_image }

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
