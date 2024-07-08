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
        return build_link(parser.citation:match(elem.text))
      end
    end,
  },
}

-- ad hoc tests
-- TODO: investigate "formalizing" test suite
-- https://lunarmodules.github.io/busted/#defining-tests

-- local t = citation:match '118hr815'
-- local link = build_link(t)
-- print(link)
--
-- local u = citation:match '118hamdt815'
-- link = build_link(u)
-- print(link)
-- local u = citation:match '118sr815'
-- url = string.format('%s/%s/%s-%s/%s', base_url, u.congress, u.chamber, u.type, u.num)
-- print(url)

-- for k, v in pairs(t) do
--   print(k, '=', v)
-- end
-- local t = citation:match 'hr5'
-- for k, v in pairs(t) do
--   print(k, '=', v)
-- end
-- t = citation:match '119hr815'
-- for k, v in pairs(t) do
--   print(k, '=', v)
-- end

-- print(citation:match '118hr815')
-- print(citation:match '119hr815')
-- print(citation:match '-1hr815')
-- print(citation:match 'h5')
-- print(citation:match '93hr5')
-- print(citation:match '118hr815.')
