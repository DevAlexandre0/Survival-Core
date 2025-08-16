-- แสดงสถานะอากาศแบบเบา ๆ (optional)
local lastShown = ''

CreateThread(function()
  while true do
    Wait(10000)
    -- คุณสามารถเชื่อมกับ HUD หลักได้ ที่นี่เป็นเพียงตัวอย่าง
    -- lib.notify({ title='Weather', description=lastShown, type='inform' })
  end
end)