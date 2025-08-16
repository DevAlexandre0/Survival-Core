local snapshot = {}

RegisterNetEvent('status:snapshot', function(all)
  if type(all) ~= 'table' then return end
  snapshot = all
  -- HUD/สคริปต์อื่นอ่านจาก event นี้ได้ หรือเรียก exports ฝั่ง server
end)

RegisterNetEvent('status:changed', function(ch)
  if type(ch) ~= 'table' then return end
  snapshot[ch.key] = ch.value
  -- อัปเดต HUD แบบเบาได้จากตรงนี้
end)