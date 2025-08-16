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

local store, rlTreat = {}, {}

MedAPI = {}
local function ensure(src) if not store[src] then store[src]={ blood={ volume=100, type='O+' }, wounds={}, sick={}, fx={ pain=0, shock=0, fever=0, buffs={} } } end return store[src] end
local function canTreat(src) local now=GetGameTimer(); local t=rlTreat[src] or {n=0,ts=now}; if now-t.ts>60000 then t.n=0 t.ts=now end; if t.n >= 10 then return false end; t.n=t.n+1 rlTreat[src]=t return true end
function MedAPI.getState(src) local st=ensure(src) return json.decode(json.encode(st)) end
function MedAPI.applyInjury(src, kind, severity) local st=ensure(src); st.wounds[#st.wounds+1]={kind=kind,sev=severity or 1,bleeding=(kind~='bruise'),dirty=true}; Co.push(src,'medical',{ wounds=st.wounds }); return true end
function MedAPI.treat(src, action) if not canTreat(src) then return false,'rate_limited' end local st=ensure(src); if action=='bandage' then for _,w in ipairs(st.wounds) do w.bleeding=false w.dirty=false end elseif action=='painkiller' then st.fx.pain=math.max(0,(st.fx.pain or 0)-25) end Co.push(src,'medical',{ fx=st.fx, wounds=st.wounds }); return true end
exports('getState', MedAPI.getState); exports('applyInjury', MedAPI.applyInjury); exports('treat', MedAPI.treat)
local function loadPlayer(src) local id=pid(src); local rows=DB.fetch('SELECT blood_type,blood_volume,wounds_json,sick_json,fx_json FROM sc_medical WHERE identifier=?',{ id }); if rows and rows[1] then local r=rows[1]; store[src]={ blood={ type=r.blood_type or 'O+', volume=tonumber(r.blood_volume) or 100 }, wounds=(r.wounds_json and json.decode(r.wounds_json)) or {}, sick=(r.sick_json and json.decode(r.sick_json)) or {}, fx=(r.fx_json and json.decode(r.fx_json)) or { pain=0, shock=0, fever=0, buffs={} } } end Citizen.SetTimeout(1000,function() Co.push(src,'medical',MedAPI.getState(src)) end) end
local function savePlayer(src) local id=pid(src); local st=ensure(src); DB.save('sc_medical',{ identifier=id, blood_type=st.blood.type, blood_volume=math.floor(st.blood.volume), wounds_json=json.encode(st.wounds), sick_json=json.encode(st.sick), fx_json=json.encode(st.fx), schema_version=1 },{ builder=function(tbl,d) return ([=[
  INSERT INTO sc_medical(identifier,blood_type,blood_volume,wounds_json,sick_json,fx_json,schema_version)
  VALUES(?,?,?,?,?,?,?)
  ON DUPLICATE KEY UPDATE blood_type=VALUES(blood_type), blood_volume=VALUES(blood_volume),
    wounds_json=VALUES(wounds_json), sick_json=VALUES(sick_json), fx_json=VALUES(fx_json),
    schema_version=VALUES(schema_version)
]=]), {d.identifier,d.blood_type,d.blood_volume,d.wounds_json,d.sick_json,d.fx_json,d.schema_version} end }) end
AddEventHandler('playerJoining', function() local src=source Citizen.SetTimeout(600, function() loadPlayer(src) end) end)
AddEventHandler('playerDropped', function() local src=source savePlayer(src) store[src]=nil rlTreat[src]=nil end)
AddEventHandler('core:flush:all', function() for _,src in ipairs(GetPlayers()) do savePlayer(src) end end)
