-- รับผลสืบเนื่อง (จาก server/effects.lua) เพื่อประยุกต์ client-side effect เบา ๆ
RegisterNetEvent('needs:derived', function(der)
  if type(der) ~= 'table' then return end
  -- ตัวอย่าง: ปรับ multiplier การวิ่ง/รีคอยล์ ฯลฯ (ทิ้ง hook ไว้ให้สคริปต์อื่นอ่าน)
  -- คุณสามารถ TriggerEvent ต่อไปยัง HUD/Movement ของคุณได้ที่นี่
end)

-- ขอ snapshot เมื่อเข้าเกม
CreateThread(function()
  Wait(1500)
  TriggerServerEvent('status:requestSnapshot') -- เพื่อ sync HUD รวม (ถ้าใช้ Status Bridge)
end)