function Para(el)
  para_str = pandoc.utils.stringify(el)

  if not para_str:find("@import") then
    return nil
  end

  -- el.target = string.gsub(el.target, "%.md", ".html")
  return pandoc.walk_block(el, {
    Str = function(el)
      print(el.t)
      print(el.text)
      if el.text == "@import" then
        return {} -- Delete this.
      else
        return pandoc.Str {"Hello"}
        -- return { 
        --   pandoc.Str {"Hello"}--,
        --   --pandoc.Image {"Diagram", link_src, "Diagram"} 
        -- }
      end
    end,
    Quoted = function(el)
      print(el.t)
      link_src = pandoc.utils.stringify(el)
      print(link_src)
      --assert(#el.content == 1)
      return nil
      -- return pandoc.Image {"Diagram", link_src}
    end
  })

end
