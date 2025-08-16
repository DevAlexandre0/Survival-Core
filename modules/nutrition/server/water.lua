local W = {}

local function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end

local function isWaterContainer(item) return WaterItems[item] ~= nil end

function W.fill(src, item, fromSource)
  if not isWaterContainer(item) then return false,'invalid_container' end
  if GetResourceState('ox_inventory') ~= 'started' then return false,'need_ox_inventory' end

  local meta = exports.ox_inventory:GetItemMetadata(src, item) or WaterItems[item].meta
  -- ตัวอย่าง: เติมด้วยน้ำจากโซน → quality 'natural'
  meta.quality = (fromSource=='tap' and 'clean') or 'natural'
  local cap = NUT_CFG.water.containers[meta.container == 'jerry' and 'jerry' or meta.container].liters
  meta.liters = cap
  exports.ox_inventory:SetItemMetadata(src, item, meta)
  return true, meta
end

function W.purify(src, method, item)
  if not isWaterContainer(item) then return false,'invalid_container' end
  if GetResourceState('ox_inventory') ~= 'started' then return false,'need_ox_inventory' end

  local meta = exports.ox_inventory:GetItemMetadata(src, item) or WaterItems[item].meta
  if (meta.liters or 0) <= 0 then return false,'empty' end

  local t = NUT_CFG.water.purify[method]
  if not t then return false,'invalid_method' end

  -- จำลองใช้เวลา (ไม่หน่วง thread จริง: ยืนยันสำเร็จทันที และถือว่า client แสดง progress bar)
  local newQ = 'clean'
  if method == 'filter' and meta.quality == 'contaminated' then newQ = 'natural' end
  if method == 'tablet' then newQ = (meta.quality=='contaminated' and 'natural' or 'clean') end
  meta.quality = newQ

  exports.ox_inventory:SetItemMetadata(src, item, meta)
  return true, meta
end

return W