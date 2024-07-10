-- "constants"
local FIRST_CONGRESS_YEAR = 1789
local CURRENT_YEAR = os.date('*t').year
local FIRST_CONGRESS = 1
local CURRENT_CONGRESS = (CURRENT_YEAR - FIRST_CONGRESS_YEAR) // 2 + 1
local TYPES = { r = 'bill', jres = 'joint-resolution', conres = 'concurrent-resolution', res = 'resolution', amdt = 'amendment', a = 'amendment' }
local CITE_TYPES = { bill = 'R.', ['joint-resolution'] = 'J.Res.', ['concurrent-resolution'] = 'Con.Res.', resolution = 'Res.', amendment = 'Amdt.' }
local BASE_URL = 'https://www.congress.gov'

-- lpeg setup
local lpeg = require 'lpeg'
local P, Ct, Cg = lpeg.P, lpeg.Ct, lpeg.Cg
local loc = lpeg.locale()

-- re setup
local re = require 're'

-- confirm congress number
local function confirm_congress(c)
  c = tonumber(c)
  if c and c >= FIRST_CONGRESS and c <= CURRENT_CONGRESS then
    return c
  else
    return CURRENT_CONGRESS
  end
end

-- set chamber string
local function set_chamber(c)
  if c == 'h' or c == 'hr' then
    return 'house'
  else
    return 'senate'
  end
end

-- set type string
local function set_type(t)
  local type = TYPES[t]
  if t ~= nil then
    return type
  else
    return 'bill'
  end
end

-- set collection
local function set_collection(c)
  if c == 'amendment' then
    return c
  else
    return 'bill'
  end
end

-- should error out if any key is nil
local function build_url(t)
  local collection = set_collection(t.type)
  local type
  if t.type ~= nil then
    type = t.type
  else
    type = 'bill'
  end
  local url = string.format('%s/%s/%s/%s-%s/%s', BASE_URL, collection, t.congress, t.chamber, type, t.num)
  return url
end

local function build_content(t)
  local chamber = string.upper(string.sub(t.chamber, 1, 1))
  local num = t.num
  local type = CITE_TYPES[t.type]
  if type == nil then
    if chamber == 'H' then
      type = 'R.'
    else
      type = ''
    end
  end
  local cite = string.format('%s.%s%s', chamber, type, num)
  return cite
end

local function get_punct(t)
  local punct

  if t.punct then
    punct = t.punct
  else
    punct = ''
  end
  return punct
end

-- grammar
local citation = re.compile(
  [[
    citation <- '{' {| congress cite num '}' punct |}
    congress <- {:congress: natural? -> confirm_congress :}
    num <- {:num: natural :}
    cite <- chamber type
    natural <- [1-9] [0-9]*
    punct <- {:punct: %p* :}
    type <- {:type: (resolution / amendment)? -> set_type :}
    resolution <- ('con' / 'j')? 'res'
    amendment <- 'a' 'mdt'?
    chamber <- {:chamber: 'h' 'r'? / 's' -> set_chamber :}
  ]],
  { confirm_congress = confirm_congress, set_type = set_type, set_chamber = set_chamber }
)

return {
  citation = citation,
  build_url = build_url,
  build_content = build_content,
  get_punct = get_punct,
}
