local useTarget = WORLD_CFG.integration.ox_target
local added = {}

local function addTargetForNode(node)
  if not useTarget then return end
  if added[node.id] then return end
  exports.ox_target:addSphereZone({
    coords = node.pos, radius = 1.2, debug = false,
    options = {
      {
        name = 'we_node_'..node.id,
        icon = 'fa-solid fa-hand',
        label = ('Gather (%s)'):format(node.type),
        onSelect = function() TriggerServerEvent('worldengine:node:use', node.id) end
      }
    }
  })
  added[node.id] = true
end

RegisterNetEvent('worldengine:nodes:nearby', function(list)
  for _,n in ipairs(list or {}) do addTargetForNode(n) end
end)

-- fallback (ไม่มี target): ใช้ key กด
CreateThread(function()
  if useTarget then return end
  while true do
    Wait(1000)
    -- ควรผูกกับ Dev UI หรือคำสั่งเพื่อดึง nearby nodes แล้วแสดง prompt
  end
end)