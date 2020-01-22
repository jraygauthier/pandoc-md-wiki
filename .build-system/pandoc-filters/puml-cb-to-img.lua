--[[

]]--

local FILE_TYPE_COL_IDX = 1
local MIME_TYPE_COL_IDX = 2

local filetypes = {
  html5 = { "svg", "image/svg" },
  html = { "svg", "image/svg" },
}
local filetype = filetypes[FORMAT][FILE_TYPE_COL_IDX] or "svg"
local mimetype = filetypes[FORMAT][MIME_TYPE_COL_IDX] or "image/svg"

local function puml_to_img(puml_code, out_filetype)
    local out_img = pandoc.pipe("plantuml", {"-t" .. filetype, "-p"}, puml_code)
    return out_img
end

function CodeBlock(block)
    if not (block.classes[1] == "puml") then
      return nil -- Leave unchanged.
    end

    code_text = block.text
    local fname = pandoc.sha1(code_text) .. "." .. filetype
    local img = puml_to_img(code_text, filetype)
    pandoc.mediabag.insert(fname, mimetype, img)
    return pandoc.Para{ pandoc.Image({pandoc.Str("puml")}, fname) }
end
