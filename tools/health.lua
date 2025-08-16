RegisterCommand('sc_health', function(src)
  if src ~= 0 and not IsPlayerAceAllowed(src, (SC_CFG and SC_CFG.dev and SC_CFG.dev.ace) or 'sc.dev') then
    TriggerClientEvent('ox_lib:notify', src, { title='SurvivalCore', description='No permission', type='error' })
    return
  end
  local ok, reg = pcall(function() return exports[GetCurrentResourceName()]:sc_modules() end)
  if not ok then print('[SC/HEALTH] registry fetch failed', reg) return end
  print('[SC/HEALTH] registry:', reg)
  if src ~= 0 then TriggerClientEvent('ox_lib:notify', src, { title='SurvivalCore', description='Health printed to server console', type='inform' }) end
end, false)
