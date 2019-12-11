local function get_uri_scheme(uri)
  local _, _, uri_scheme = string.find(uri, "^([a-z]+)://")
  return uri_scheme
end

local function is_local_link(uri)
  return nil == get_uri_scheme(uri)
end

local rel_path_to_site_root_dir = os.getenv("PANDOC_MD_WIKI_REL_PATH_FROM_PAGE_TO_ROOT_DIR")

function Link(el)
  if not is_local_link(el.target) then
    return nil -- Leave link untouched.
  end

  -- print(string.format("site_root_dir: %s", rel_path_to_site_root_dir))

  el.target = string.gsub(el.target, "^/", "../../")
  return el
end
