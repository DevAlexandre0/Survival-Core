local A = {}

local function ok(name) return GetResourceState(name or '') == 'started' end

function A.detect()
  if ok('ox_core') then
    return true, 'ox'
  end
  return false, nil
end

function A.get(src, keyFramework)
  -- ox_core ปกติใช้ statebags / character data; ตัวอย่างนี้ใช้ statebag เบา ๆ
  local id = ('player:%s'):format(src)
  local key = ('status:%s'):format(keyFramework)
  local v = GetStateBagValue(id, key)
  if v == nil then return nil end
  return tonumber(v) or v
end

function A.set(src, keyFramework, value)
  local id = ('player:%s'):format(src)
  local key = ('status:%s'):format(keyFramework)
  Entity(GetPlayerPed(src)).state:set(key, value, true) -- replicated
  return true
end

return A