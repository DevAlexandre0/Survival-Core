local A = {}

local function ok(name) return GetResourceState(name or '') == 'started' end

local QBCore = nil

function A.detect()
  if ok('qb-core') then
    QBCore = exports['qb-core']:GetCoreObject()
    return true, 'qb'
  end
  return false, nil
end

function A.get(src, keyFramework)
  -- หลายเซิร์ฟเก็บ hunger/thirst ใน PlayerData.metadata
  if not QBCore then return nil end
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return nil end
  local meta = Player.PlayerData and Player.PlayerData.metadata
  if not meta then return nil end
  local v = meta[keyFramework]
  if v == nil then return nil end
  return tonumber(v) or v
end

function A.set(src, keyFramework, value)
  if not QBCore then return false end
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return false end
  local meta = Player.PlayerData.metadata or {}
  meta[keyFramework] = value
  Player.Functions.SetMetaData(keyFramework, value)
  return true
end

return A