CreateThread(function()
  local cfg = (SC_CFG and SC_CFG.save) or {}
  if not cfg.enabled then return end
  local interval = cfg.interval_ms or 120000
  print(('[SC/Save] Autosave every %d ms'):format(interval))
  while true do
    Wait(interval)
    TriggerEvent('core:flush:all')
  end
end)

RegisterCommand('sc_flush', function(src)
  local ace = (SC_CFG and SC_CFG.dev and SC_CFG.dev.ace) or 'sc.dev'
  if src ~= 0 and not IsPlayerAceAllowed(src, ace) then
    TriggerClientEvent('ox_lib:notify', src, { title='SurvivalCore', description='No permission', type='error' })
    return
  end
  TriggerEvent('core:flush:all')
  if src ~= 0 then
    TriggerClientEvent('ox_lib:notify', src, { title='SurvivalCore', description='Flushed to DB', type='success' })
  else
    print('[SC/Save] Manual flush issued')
  end
end, false)
