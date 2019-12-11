local function get_uri_scheme(uri)
  local _, _, uri_scheme = string.find(uri, "^([a-z]+)://")
  return uri_scheme
end

local function is_local_link(uri)
  return nil == get_uri_scheme(uri)
end

local function get_uri_extension(uri)
  local _, _, uri_ext = string.find(uri, "%.([a-zA-Z0-9]+)$")
  return uri_ext
end

local source_ext = "md"
local target_ext = "html"


function Link(el)
  if not is_local_link(el.target) then
    return nil -- Leave link untouched.
  end

  local uri_ext = get_uri_extension(el.target)

  if not uri_ext then
    el.target = el.target .. "." .. target_ext
    return el
  end

  if uri_ext ~= source_ext then
    return nil -- Leave link untouched.
  end

  el.target = string.gsub(el.target, "%." .. source_ext .. "$", "." .. target_ext)
  return el
end
