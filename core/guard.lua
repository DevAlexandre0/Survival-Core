AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  TriggerEvent('core:flush:all')
  Wait(200)
end)
