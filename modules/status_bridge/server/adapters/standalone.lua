local A = {}
local store = {}  -- per-player table

function A.detect()
  return true, 'standalone'
end

local function ensure(src)
  store[src] = store[src] or {}
  return store[src]
end

function A.get(src, keyFramework)
  local t = ensure(src)
  return t[keyFramework]
end

function A.set(src, keyFramework, value)
  local t = ensure(src)
  t[keyFramework] = value
  return true
end

AddEventHandler('playerDropped', function()
  store[source] = nil
end)

return A