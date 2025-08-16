local last = { t=0 }
local function now() return GetGameTimer() end

local function readTelemetry()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped,false)
  if veh == 0 or GetPedInVehicleSeat(veh,-1) ~= ped then return nil end

  local net  = NetworkGetNetworkIdFromEntity(veh)
  local plate= GetVehicleNumberPlateText(veh)
  local model= GetEntityModel(veh)
  local speed= GetEntitySpeed(veh) -- m/s

  -- style approx
  local accel = IsControlPressed(0,71) -- W/accelerate
  local handbrake = IsControlPressed(0,76)
  local style = (handbrake and 'stunt') or (accel and 'aggressive') or 'normal'

  -- terrain (หยาบ): map จาก surface material ได้ถ้าต้อง
  local terrain = 'asphalt'
  if IsVehicleOnAllWheels(veh) and IsPointOnRoad(GetEntityCoords(veh).x, GetEntityCoords(veh).y, GetEntityCoords(veh).z, veh) then
    terrain = 'asphalt'
  end

  -- inWater: จาก native
  local inWater = IsEntityInWater(veh)

  return {
    net=net, plate=plate, model=model,
    speed=speed, rpm=GetVehicleCurrentRpm(veh)*6000,
    terrain=terrain, style=style, inWater=inWater, crash=false
  }
end

CreateThread(function()
  while true do
    if not VEH_CFG.enabled then Wait(1000) goto continue end
    local t = readTelemetry()
    local n = now()
    if t then
      local dt = (n - (last.t or n)) / 1000.0
      t.dt = math.max(0.1, math.min(1.0, dt))
      TriggerServerEvent('vehicleSystem:telemetry', t)
      Wait(VEH_CFG.tick.active_ms)
    else
      Wait(VEH_CFG.tick.idle_ms)
    end
    last.t = n
    ::continue::
  end
end)

-- แจ้งเตือนเบา
RegisterNetEvent('vehicleSystem:warn', function(msg)
  lib.notify({ title='Vehicle', description=tostring(msg), type='warning' })
end)

-- Inspect / Repair commands (สามารถผูก key หรือเมนูได้)
RegisterCommand('veh_inspect', function() TriggerServerEvent('vehicleSystem:inspect') end)
RegisterNetEvent('vehicleSystem:inspect:result', function(okOrData, maybe)
  local st = okOrData
  if type(okOrData)=='boolean' then if okOrData then st=maybe else lib.notify({title='Vehicle', description=tostring(maybe), type='error'}) return end end
  if type(st)~='table' then return end
  local lines={}
  for k,v in pairs(st.parts or {}) do lines[#lines+1]=('%s: %d'):format(k, math.floor(v)) end
  lines[#lines+1]=('Fuel: %.1f L'):format(st.fluids and st.fluids.fuel or 0)
  lines[#lines+1]=('Heat: %.1f °C'):format(st.heat or 0)
  lib.notify({ title='Vehicle Inspect', description=table.concat(lines,'\n'), type='inform' })
end)

RegisterNetEvent('vehicleSystem:repair:result', function(ok, data)
  lib.notify({ title='Repair', description= ok and (('%s %s → %d'):format(data.level,data.part, data.new)) or tostring(data), type= ok and 'success' or 'error' })
end)
RegisterNetEvent('vehicleSystem:service:result', function(ok, data)
  lib.notify({ title='Service', description= ok and json.encode(data) or tostring(data), type= ok and 'success' or 'error' })
end)