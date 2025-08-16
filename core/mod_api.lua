Core = Core or {}
Core.modules = Core.modules or {}
Core.started = false
Core.registry = { modules = {}, started_at = nil, version = (SC_CFG and SC_CFG.version) or 'v2' }

local function log(...) print('[Core]', ...) end

function Core.RegisterModule(name, mod)
  if not name or type(mod) ~= 'table' then
    log('RegisterModule invalid args')
    return
  end
  if mod.enabled == nil then mod.enabled = (SC_CFG and (SC_CFG.modules[name] ~= false)) or true end
  Core.modules[name] = mod
  Core.registry.modules[name] = {
    enabled = mod.enabled and true or false,
    meta = mod.meta or {},
    exports = (mod.exports and (function() local t={} for k,_ in pairs(mod.exports) do t[#t+1]=k end return t end)()) or {}
  }
  if Core.started and mod.enabled and mod.__start then
    local ok, err = xpcall(mod.__start, debug.traceback)
    if not ok then log(('Module %s failed to start: %s'):format(name, err)) end
  end
end

function Core.Start()
  if Core.started then return end
  Core.started = true
  Core.registry.started_at = GetGameTimer()
  for name, mod in pairs(Core.modules) do
    if mod.enabled and mod.__start then
      local ok, err = xpcall(mod.__start, debug.traceback)
      if not ok then log(('Module %s start error: %s'):format(name, err)) end
    end
  end
end

function Core.Stop()
  for name, mod in pairs(Core.modules) do
    if mod.__stop then
      xpcall(mod.__stop, debug.traceback)
    end
  end
  Core.started = false
end

function Core.Call(module, func, ...)
  local m = Core.modules[module]
  if not m or not m.exports or type(m.exports[func]) ~= 'function' then
    return false, ('missing export %s.%s'):format(tostring(module), tostring(func))
  end
  return xpcall(m.exports[func], debug.traceback, ...)
end

exports('sc_call', function(module, func, ...)
  local ok, res = Core.Call(module, func, ...)
  return ok, res
end)

exports('sc_modules', function()
  return json.encode(Core.registry)
end)

exports('sc_version', function()
  return (SC_CFG and SC_CFG.version) or 'v2'
end)

RegisterNetEvent('core:registry:request', function()
  local src = source
  local ace = (SC_CFG and SC_CFG.dev and SC_CFG.dev.ace) or 'sc.dev'
  if src ~= 0 and not IsPlayerAceAllowed(src, ace) then
    print(('[Core] registry denied for %s'):format(src))
    return
  end
  TriggerClientEvent('core:registry:update', src, Core.registry)
end)

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  local okDB, DB = pcall(require, 'core/db')
  if okDB and DB and DB.migrate then DB.migrate() end
  Core.Start()
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  Core.Stop()
end)
