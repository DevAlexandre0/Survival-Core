local M = {}
local Z = {}
local playerFlags = {}

local function dist(a,b) local dx,dy,dz=a.x-b.x,a.y-b.y,a.z-b.z return math.sqrt(dx*dx+dy*dy+dz*dz) end

local function buildStaticZones()
  Z = {}
  -- ตัวอย่าง: จาก config (สามารถโหลดจาก DB/ไฟล์ก็ได้)
  -- เพิ่มเติม dynamic จาก prop scan ได้ใน main.lua
end

local function flagsForPos(pos)
  local f = 0
  for _,z in pairs(Z) do
    if dist(pos, z.center) <= (z.range or 3.5) then
      if z.type == 'shelter' then f = f | WorldFlags.SHELTER end
      if z.type == 'heat'    then f = f | WorldFlags.HEAT end
      if z.type == 'water'   then f = f | WorldFlags.WATER end
      if z.type == 'danger'  then f = f | WorldFlags.DANGER end
    end
  end
  return f
end

function M.getZoneAt(pos)
  for _,z in pairs(Z) do
    if dist(pos, z.center) <= (z.range or 3.5) then
      return z
    end
  end
  return nil
end

function M.onTickBroadcastFlags()
  for _,src in ipairs(GetPlayers()) do
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local f = flagsForPos(pos)
    if playerFlags[src] ~= f then
      playerFlags[src] = f
      TriggerClientEvent('worldengine:flags', src, {
        shelter = (f & WorldFlags.SHELTER) ~= 0,
        heat    = (f & WorldFlags.HEAT) ~= 0,
        water   = (f & WorldFlags.WATER) ~= 0,
        danger  = (f & WorldFlags.DANGER) ~= 0,
      })
    end
  end
end

function M.injectDynamicZones(list)
  for _,z in ipairs(list or {}) do Z[z.id]=z end
end

function M.forceRescan()
  buildStaticZones()
end

AddEventHandler('playerDropped', function() playerFlags[source] = nil end)

buildStaticZones()
return M