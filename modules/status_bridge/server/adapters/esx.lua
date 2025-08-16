local A = {}

local function ok(name) return GetResourceState(name or '') == 'started' end

function A.detect()
  if ok('es_extended') then
    return true, 'esx'
  end
  return false, nil
end

-- อ่าน/เขียนแบบปลอดภัย: หลายเซิร์ฟใช้ esx_status
local function getStatusObject(src)
  if ok('esx_status') and exports and exports['esx_status'] then
    return exports['esx_status']
  end
  return nil
end

function A.get(src, keyFramework)
  local status = getStatusObject(src)
  if status and status.getStatus then
    local v = status:getStatus(src, keyFramework)   -- บางเวอร์ชันคืน object ที่มี .val
    if type(v) == 'table' and v.val then return tonumber(v.val) end
    if type(v) == 'number' then return v end
  end
  return nil
end

function A.set(src, keyFramework, value)
  local status = getStatusObject(src)
  if status and status.setStatus then
    status:setStatus(src, keyFramework, value)
    return true
  end
  return false
end

return A