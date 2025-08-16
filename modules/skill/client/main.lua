local snapshot = {}

RegisterNetEvent('skill:snapshot', function(all)
  if type(all) ~= 'table' then return end
  snapshot = all
  -- HUD/เมนูสกิลสามารถอ่านค่าในตัวแปรนี้ หรือฟัง event skill:changed
end)

RegisterNetEvent('skill:changed', function(ch)
  if type(ch) ~= 'table' then return end
  snapshot[ch.key] = { xp=ch.xp, rank=ch.rank }
  -- แจ้งเตือนแบบเบา หรืออัปเดต UI
  TriggerEvent('skill:ui:update', ch.key, ch.xp, ch.rank)
end)

-- ตัวอย่างการขอ XP จาก client (ให้ระบบอื่นเรียก server event ดีกว่า)
-- TriggerServerEvent('skill:grant', 'nutrition:cook:done', { })