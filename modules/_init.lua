local res = GetCurrentResourceName()
local function safe_require(path)
  local src = LoadResourceFile(res, path)
  if not src then print('[Modules] missing:', path) return end
  local fn, err = load(src, ('@%s'):format(path))
  if not fn then print('[Modules] load error', path, err) return end
  local ok, e = xpcall(fn, debug.traceback)
  if not ok then print('[Modules] exec error', path, e) end
end

local order = {
  'status_bridge',
  'needs',
  'nutrition',
  'medical',
  'skill',
  'vehicle_system',
  'weather'
}

for _,name in ipairs(order) do
  safe_require(('modules/%s/init.lua'):format(name))
end
