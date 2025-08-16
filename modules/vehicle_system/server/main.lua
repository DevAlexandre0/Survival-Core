CreateThread(function()
  if not VEH_CFG.enabled then return end
  print('[VehicleSystem] server started')
  while true do
    -- วงหลักเบา ๆ: ตอนนี้ส่วนใหญ่คำนวณจาก telemetry event แล้ว
    -- สามารถเพิ่ม flush/save DB ที่นี่ได้ถ้าคุณต้องการ persistence
    Wait(2000)
  end
end)