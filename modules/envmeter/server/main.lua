local lib = lib

CreateThread(function()
  if not ENV_CFG.enabled then return end
  print('[EnvMeter] server started (by_band='..tostring(ENV_CFG.replication.by_band)..')')
end)

-- Optional: periodic consolidation (example placeholder if you later push to Core state)
-- You can integrate with your Core's setState/replicate budget here if needed.