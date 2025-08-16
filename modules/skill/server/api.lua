local rules = require 'server/rules'
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

local store, dr, rl = {}, {}, {}

local function clampRank(xp) local b=SKILL_CFG.xp_curve.bands; if xp<b[1] then return 0 elseif xp<(b[1]+b[2]) then return 1 elseif xp<(b[1]+b[2]+b[3]) then return 2 else return 3 end end
local function ensure(src) if not store[src] then store[src]={}; for _,k in ipairs(SKILL_CFG.keys) do store[src][k]={ xp=0, rank=0 } end end if not dr[src] then dr[src]={} end return store[src] end
local function rlKey(src,key,limit,win) local t=GetGameTimer(); rl[src]=rl[src] or {}; rl[src][key]=rl[src][key] or {n=0,ts=t}; local b=rl[src][key]; if t-b.ts>win then b.n=0 b.ts=t end; if b.n>=limit then return false end b.n=b.n+1 return true end
local function applyDR(src,key,base) if not SKILL_CFG.daily_dr.enable then return base end local mult=dr[src][key] or SKILL_CFG.daily_dr.base; local out=math.max(1,math.floor(base*mult)); mult=math.max(SKILL_CFG.daily_dr.min_mult, mult - SKILL_CFG.daily_dr.decay_per_award); dr[src][key]=mult; return out end

SkillAPI = {}

function SkillAPI.addXP(src,key,amount,cause)
  if not src or not key then return false,'bad_args' end
  if not rlKey(src,('p:%s'):format(key),SKILL_CFG.rate_limit.per_key_per_min,60000) then return false,'rate_limited' end
  if not rlKey(src,'p:all',SKILL_CFG.rate_limit.per_player_per_min,60000) then return false,'rate_limited' end
  local tab=ensure(src); if not tab[key] then return false,'unknown_key' end
  local base=math.max(1, math.floor(tonumber(amount) or 1))
  local gain=applyDR(src,key,base)
  tab[key].xp = tab[key].xp + gain
  tab[key].rank = clampRank(tab[key].xp)
  Co.push(src, 'skill', { key=key, xp=tab[key].xp, rank=tab[key].rank })
  return true, tab[key]
end

function SkillAPI.get(src,key) local tab=ensure(src) return tab[key] end
function SkillAPI.getAll(src) local tab=ensure(src) return json.decode(json.encode(tab)) end

exports('addXP', SkillAPI.addXP); exports('get', SkillAPI.get); exports('getAll', SkillAPI.getAll)

RegisterNetEvent('skill:grant', function(evt,payload) local src=source local key,amt = rules.computeXP(evt,payload); if not key then return end SkillAPI.addXP(src,key,amt,evt) end)

-- Persistence
local function loadPlayer(src) local id=pid(src); local rows=DB.fetch('SELECT k,xp,rank FROM sc_skill WHERE identifier=?', { id }); if rows and #rows>0 then local tab=ensure(src); for _,r in ipairs(rows) do tab[r.k]={ xp=tonumber(r.xp) or 0, rank=tonumber(r.rank) or 0 } end end Citizen.SetTimeout(900,function() Co.push(src,'skill',SkillAPI.getAll(src)) end) end
local function savePlayer(src) local id=pid(src); local all=ensure(src); for k,v in pairs(all) do DB.save('sc_skill',{ identifier=id,k=k,xp=v.xp,rank=v.rank,schema_version=1 },{ builder=function(tbl,d) return ([=[
  INSERT INTO sc_skill(identifier,k,xp,rank,schema_version)
  VALUES(?,?,?,?,?)
  ON DUPLICATE KEY UPDATE xp=VALUES(xp), rank=VALUES(rank), schema_version=VALUES(schema_version)
]=]), {d.identifier,d.k,d.xp,d.rank,d.schema_version} end }) end end
AddEventHandler('playerJoining', function() local src=source Citizen.SetTimeout(700,function() loadPlayer(src) end) end)
AddEventHandler('playerDropped', function() local src=source savePlayer(src) store[src]=nil dr[src]=nil rl[src]=nil end)
AddEventHandler('core:flush:all', function() for _,src in ipairs(GetPlayers()) do savePlayer(src) end end)
