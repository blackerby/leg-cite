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
  if c == 'h' then
    return 'house'
  else
    return 'senate'
  end
end

-- set type string
local function set_type(t)
  return TYPES[t]
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
  if t.type == nil then
    type = 'bill'
  else
    type = t.type
  end
  local url = string.format('%s/%s/%s/%s-%s/%s', BASE_URL, collection, t.congress, t.chamber, type, t.num)
  return url
end

local function build_content(t)
  local chamber = string.upper(string.sub(t.chamber, 1, 1))
  local num = t.num
  local type = CITE_TYPES[t.type]
  if type == nil then
    type = ''
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

-- parser
-- TODO: investigate rewriting with re syntax
local natural = ((loc.digit - '0') * loc.digit ^ 0) ^ 1
local punct = Cg(loc.punct ^ 0, 'punct')
local congress = natural
local resolution = (P 'con' + P 'j') ^ -1 * P 'res'
local amendment = P 'a' * P 'mdt' ^ -1
local house = Cg(P('h', 'chamber') / set_chamber, 'chamber') * Cg((resolution + P 'r' + amendment) ^ -1 / set_type, 'type')
local senate = Cg(P('s', 'chamber') / set_chamber, 'chamber') * Cg((resolution + amendment) ^ -1 / set_type, 'type')
local citation = P '{' * Ct(Cg(congress ^ -1 / confirm_congress, 'congress') * (house + senate) * Cg(natural, 'num') * P '}' * punct)

return {
  citation = citation,
  build_url = build_url,
  build_content = build_content,
  get_punct = get_punct,
}
