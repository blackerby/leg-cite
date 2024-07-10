-- parser and helpers
local parser = require 'parser'

-- not strictly necessary with `pandoc lua` but this shuts up diagnostics in my editor
local pandoc = require 'pandoc'

local function build_link(t)
  local url = parser.build_url(t)
  local content = parser.build_content(t)
  return pandoc.Link(content, url)
end

return {
  {
    Str = function(elem)
      local t = parser.citation:match(elem.text)
      if t then
        return { build_link(t), pandoc.Str(parser.get_trail(t)) }
      end
    end,
  },
}
