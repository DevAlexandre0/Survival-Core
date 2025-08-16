local C = {}

-- ตรวจแหล่งไฟ (จาก WorldEngine) แบบง่าย
local function nearHeatZone(src, range)
  -- ในระบบจริงควรเรียก WorldAPI.getZoneAt/flags ที่มี heat=true
  -- ที่นี่สมมติว่า EnvMeter/WorldEngine ส่งธงให้ client แล้ว client ขอทำอาหาร → เราตรวจแค่ rate-limit/ไอเท็ม
  return true
end

-- เพิ่มระดับสุก + อัปเดตไอเท็ม (ox_inventory)
function C.cook(src, method, item)
  if not FoodItems[item] then return false, 'invalid_food' end
  if not nearHeatZone(src, 4.0) then return false, 'need_heat' end

  if GetResourceState('ox_inventory') ~= 'started' then
    return false, 'need_ox_inventory'
  end

  local meta = exports.ox_inventory:GetItemMetadata(src, item) or FoodItems[item].meta
  meta.opened = true
  meta.doneness = math.min(100, (meta.doneness or 0) + (NUT_CFG.cooking.time_s[method] and 25 or 20))
  -- สุกแล้วปลอดภัยขึ้น
  exports.ox_inventory:SetItemMetadata(src, item, meta)

  return true, meta
end

return C