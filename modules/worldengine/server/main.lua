local zones = require 'modules/worldengine/server/zones'
local res   = require 'modules/worldengine/server/resources'

CreateThread(function()
  if not WORLD_CFG.enabled then return end
  print('[WorldEngine] server started')
  local idle = WORLD_CFG.scan.interval_ms.idle
  local active = WORLD_CFG.scan.interval_ms.active

  while true do
    zones.onTickBroadcastFlags()
    res.tickNodes()

    -- (ถ้าจะสแกน prop แบบ dynamic: ใส่ที่นี่หรือแยก thread)
    Wait(active)
  end
end)