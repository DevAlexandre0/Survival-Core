local Co = require 'core/coalesce'

CreateThread(function()
  if not WEATHER_CFG.enabled then return end

  local w = { name = 'EXTRASUNNY', wind = 0.1, temp = 28.0 }

  while true do
    Wait(WEATHER_CFG.interval_ms or 7000)
    -- modules can push per-player snapshots
    TriggerClientEvent('weather:ambient', -1, w)
  end
end)
