local ambient = { tempC=26.0, wind=1.5, precip=0.0, humidity=0.55, cloud=0.2, weather='CLEAR' }
local lastApply = 0

RegisterNetEvent('weather:ambient', function(a)
  if type(a) ~= 'table' then return end
  -- อัปเดตค่าสำหรับ EnvMeter (ฟีดต่อ)
  ambient = a
  -- ส่งต่อให้ EnvMeter ทันที (ถ้าเปิดใช้)
  TriggerEvent('weather:ambient', ambient)

  -- ปรับ native สภาพอากาศบางส่วน (เบา ๆ)
  -- หมายเหตุ: FiveM มี native คุมสภาพ เช่น SetWeatherTypeNowPersist, SetRainLevel ฯลฯ
  local now = GetGameTimer()
  if now - lastApply > 5000 then
    lastApply = now
    -- ตัวอย่าง (ป้องกันกระชาก): ใช้คีย์ weather string เพื่อ set weather type แบบหยาบ
    if ambient.weather == 'STORM' then
      SetWeatherTypeOverTime('THUNDER', 15.0)
      SetRainLevel(math.min(1.0, ambient.precip or 1.0))
    elseif ambient.weather == 'RAIN' then
      SetWeatherTypeOverTime('RAIN', 10.0)
      SetRainLevel(math.min(0.8, ambient.precip or 0.6))
    elseif ambient.weather == 'FOG' then
      SetWeatherTypeOverTime('FOGGY', 15.0)
      SetRainLevel(0.0)
    elseif ambient.weather == 'CLOUDS' or ambient.weather == 'CLOUDY' then
      SetWeatherTypeOverTime('CLOUDS', 10.0); SetRainLevel(0.0)
    elseif ambient.weather == 'HEATWAVE' then
      SetWeatherTypeOverTime('EXTRASUNNY', 10.0); SetRainLevel(0.0)
    elseif ambient.weather == 'COLD' or ambient.weather == 'CLEAR' then
      SetWeatherTypeOverTime('CLEAR', 10.0); SetRainLevel(0.0)
    else
      SetWeatherTypeOverTime('CLEAR', 10.0); SetRainLevel(0.0)
    end
  end
end)