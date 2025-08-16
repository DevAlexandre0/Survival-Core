-- ตัวอย่าง notify แบบเบา เมื่อค่าเปลี่ยนช่วง (optional)
local lastBand = {}

local function band(v, a,b,c)
  if v < a then return 0 elseif v < b then return 1 elseif v < c then return 2 else return 3 end
end

RegisterNetEvent('needs:snapshot', function(st) lastBand={} end)

RegisterNetEvent('needs:changed', function(ch)
  if type(ch) ~= 'table' then return end
  -- แสดงเฉพาะบางคีย์/เมื่อข้ามช่วง (ตัวอย่าง)
  local key=ch.key; local v=ch.value
  local b
  if key=='hunger' then b=band(v,25,50,75)
  elseif key=='thirst' then b=band(v,25,50,75)
  elseif key=='stamina' then b=band(v,25,50,75) end
  if b and lastBand[key] ~= nil and lastBand[key] ~= b then
    lib.notify({title='Needs', description=(key..' → '..v), type='inform'})
  end
  lastBand[key]=b
end)