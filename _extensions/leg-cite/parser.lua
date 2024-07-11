-- "constants"
local FIRST_CONGRESS_YEAR = 1789
local CURRENT_YEAR = os.date('*t').year
local FIRST_CONGRESS = 1
local CURRENT_CONGRESS = (CURRENT_YEAR - FIRST_CONGRESS_YEAR) // 2 + 1
local COLLECTIONS = {
  h = 'bill',
  hr = 'bill',
  hjres = 'bill',
  hconres = 'bill',
  hres = 'bill',
  hamdt = 'amendment',
  ha = 'amendment',
  pn = 'nomination',
  s = 'bill',
  sjres = 'bill',
  sconres = 'bill',
  sres = 'bill',
  samdt = 'amendment',
  sa = 'amendment',
}
local TYPES = {
  h = 'bill',
  hr = 'bill',
  hjres = 'joint-resolution',
  hconres = 'concurrent-resolution',
  hres = 'resolution',
  hamdt = 'amendment',
  ha = 'amendment',
  s = 'bill',
  sjres = 'joint-resolution',
  sconres = 'concurrent-resolution',
  sres = 'resolution',
  samdt = 'amendment',
  sa = 'amendment',
}
local CITE_TYPES = { bill = 'R.', ['joint-resolution'] = 'J.Res.', ['concurrent-resolution'] = 'Con.Res.', resolution = 'Res.', amendment = 'Amdt.' }
local BASE_URL = 'https://www.congress.gov'

-- re setup
local re = require 're'

-- confirm congress number
local function set_congress(c)
  c = tonumber(c)
  if c and c >= FIRST_CONGRESS and c <= CURRENT_CONGRESS then
    return c
  else
    return CURRENT_CONGRESS
  end
end

-- set chamber string
local function set_chamber(c)
  local first = string.sub(c, 1, 1)
  if first == 'h' then
    return 'house'
  elseif first == 's' then
    return 'senate'
  end
end

-- set type string
local function set_leg_type(t)
  return TYPES[t]
end

-- set collection
local function set_collection(c)
  return COLLECTIONS[string.lower(c)]
end

local function build_leg_url(t, congress, chamber, collection)
  local type = TYPES[t.collection]
  return string.format('%s/%s/%s/%s-%s/%s', BASE_URL, collection, congress, chamber, type, t.num)
end

local function build_nom_url(t, congress, collection)
  return string.format('%s/%s/%s/%s', BASE_URL, collection, congress, t.num)
end

local function build_url(t)
  print(t.collection)
  local congress = set_congress(t.congress)
  local collection = set_collection(t.collection)
  local chamber = set_chamber(t.collection)
  print(chamber)
  if chamber ~= nil then
    return build_leg_url(t, congress, chamber, collection)
  else
    return build_nom_url(t, congress, collection)
  end
end

local function build_leg_content(t, chamber)
  local chamber_cite = string.upper(string.sub(chamber, 1, 1))
  local num = t.num
  local leg_type = set_leg_type(t.collection)
  local type = CITE_TYPES[leg_type]
  if chamber_cite == 'S' and leg_type == 'bill' then
    type = ''
  end
  return string.format('%s.%s%s', chamber_cite, type, num)
end

local function build_nom_content(t)
  return 'PN' .. t.num
end

local function build_content(t)
  local chamber = set_chamber(t.collection)
  if chamber ~= nil then
    return build_leg_content(t, chamber)
  else
    return build_nom_content(t)
  end
end

local function get_trail(t)
  local trail
  if t.trail then
    trail = t.trail
  else
    trail = ''
  end
  return trail
end

-- grammar
local citation = re.compile [[
    citation    <- '{' {| congress? collection num '}' trail |}
    congress    <- {:congress: [1-9] [0-9]* :}
    collection  <- {:collection: (legislation / nomination) :}
    legislation <- chamber leg_type?
    chamber     <- 'h' 'r'? / 's'
    leg_type    <- amendment / resolution
    trail       <- {:trail: .* :}
    num         <- {:num: [1-9] [0-9]* :}
    amendment   <- 'a' 'mdt'?
    resolution  <- ('con' / 'j')? 'res'
    nomination  <- 'pn' / 'PN'
  ]]

return {
  citation = citation,
  build_url = build_url,
  build_content = build_content,
  get_trail = get_trail,
}
