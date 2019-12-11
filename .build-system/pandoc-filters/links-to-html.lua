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

function Link(el)
  if is_local_link(el.target) then
    local uri_ext = get_uri_extension(el.target)
    if uri_ext then
      el.target = string.gsub(el.target, "%.md$", ".html")
    else
      el.target = el.target .. ".html"
    end
  end
  return el
end
