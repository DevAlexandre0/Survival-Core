local lib = lib
local players = {}

local lastSnapshot = {}

local function band_temp(v)
  if v < ENV_CFG.temp_model.cold_th then return EnvBands.temp.cold end
  if v < ENV_CFG.temp_model.comfort then return EnvBands.temp.cool end
  if v < ENV_CFG.temp_model.heat_th then return EnvBands.temp.comfort end
  if v < 90 then return EnvBands.temp.warm end
  return EnvBands.temp.hot
end

local function band_wet(v)
  if v < 10 then return EnvBands.wet.dry end
  if v < 35 then return EnvBands.wet.damp end
  if v < 75 then return EnvBands.wet.wet end
  return EnvBands.wet.soaked
end

local function merge_env(src, payload)
  local p = players[src] or {}
  p.t = payload.t or p.t or 50.0
  p.w = payload.w or p.w or 0.0
  p.s = payload.s or p.s or 0.0
  p.k = payload.k or p.k or 0.0
  p.m = payload.m or p.m or "asphalt"
  p.f = payload.f or p.f or 0
  p.mo= payload.mo or p.mo or 0
  players[src] = p

  lastSnapshot[src] = {
    temp = p.t, wet = p.w, speed = p.s, slope = p.k, mat = p.m, flags = p.f, motion = p.mo,
    tband = band_temp(p.t), wband = band_wet(p.w)
  }
end

-- expose API for other modules (Core capability style)
EnvAPI = {}

---Get last env snapshot for a player
---@param src number
function EnvAPI.getPlayerEnv(src)
  return lastSnapshot[src]
end

---Broadcast snapshot to a specific player (on join/resync)
---@param src number
function EnvAPI.sendSnapshot(src)
  local snap = lastSnapshot[src]
  if snap then
    TriggerClientEvent('envmeter:snapshot', src, snap)
  end
end

AddEventHandler('playerDropped', function()
  local src = source
  players[src] = nil
  lastSnapshot[src] = nil
end)

RegisterNetEvent('envmeter:changed', function(payload)
  local src = source
  if type(payload) ~= 'table' then return end
  -- lightweight validation
  if payload.t then payload.t = math.max(0, math.min(100, payload.t+0.0)) end
  if payload.w then payload.w = math.max(0, math.min(100, payload.w+0.0)) end
  merge_env(src, payload)

  -- Optionally coalesce broadcasts; for now, rely on client-side throttling and core replication
end)

-- Give snapshot on spawn (Core can also call EnvAPI.sendSnapshot)
AddEventHandler('playerJoining', function(oldId)
  local src = source
  Citizen.SetTimeout(1500, function()
    if lastSnapshot[src] then
      TriggerClientEvent('envmeter:snapshot', src, lastSnapshot[src])
    end
  end)
end)