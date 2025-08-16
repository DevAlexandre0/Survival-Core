RegisterNetEvent('core:coalesced', function(batch)
  if type(batch) ~= 'table' then return end
  for _,pkt in ipairs(batch) do
    local e = pkt.e
    local p = pkt.p
    if e == 'needs' then
      TriggerEvent('needs:coalesced', p)
    elseif e == 'medical' then
      TriggerEvent('medical:coalesced', p)
    elseif e == 'skill' then
      TriggerEvent('skill:coalesced', p)
    elseif e == 'vehicle' then
      TriggerEvent('vehicle:coalesced', p)
    elseif e == 'weather' then
      TriggerEvent('weather:coalesced', p)
    elseif e == 'nutrition' then
      TriggerEvent('nutrition:coalesced', p)
    end
  end
end)
