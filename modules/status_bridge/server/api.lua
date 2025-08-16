local adapters = {
  esx = require 'server/adapters/esx',
  qb  = require 'server/adapters/qb',
  ox  = require 'server/adapters/ox',
  standalone = require 'server/adapters/standalone',
}

local activeAdapter = nil
local activeKeyMap  = nil
local providerName  = 'standalone'

local clamp = function(v)
  v = tonumber(v) or 0
  if v < STATUS_CFG.min then v = STATUS_CFG.min end
  if v > STATUS_CFG.max then v = STATUS_CFG.max end
  return v
end

-- per-player write limiter
local wCount = {}
local function allowWrite(src)
  local now = GetGameTimer()
  local b = wCount[src] or { t = now, n = 0 }
  if now - b.t >= 1000 then b.t = now b.n = 0 end
  if b.n >= STATUS_CFG.write_limits.per_second then return false end
  b.n = b.n + 1
  wCount[src] = b
  return true
end

local function detectAdapter()
  for _,k in ipairs(STATUS_CFG.detect_order) do
    local ok, name = adapters[k].detect()
    if ok then
      activeAdapter = adapters[k]
      providerName = name
      activeKeyMap = StatusMap[k].keys
      print(('[StatusBridge] using adapter: %s'):format(name))
      return
    end
  end
  -- fallback
  activeAdapter = adapters['standalone']
  providerName  = 'standalone'
  activeKeyMap  = StatusMap['standalone'].keys
  print('[StatusBridge] fallback to standalone')
end

detectAdapter()

StatusAPI = {}

function StatusAPI.get(src, key)      -- key = 'hunger'|'thirst'|...
  if not activeAdapter then return nil end
  local fk = activeKeyMap[key]
  if not fk then return nil end
  local v = activeAdapter.get(src, fk)
  if v == nil then return nil end
  return clamp(v)
end

function StatusAPI.set(src, key, value, cause)
  if not activeAdapter then return false end
  if STATUS_CFG.deny_external_write and not IsDuplicityVersion() then return false end
  if not allowWrite(src) then return false end
  local fk = activeKeyMap[key]
  if not fk then return false end
  local v = clamp(value)
  local ok = activeAdapter.set(src, fk, v)
  if ok then
    TriggerClientEvent('status:changed', src, { key = key, value = v, cause = cause or 'bridge' })
    -- ส่งต่อให้ Status Engine (ถ้ามี)
    TriggerEvent('core:status:write', src, key, v, cause or 'bridge')
  end
  return ok
end

function StatusAPI.bulkSet(src, tbl, cause)
  if type(tbl) ~= 'table' then return false end
  local any = false
  for k,v in pairs(tbl) do
    if StatusAPI.set(src, k, v, cause) then any = true end
  end
  return any
end

function StatusAPI.getAll(src)
  local out = {}
  for _,k in ipairs(STATUS_CFG.keys) do
    out[k] = StatusAPI.get(src, k) or STATUS_CFG.defaults[k]
  end
  return out
end

exports('get', StatusAPI.get)
exports('set', StatusAPI.set)
exports('bulkSet', StatusAPI.bulkSet)
exports('getAll', StatusAPI.getAll)

RegisterNetEvent('status:requestSnapshot', function()
  local src = source
  TriggerClientEvent('status:snapshot', src, StatusAPI.getAll(src))
end)

AddEventHandler('playerJoining', function()
  local src = source
  Citizen.SetTimeout(1000, function()
    TriggerClientEvent('status:snapshot', src, StatusAPI.getAll(src))
  end)
end)