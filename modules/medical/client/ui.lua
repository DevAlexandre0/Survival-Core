RegisterNetEvent('medical:notify', function(msg)
  lib.notify({ title='Medical', description=tostring(msg), type='inform' })
end)

RegisterNetEvent('medical:snapshot', function(st)
  -- สามารถผูก HUD ได้ที่นี่
end)

RegisterNetEvent('medical:changed', function(delta)
  -- อัปเดต HUD แบบเบา ๆ
end)