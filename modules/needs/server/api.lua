local DB = require 'core/db'
local Co = require 'core/coalesce'

local function pid(src)
  local id = GetPlayerIdentifierByType and GetPlayerIdentifierByType(src, 'license') or nil
  if not id then
    for i=0, GetNumPlayerIdentifiers(src)-1 do
      local ident = GetPlayerIdentifier(src, i)
      if ident and ident:find('license:') == 1 then id = ident break end
    end
  end
  return id or ('src:'..tostring(src))
end

local store, lastSent = {}, {}

local function ensure(src) store[src]=store[src] or {hunger=50,thirst=50,sleep=70,stamina=100,stress=0,lung_capacity=100}; return store[src] end
local function diffAndPush(src, st)
  local last = lastSent[src] or {}
  local delta, changed = {}, false
  for k,v in pairs(st) do local lv=last[k]; if lv==nil or math.abs((v or 0)-(lv or 0)) >= (NEEDS_CFG.replication.hysteresis or 1.0) then delta[k]=v; changed=true end end
  if changed then TriggerEvent('core:audit:note', 'NEEDS', ('src:%s delta'):format(src), delta) end
end

NeedsAPI = {}
function NeedsAPI.getAll(src) return ensure(src) end
function NeedsAPI.set(src, key, value) local st=ensure(src); if st[key]==nil then return false end st[key]=math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, tonumber(value) or 0)); diffAndPush(src, st); return true end
function NeedsAPI.add(src, key, delta) local st=ensure(src); if st[key]==nil then return false end return NeedsAPI.set(src, key, (st[key] or 0)+(delta or 0)) end
exports('getAll', NeedsAPI.getAll); exports('set', NeedsAPI.set); exports('add', NeedsAPI.add)

local function loadPlayer(src)
  if not NEEDS_CFG.persistence then return end
  local id = pid(src)
  local rows = DB.fetch('SELECT hunger,thirst,sleep,stamina,stress,lung FROM sc_players_needs WHERE identifier = ?', { id })
  if rows and rows[1] then local r=rows[1]; store[src]={ hunger=r.hunger or 50, thirst=r.thirst or 50, sleep=r.sleep or 70, stamina=r.stamina or 100, stress=r.stress or 0, lung_capacity=r.lung or 100 } end
end
local function savePlayer(src)
  if not NEEDS_CFG.persistence then return end
  local id = pid(src); local st = ensure(src)
  DB.save('sc_players_needs', { identifier=id, hunger=math.floor(st.hunger), thirst=math.floor(st.thirst), sleep=math.floor(st.sleep), stamina=math.floor(st.stamina), stress=math.floor(st.stress), lung=math.floor(st.lung_capacity), schema_version=1 }, {
    builder=function(tbl,d) return ([=[
      INSERT INTO sc_players_needs(identifier,hunger,thirst,sleep,stamina,stress,lung,schema_version)
      VALUES(?,?,?,?,?,?,?,?)
      ON DUPLICATE KEY UPDATE hunger=VALUES(hunger),thirst=VALUES(thirst),sleep=VALUES(sleep),
        stamina=VALUES(stamina),stress=VALUES(stress),lung=VALUES(lung),schema_version=VALUES(schema_version)
    ]=]), {d.identifier,d.hunger,d.thirst,d.sleep,d.stamina,d.stress,d.lung,d.schema_version} end })
end
AddEventHandler('playerJoining', function() local src=source Citizen.SetTimeout(500, function() loadPlayer(src) end) end)
AddEventHandler('playerDropped', function() local src=source savePlayer(src) store[src]=nil lastSent[src]=nil end)
AddEventHandler('core:flush:all', function() for _,src in ipairs(GetPlayers()) do savePlayer(src) end end)
