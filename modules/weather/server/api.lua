local state = {
  mode   = WEATHER_CFG.mode,
  active = 'CLEAR',
  nextAt = 0,
  ambient = { tempC = WEATHER_CFG.ambient.base_tempC, wind = WEATHER_CFG.ambient.wind_base, precip = 0.0, humidity = WEATHER_CFG.ambient.humidity_base, cloud = 0.1, weather = 'CLEAR' },
}

local function broadcastAmbient(target)
  if target then
    TriggerClientEvent('weather:ambient', target, state.ambient)
  else
    TriggerClientEvent('weather:ambient', -1, state.ambient)
  end
end

local function pickWeighted(tbl)
  local total=0 for _,w in pairs(tbl) do total=total+w end
  local r = math.random()*total
  for k,w in pairs(tbl) do r=r-w if r<=0 then return k end end
  -- fallback
  for k,_ in pairs(tbl) do return k end
end

WeatherAPI = {}

function WeatherAPI.current()
  return json.decode(json.encode(state))
end

function WeatherAPI.setMode(mode)
  if mode ~= 'own' and mode ~= 'follow' and mode ~= 'locked' then return false end
  state.mode = mode
  return true
end

function WeatherAPI.setLocked(preset)
  state.mode = 'locked'
  state.active = preset or 'CLEAR'
  state.nextAt = 0
  return true
end

function WeatherAPI.force(preset, transition_s)
  state.active = preset
  state.nextAt = GetGameTimer() + (transition_s or math.random(WEATHER_CFG.sync.transition_sec.min, WEATHER_CFG.sync.transition_sec.max))*1000
  return true
end

-- For external weather providers in 'follow' mode
function WeatherAPI.pushExternal(data)
  if state.mode ~= 'follow' then return false end
  -- data: { weather='EX_CLEAR', tempC=.., wind=.., precip=.., humidity=.., cloud=.. }
  local key = (WEATHER_CFG.external_follow.map[data.weather or '']) or 'CLEAR'
  state.active = key
  state.ambient.tempC   = data.tempC   or state.ambient.tempC
  state.ambient.wind    = data.wind    or state.ambient.wind
  state.ambient.precip  = data.precip  or state.ambient.precip
  state.ambient.humidity= data.humidity or state.ambient.humidity
  state.ambient.cloud   = data.cloud   or state.ambient.cloud
  state.ambient.weather = key
  broadcastAmbient()
  return true
end

exports('current', WeatherAPI.current)
exports('setMode', WeatherAPI.setMode)
exports('setLocked', WeatherAPI.setLocked)
exports('force', WeatherAPI.force)
exports('pushExternal', WeatherAPI.pushExternal)

AddEventHandler('playerJoining', function()
  local src = source
  Citizen.SetTimeout(math.random(WEATHER_CFG.sync.join_blend_sec.min, WEATHER_CFG.sync.join_blend_sec.max)*1000, function()
    broadcastAmbient(src)
  end)
end)