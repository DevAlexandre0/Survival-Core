local api  = require('core/api.lua')
local cfg  = require('config/core.lua')
local Util = require('core/utils.lua')
local Storage = require('core/storage/oxmysql.lua')

local Core = {
  players = {},      -- per source state table
  dirty   = {},      -- set of sources needing save
  running = true,
}

-- exports for other resources
exports('getState', function(src) return Core.players[src] end)

exports('setState', function(src, key, value)
  local st = Core.players[src]; if not st then return end
  local old = st[key]
  st[key] = value
  Core.dirty[src] = true

  -- replication allow-list
  local allow = false
  for _,k in ipairs(cfg.replication.allowlist or {}) do if k == key then allow = true break end end
  if allow then
    local ped = GetPlayerPed(src)
    if ped and ped > 0 then Entity(ped).state[(cfg.statebag_prefix or 'svv_') .. key] = value end
  end

  api.emit(api.TOPIC.STATE_CHANGED, src, key, old, value)
end)

-- Identifier helper
local function identifierOf(src)
  for _, id in ipairs(GetPlayerIdentifiers(src)) do
    if id:find('license:') == 1 then return id end
  end
  return ('temp:%s'):format(src)
end

-- Deferrals preload (optional)
AddEventHandler('playerConnecting', function(name, setKick, deferrals)
  if not (cfg.join and cfg.join.preload and cfg.join.preload.enabled) then return end
  deferrals.defer()
  deferrals.update('Loading player state...')
  local src = source
  local lic = identifierOf(src)
  local state = Storage.loadPlayer(lic)
  Core.players[src] = state or {}
  deferrals.done()
end)

-- Regular load (fallback if not preloaded)
AddEventHandler('playerJoining', function(src)
  local s = tonumber(src) or source
  if Core.players[s] == nil then
    local lic = identifierOf(s)
    Core.players[s] = Storage.loadPlayer(lic) or {}
  end
  api.emit(api.TOPIC.PLAYER_LOADED, s, Core.players[s])
end)

AddEventHandler('playerDropped', function()
  local s = source
  local lic = identifierOf(s)
  Storage.savePlayer(lic, Core.players[s] or {})
  api.emit(api.TOPIC.PLAYER_UNLOADED, s)
  Core.players[s] = nil
  Core.dirty[s] = nil
end)

-- Flush helpers
local function flushOne(src)
  local st = Core.players[src]; if not st then return end
  local lic = identifierOf(src)
  Storage.savePlayer(lic, st)
  Core.dirty[src] = nil
end

local function flushAll()
  for src,_ in pairs(Core.players) do flushOne(src) end
end

-- Tick loop (adaptive)
CreateThread(function()
  local base = (cfg.perf and cfg.perf.tick_base_ms) or 1000
  local idle = (cfg.perf and cfg.perf.tick_idle_ms) or 2500
  local burst= (cfg.perf and cfg.perf.tick_burst_ms) or 500

  while Core.running do
    local online = 0; for _ in pairs(Core.players) do online = online + 1 end
    local wait = (online == 0) and idle or base
    Wait(wait)
    api.emit(api.TOPIC.TICK)

    -- batch save dirty players
    local batch = (cfg.perf and cfg.perf.batch_save_size) or 25
    local n = 0
    for src,_ in pairs(Core.dirty) do
      flushOne(src); n = n + 1
      if n >= batch then break end
    end
    -- burst shorten when work exists
    if n > 0 then Wait(burst) end
  end
end)

-- onResourceStop safe flush
AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  Core.running = false
  local t0 = GetGameTimer()
  flushAll()
  Util.log('info', 'Flushed all on stop in '..(GetGameTimer()-t0)..'ms')
end)