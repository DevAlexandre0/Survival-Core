-- ตัวอย่าง UI ย่อผ่าน ox_lib: แสดง rank เมื่อเลื่อนขั้น
RegisterNetEvent('skill:ui:update', function(key, xp, rank)
  local r = ({[0]='Novice',[1]='Adept',[2]='Expert',[3]='Master'})[rank] or ('R'..tostring(rank))
  lib.notify({ title='Skill Up', description=('%s → %s (%d XP)'):format(key, r, xp), type='success' })
end)