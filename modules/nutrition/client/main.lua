-- ปุ่มลัด/เมนูเบา ๆ ผ่าน ox_lib (เลือกกิน/ดื่ม/ต้ม/กรอง)
local MENU_OPEN = false

local function openMenu()
  if MENU_OPEN then return end
  MENU_OPEN = true
  lib.registerContext({
    id = 'nutrition_menu',
    title = 'Nutrition & Hydration',
    options = {
      { title='กิน/ดื่ม (auto-detect item in hand)',  onSelect=function() TriggerServerEvent('nutrition:consume:auto') end },
      { title='ปรุงอาหาร (ย่าง)',   onSelect=function() TriggerServerEvent('nutrition:cook', 'grill') end },
      { title='ปรุงอาหาร (ต้ม)',    onSelect=function() TriggerServerEvent('nutrition:cook', 'boil') end },
      { title='ทำให้น้ำสะอาด (ต้ม)', onSelect=function() TriggerServerEvent('nutrition:purify', 'boil') end },
      { title='ทำให้น้ำสะอาด (กรอง)', onSelect=function() TriggerServerEvent('nutrition:purify', 'filter') end },
      { title='เติมน้ำ (จากแหล่งธรรมชาติ)', onSelect=function() TriggerServerEvent('nutrition:fill', 'natural') end },
    }
  })
  lib.showContext('nutrition_menu')
  MENU_OPEN = false
end

-- คุณสามารถผูกคีย์เปิดเมนูได้เอง
-- RegisterCommand('nut', openMenu)

RegisterNetEvent('nutrition:consumed', function(data)
  lib.notify({ title='Consumed', description=('+'..(data.eff.hunger or 0)..' hunger, +'..(data.eff.thirst or 0)..' thirst'), type='success' })
end)

RegisterNetEvent('nutrition:spoiled', function(info)
  lib.notify({ title='Spoiled', description=(tostring(info.item)..' has spoiled'), type='warning' })
end)