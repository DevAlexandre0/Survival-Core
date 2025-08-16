local lastNearby = 0

-- ขอดึง nodes ใกล้ตัวเป็นระยะ เพื่ออัปเดต ox_target (ถ้าเปิด)
CreateThread(function()
  while true do
    if not WORLD_CFG.enabled then return end
    local ped = PlayerPedId()
    local p = GetEntityCoords(ped)
    local now = GetGameTimer()
    if now - lastNearby > 4000 then
      TriggerServerEvent('worldengine:requestNearbyNodes', p)
      lastNearby = now
    end
    Wait(1500)
  end
end)

-- รับลิสต์ nodes ใกล้ตัว (จาก server)
RegisterNetEvent('worldengine:nearbyNodes', function(list)
  TriggerEvent('worldengine:nodes:nearby', list)
end)

-- ธงโซน (ส่งถึง EnvMeter/Needs)
RegisterNetEvent('worldengine:flags', function(flags)
  -- ส่งต่อให้ EnvMeter (เพื่อ temp/wetness) ถ้าโมดูลนั้นเปิด
  TriggerEvent('worldengine:flags:for_env', flags)
end)

-- ขอใช้งาน node (กดจาก ox_target)
RegisterNetEvent('worldengine:node:use', function(id)
  TriggerServerEvent('worldengine:node:use', id)
end)