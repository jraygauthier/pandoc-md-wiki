local function get_uri_scheme(uri)
  local _, _, uri_scheme = string.find(uri, "^([a-z]+)://")
  return uri_scheme
end

local function is_local_link(uri)
  return nil == get_uri_scheme(uri)
end

local function remove_uri_anchor(uri)
  local without_anchor = string.gsub(uri, "#.+$", "")
  return without_anchor
end

local function remove_uri_anchor_and_query(uri)
  local without_anchor = remove_uri_anchor(uri)
  local without_query = string.gsub(without_anchor, "?.+$", "")
  return without_query
end

local function get_uri_query_fragment(uri)
  local without_anchor = remove_uri_anchor(uri)
  local _, _, query_str = string.find(without_anchor, "(%?.+)$")
  return query_str or ""
end

local function get_uri_anchor_fragment(uri)
  local _, _, anchor_str = string.find(uri, "(#.+)$")
  return anchor_str or ""
end

local function get_uri_query_and_anchor_fragment(uri)
  return get_uri_query_fragment(uri) .. get_uri_anchor_fragment(uri)
end

local function get_uri_extension(uri)
  local path = remove_uri_anchor_and_query(uri)
  local _, _, uri_ext = string.find(path, "%.([^/]+)$")
  return uri_ext
end

local function replace_uri_extension(uri, new_ext)
  local anchor_and_query_str = get_uri_query_and_anchor_fragment(uri)

  local wo_anchor_wo_query = remove_uri_anchor_and_query(uri)

  local wo_ext = string.gsub(wo_anchor_wo_query, "%.[^/]+$", "")

  _, _, stem = string.find(wo_ext, "([^/]*)$")
  if "" == stem then
    -- This is a current page anchor and/or query
    -- (e.g.: "[Link to my anchor](#my-anchor)")
    -- Do not touch the uri.
    return uri
  end

  local new_uri = wo_ext .. "." .. new_ext .. anchor_and_query_str
  return new_uri
end

local function is_uri_to_directory(uri)
  local path = remove_uri_anchor_and_query(uri)
  return not not string.find(path, "/$") -- booleanize the result.
end


local source_ext = "md"
local target_ext = "html"


function Link(el)
  if not is_local_link(el.target) then
    return nil -- Leave link untouched.
  end

  local uri_ext = get_uri_extension(el.target)

  if not uri_ext then
    if is_uri_to_directory(el.target) then
      return nil -- Leave link untouched.
    end

    el.target = replace_uri_extension(el.target, target_ext)
    return el
  end

  if uri_ext ~= source_ext then
    return nil -- Leave link untouched.
  end

  el.target = replace_uri_extension(el.target, target_ext)
  return el
end
