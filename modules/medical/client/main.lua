-- เอฟเฟกต์ภาพ/การสั่น/เดินช้าลงแบบเบา (optional hooks)
local lastPain = 0
RegisterNetEvent('medical:changed', function(delta)
  if type(delta) ~= 'table' then return end
  if delta.pain and delta.pain >= 60 and lastPain < 60 then
    -- ตัวอย่าง: แสดง vignette เบา ๆ หรือ camera shake เล็กน้อย
    -- Stop at 60-80 for comfort; อย่าหนักไป
  end
  lastPain = delta.pain or lastPain
end)