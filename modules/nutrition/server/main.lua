-- Spoilage batch tick (เบา)
CreateThread(function()
  if not NUT_CFG.enabled or not NUT_CFG.spoil.enabled then return end
  print('[Nutrition] server started (spoil batch)')
  while true do
    local amb = { tempC=24.0, humidity=0.55, precip=0.0 }
    -- ถ้ามี Weather ให้ดึงค่า current ambient จาก exports (หรือ cache)
    if GetResourceState('weather') == 'started' then
      local s = exports.weather:current()
      if s and s.ambient then amb = s.ambient end
    end

    local amp = 1.0
    amp = amp + (amb.tempC - 24.0) * NUT_CFG.spoil.env.temp_amp_per_C
    amp = amp + (amb.humidity - 0.55) * NUT_CFG.spoil.env.humidity_amp
    if (amb.precip or 0) > 0.05 then amp = amp + NUT_CFG.spoil.env.rain_bonus end

    -- วนเฉพาะผู้เล่นออนไลน์: อัปเดตไอเท็มที่มี meta.spoil
    if GetResourceState('ox_inventory') == 'started' then
      for _,src in ipairs(GetPlayers()) do
        -- ตัวอย่าง: สแกนรายการไอเท็มในกระเป๋า (ควรจำกัดบ้าน/ยานพาหนะทีหลัง)
        local items = exports.ox_inventory:GetInventoryItems(src)
        if items then
          for _,it in pairs(items) do
            local m = it.metadata
            if m and m.spoil ~= nil then
              local mod = NUT_CFG.spoil.base_rate * amp
              if m.opened then mod = mod * NUT_CFG.spoil.open_multiplier end
              -- ภาชนะ/ชนิดอาหาร
              if m.container and NUT_CFG.spoil.container_mod[m.container] then
                mod = mod * NUT_CFG.spoil.container_mod[m.container]
              elseif FoodItems[it.name] then
                local prof = FoodItems[it.name].profile
                if NUT_CFG.spoil.container_mod[prof] then mod = mod * NUT_CFG.spoil.container_mod[prof] end
              end

              m.spoil = math.min(100, (m.spoil or 0) + mod * (NUT_CFG.spoil.tick_ms/1000))
              exports.ox_inventory:SetItemMetadata(src, it.name, m)

              if m.spoil >= 100 then
                -- ของเสีย: ลดค่าบริโภค/เพิ่มเสี่ยง หรือแปลงเป็น "spoiled_food"
                -- ตัวอย่างง่าย: แจ้งเตือน
                TriggerClientEvent('nutrition:spoiled', src, { item=it.name })
              end
            end
          end
        end
      end
    end

    Wait(NUT_CFG.spoil.tick_ms)
  end
end)

-- Event hooks (ง่าย ๆ) สำหรับ Medical demo
RegisterNetEvent('medical:applySickness', function(target, key)
  -- หากต้องการผูกกับ MedAPI จริง ให้ไปที่โมดูล medical เรียก exports ตรง ๆ
  -- ที่นี่เป็น placeholder event bridge
end)


-- ตัวอย่างคำสั่งแบบง่าย (ให้ client ไม่ต้องส่งชื่อไอเท็ม)
RegisterNetEvent('nutrition:consume:auto', function()
  local src=source
  if GetResourceState('ox_inventory') ~= 'started' then return end
  local hand = exports.ox_inventory:GetCurrentWeapon(src)  -- ถ้าใช้มือเปล่า ให้คุณดึงไอเท็มอื่นตามที่กำหนด
  -- ตัวอย่างเรียกของจากช่องด่วน/หรือไอเท็ม “ที่เลือกอยู่” ของคุณเองแทน
  -- ที่นี่จะลองไล่หาจากลิสต์ FoodItems/WaterItems ในกระเป๋าก่อน
  local inv = exports.ox_inventory:GetInventoryItems(src) or {}
  for _,it in pairs(inv) do
    if FoodItems[it.name] or WaterItems[it.name] then
      local ok, eff = NutAPI.consume(src, it.name)
      if ok then return end
    end
  end
end)

RegisterNetEvent('nutrition:cook', function(method)
  local src=source
  -- หาไอเท็มที่ปรุงได้ในกระเป๋า (อย่างง่าย)
  local inv = exports.ox_inventory:GetInventoryItems(src) or {}
  for _,it in pairs(inv) do
    if FoodItems[it.name] then
      local ok, meta = NutAPI.cook(src, method, it.name)
      TriggerClientEvent('ox_lib:notify', src, { type = ok and 'success' or 'error', description = ok and ('Cooked '..it.name) or tostring(meta) })
      if ok then return end
    end
  end
end)

RegisterNetEvent('nutrition:purify', function(method)
  local src=source
  local inv = exports.ox_inventory:GetInventoryItems(src) or {}
  for _,it in pairs(inv) do
    if WaterItems[it.name] then
      local ok, meta = NutAPI.purify(src, method, it.name)
      TriggerClientEvent('ox_lib:notify', src, { type = ok and 'success' or 'error', description = ok and ('Purified '..it.name) or tostring(meta) })
      if ok then return end
    end
  end
end)

RegisterNetEvent('nutrition:fill', function(srcName)
  local src=source
  local inv = exports.ox_inventory:GetInventoryItems(src) or {}
  for _,it in pairs(inv) do
    if WaterItems[it.name] then
      local ok, meta = NutAPI.fillWater(src, it.name, srcName or 'natural')
      TriggerClientEvent('ox_lib:notify', src, { type = ok and 'success' or 'error', description = ok and ('Filled '..it.name) or tostring(meta) })
      if ok then return end
    end
  end
end)