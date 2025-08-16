local api = require('core/api.lua')
local cfg = require('config/core.lua')
local Util = require('core/utils.lua')

RegisterCommand('core:flushall', function(src)
  if src ~= 0 then return end
  TriggerEvent('svcore:flushAll')
  Util.log('info', 'Manual flush all requested.')
end, true)

RegisterCommand('core:metrics', function(src)
  if src ~= 0 then return end
  print('Survival Core metrics: (sample) online players, dirty set size not exposed here; use Dev UI for details.')
end, true)

RegisterCommand('core:profile', function(src, args)
  if src ~= 0 then return end
  local p = args[1]; if not p or not cfg.profiles[p] then print('Usage: core:profile <dev|staging|prod>'); return end
  print('Profile switch requested to '..p..' (hot-apply partial).')
  -- In practice you'd live-apply safe keys here.
end, true)

RegisterCommand('core:reload-config', function(src)
  if src ~= 0 then return end
  print('Config reload requested (live keys only).')
end, true)

-- event for flushall
AddEventHandler('svcore:flushAll', function()
  -- core handles on stop; here you could iterate and save each
  -- Kept minimal for brevity.
end)