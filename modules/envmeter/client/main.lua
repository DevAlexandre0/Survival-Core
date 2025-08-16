local bands = require 'client/bands'
local last = { t=50.0, w=0.0, s=0.0, k=0.0, m='asphalt', f=0, mo=0 }
local lastSend = 0

-- flags bitmask
local FLAG_RAIN   = 1
local FLAG_WATER  = 2
local FLAG_INDOOR = 4
local FLAG_SHELTR = 8

-- motion bitmask
local MOT_WALK   = 1
local MOT_RUN    = 2
local MOT_SPRINT = 4
local MOT_SWIM   = 8
local MOT_CROUCH = 16
local MOT_PRONE  = 32

-- simple lerp
local function lerp(a,b,k) return a + (b-a)*k end

-- ambient feed from Weather (optional)
local ambient = { tempC = 26.0, wind = 2.0, precip = 0.0, humidity = 0.55 }
RegisterNetEvent('weather:ambient', function(data)
  if type(data) == 'table' then
    ambient.tempC   = data.tempC   or ambient.tempC
    ambient.wind    = data.wind    or ambient.wind
    ambient.precip  = data.precip  or ambient.precip
    ambient.humidity= data.humidity or ambient.humidity
  end
end)

-- world/shelter/heat flags (optional integration with WorldEngine)
RegisterNetEvent('worldengine:flags', function(data)
  -- expect data.shelter, data.heat, data.water
  if type(data) == 'table' then
    last.worldShelter = data.shelter or false
    last.worldWater   = data.water or false
  end
end)

-- compute motion flags & speed
local function readMotion()
  local ped = PlayerPedId()
  local v = GetEntitySpeed(ped) -- m/s
  local inWater = IsEntityInWater(ped)
  local crouch = IsPedCrouching and IsPedCrouching(ped) or false
  local sprint = IsPedSprinting(ped)
  local run    = IsPedRunning(ped)
  local swim   = IsPedSwimming(ped)

  local mo = 0
  if swim then mo = mo | MOT_SWIM
  elseif sprint then mo = mo | MOT_SPRINT
  elseif run then mo = mo | MOT_RUN
  elseif v > 0.2 then mo = mo | MOT_WALK end
  if crouch then mo = mo | MOT_CROUCH end
  -- prone (optional from other scripts) not native by default

  return v, mo, inWater
end

-- rough slope from entity matrix (lightweight)
local function readSlope()
  local ped = PlayerPedId()
  local _, _, upRight, _ = GetEntityMatrix(ped) -- forward,right,up,position
  -- upRight is a vector3 (x,y,z) orientation (approx); slope deg from z
  local z = upRight.z or 1.0
  local slope = math.deg(math.acos(math.min(1.0, math.max(-1.0, z))))
  return slope
end

-- material name (coarse, you can map decals/surface types)
local function readMaterial()
  -- Placeholder: you can integrate with raycast/ground material
  return 'asphalt'
end

-- temperature & wetness model
local function stepEnv(dt)
  local tcfg = ENV_CFG.temp_model
  local wcfg = ENV_CFG.wet_model

  -- temp
  local ambientC = ambient.tempC
  local wind     = ambient.wind
  local precip   = ambient.precip

  local activity = last.s > 2.0 and 1.0 or (last.s > 0.2 and 0.4 or 0.0)

  local dTemp = 0.0
  dTemp = dTemp + (tcfg.k_env * (ambientC/0.5 - last.t))  -- scale C->(0..100) crudely
  dTemp = dTemp + (tcfg.k_wet * (last.w / 100.0) * (50 - last.t))
  dTemp = dTemp + (tcfg.k_wind * wind * (30 - last.t))
  dTemp = dTemp + (tcfg.k_activity * activity * (last.t - tcfg.comfort))

  local newT = math.max(0.0, math.min(100.0, last.t + dTemp * dt))

  -- wetness
  local gain = 0.0
  if (last.f & FLAG_WATER) == FLAG_WATER then
    gain = gain + wcfg.water_gain
  elseif precip > 0.01 and (last.f & FLAG_SHELTR) == 0 then
    gain = gain + (wcfg.rain_gain * precip)
  end
  if last.s > 2.0 and precip > 0.1 then
    gain = gain + wcfg.ground_splash
  end

  local dry = wcfg.dry_rate_base + (ambient.wind * wcfg.dry_wind_amp)
  if last.worldShelter then dry = dry + 0.3 end
  -- you can boost near fire via WorldEngine flags

  local newW = last.w + (gain - dry) * dt
  newW = math.max(0.0, math.min(100.0, newW))

  last.t = newT
  last.w = newW
end

-- send throttled change
local function maybeSend()
  local now = GetGameTimer()
  local interval = ENV_CFG.replication.interval_ms
  if now - lastSend < interval then return end

  local tb, wb, bandChanged = bands.computeBands(last.t, last.w)

  local function deltaEnough(a,b,th) return math.abs(a-b) >= th end

  local send = bandChanged
  if not send then
    send = deltaEnough(last.t, last._t or last.t, ENV_CFG.thresholds.temp) or
           deltaEnough(last.w, last._w or last.w, ENV_CFG.thresholds.wet)  or
           deltaEnough(last.s, last._s or last.s, ENV_CFG.thresholds.speed) or
           deltaEnough(last.k, last._k or last.k, ENV_CFG.thresholds.slope)
  end

  if send then
    TriggerServerEvent('envmeter:changed', {
      t = last.t, w = last.w, s = last.s, k = last.k, m = last.m, f = last.f, mo = last.mo
    })
    last._t, last._w, last._s, last._k = last.t, last.w, last.s, last.k
    lastSend = now
  end
end

-- snapshot from server (on join/resync)
RegisterNetEvent('envmeter:snapshot', function(snap)
  if type(snap) ~= 'table' then return end
  last.t = snap.temp or last.t
  last.w = snap.wet  or last.w
  last.s = snap.speed or last.s
  last.k = snap.slope or last.k
  last.m = snap.mat   or last.m
  last.f = snap.flags or last.f
  last.mo= snap.motion or last.mo
end)

CreateThread(function()
  if not ENV_CFG.enabled then return end
  local idle = ENV_CFG.timing.idle
  local changing = ENV_CFG.timing.changing
  local event = ENV_CFG.timing.event

  while true do
    local speed, mo, inWater = readMotion()
    local slope = readSlope()
    local mat = readMaterial()

    last.s = lerp(last.s, speed, 0.35)
    last.k = lerp(last.k, slope, 0.25)
    last.m = mat

    -- flags
    local f = 0
    if inWater then f = f | FLAG_WATER end
    if ambient.precip > 0.05 then f = f | FLAG_RAIN end
    if last.worldShelter then f = f | FLAG_SHELTR end
    last.f = f
    last.mo = mo

    -- step model (dt seconds)
    stepEnv(0.5)

    -- choose sleep based on activity/env changes
    local sleep = idle
    if speed > 0.5 or ambient.precip > 0.05 or (last.w > 0.1 and last.w < 99.0) then
      sleep = changing
    end
    if mo & MOT_SPRINT == MOT_SPRINT or inWater then
      sleep = event
    end

    maybeSend()
    Wait(sleep)
  end
end)