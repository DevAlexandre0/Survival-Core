local S = {}

local function diurnalTemp(base, amp)
  -- โค้งง่าย ๆ จากเวลาจริงในเกม (ชั่วโมง 0..24)
  local h = GetClockHours()
  local phase = math.cos((h-14)/24 * 2*math.pi) -- อบอุ่นช่วงบ่าย
  return base + (-phase) * amp
end

function S.step(state)
  -- สร้าง ambient จาก preset ปัจจุบัน + diurnal
  local preset = WEATHER_CFG.presets[state.active] or WEATHER_CFG.presets.CLEAR
  local base = WEATHER_CFG.ambient
  local tempC = diurnalTemp(base.base_tempC + (preset.temp_bias or 0), base.diurnal_amp)

  state.ambient.tempC   = tempC
  state.ambient.wind    = (preset.wind or base.wind_base)
  state.ambient.humidity= (preset.humidity or base.humidity_base)
  state.ambient.cloud   = (preset.cloud or 0.2)
  state.ambient.precip  = (preset.precip or 0.0)
  state.ambient.weather = state.active
end

function S.pickNext(state)
  local hour = GetClockHours()
  local weights = (hour >= 6 and hour < 20) and WEATHER_CFG.schedule.weights.day or WEATHER_CFG.schedule.weights.night
  local nxt = nil
  repeat
    nxt = (function()
      local total=0 for _,w in pairs(weights) do total=total+w end
      local r = math.random(1,total)
      local cum=0
      for k,w in pairs(weights) do
        cum=cum+w
        if r<=cum then return k end
      end
      return 'CLEAR'
    end)()
  until nxt ~= state.active or math.random()<0.3 -- มีโอกาสอยู่ preset เดิมได้

  local holdMin = math.random(WEATHER_CFG.schedule.min_hold_min, WEATHER_CFG.schedule.max_hold_min)
  state.active = nxt
  state.nextAt = GetGameTimer() + holdMin*60*1000
end

return S