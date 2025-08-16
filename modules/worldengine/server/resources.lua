local M = {}
local cfg = WORLD_CFG.resources
local nodes = {}      ---@type table<string, Node>
local containers = {} ---@type table<string, Container>
local lastUse = {}    -- per-player rate limit

local function now() return os.time() end
local function keyPerMin(src, typ) return ('%s:%s'):format(src, typ) end

local function canUse(src, typ)
  local k = keyPerMin(src, typ)
  local t = lastUse[k] or 0
  local n = now()
  if n - t < 60/cfg.limits.per_player_per_min then return false end
  lastUse[k] = n
  return true
end

-- ===== Nodes =====
local function respawnAt(secMin, secMax) return now() + math.random(secMin, secMax) end

local function ensureNode(id, typ, pos)
  if nodes[id] then return nodes[id] end
  local def = cfg.nodes[typ] ; if not def then return nil end
  nodes[id] = { id=id, type=typ, pos=pos, ready=true, respawnAt=0 }
  return nodes[id]
end

function M.spawnNode(id, typ, pos)
  local n = ensureNode(id, typ, pos) ; if not n then return end
  n.ready = true ; n.respawnAt = 0
end

function M.consumeNode(src, id)
  local n = nodes[id]; if not n then return false, 'invalid_node' end
  if not n.ready then return false, 'depleted' end
  local def = cfg.nodes[n.type]
  if def.stamina_cost then TriggerEvent('survival:status:stamina:use', src, def.stamina_cost) end
  -- tool check (server-authoritative)
  if #def.tools > 0 then
    local ok = exports.ox_inventory:Search(src, 'count', def.tools) > 0
    if not ok then return false, 'need_tool' end
  end
  if not canUse(src, n.type) then return false, 'rate_limited' end

  n.ready = false
  n.respawnAt = respawnAt(def.respawn_min, def.respawn_max)

  -- roll drops
  local function roll(pool)
    local total=0 for _,e in ipairs(pool) do total=total+e.weight end
    local r = math.random(1,total)
    local cum=0
    for _,e in ipairs(pool) do cum=cum+e.weight if r<=cum then return e end end
  end
  local dp = (WORLD_CFG.resources.drops[n.type]) or { common = {} }
  local result = {}

  local draws = math.random(1,2)
  for i=1,draws do
    local e = roll(dp.common)
    if e then
      local amt = math.random(e.min or 1, e.max or 1)
      table.insert(result, { item=e.item, count=amt })
    end
  end
  -- rare chance (simple 10%)
  if dp.rare and math.random() < 0.10 then
    local e = roll(dp.rare)
    if e then table.insert(result, { item=e.item, count=math.random(e.min or 1, e.max or 1) }) end
  end

  -- give items (ox or fallback)
  if WORLD_CFG.integration.ox_inventory ~= false then
    for _,it in ipairs(result) do exports.ox_inventory:AddItem(src, it.item, it.count) end
  else
    TriggerClientEvent('worldengine:resources:result', src, result)
  end

  return true, result
end

function M.tickNodes()
  local t = now()
  for id,n in pairs(nodes) do
    if not n.ready and n.respawnAt > 0 and t >= n.respawnAt then
      n.ready = true ; n.respawnAt = 0
      -- optional: notify nearby
    end
  end
end

function M.getNearbyNodes(src, radius, typeFilter)
  local ped = GetPlayerPed(src)
  local p = GetEntityCoords(ped)
  local list = {}
  for _,n in pairs(nodes) do
    if n.ready and (not typeFilter or n.type==typeFilter) then
      local d = #(p - n.pos)
      if d <= (radius or 20.0) then table.insert(list, { id=n.id, type=n.type, pos=n.pos }) end
    end
  end
  return list
end

-- ===== Containers =====
local function ensureContainer(id, class, pos)
  if containers[id] then return containers[id] end
  containers[id] = { id=id, class=class, pos=pos, lockedUntil=0 }
  return containers[id]
end

function M.spawnContainer(id, class, pos)
  ensureContainer(id, class, pos)
end

function M.claimContainer(src, id)
  local c = containers[id]; if not c then return false, 'invalid_container' end
  local t = GetGameTimer()
  if t < (c.lockedUntil or 0) then return false, 'locked' end
  c.lockedUntil = t + (WORLD_CFG.resources.limits.per_container_lock_s * 1000)
  local token = ('%s:%d'):format(id, t)
  return true, token
end

RegisterNetEvent('worldengine:container:open', function(id)
  local src = source
  if not canUse(src, 'container') then return end
  local ok, token = M.claimContainer(src, id)
  if not ok then return end
  -- roll drops from class
  local class = (containers[id] or {}).class
  local dp = WORLD_CFG.resources.drops[class] or WORLD_CFG.resources.drops['forage'] -- reuse table
  local result = {}
  if dp and dp.common then
    local function roll(pool)
      local total=0 for _,e in ipairs(pool) do total=total+e.weight end
      local r = math.random(1,total)
      local cum=0
      for _,e in ipairs(pool) do cum=cum+e.weight if r<=cum then return e end end
    end
    for i=1,2 do
      local e = roll(dp.common)
      if e then table.insert(result, { item=e.item, count=math.random(e.min or 1, e.max or 1) }) end
    end
    if dp.rare and math.random() < 0.10 then
      local e = roll(dp.rare)
      if e then table.insert(result, { item=e.item, count=math.random(e.min or 1, e.max or 1) }) end
    end
  end
  for _,it in ipairs(result) do exports.ox_inventory:AddItem(src, it.item, it.count) end
  TriggerClientEvent('worldengine:resources:result', src, result)
end)

function M.forceRespawn(typeFilter)
  for _,n in pairs(nodes) do
    if not typeFilter or n.type==typeFilter then n.ready=true n.respawnAt=0 end
  end
end

RegisterNetEvent('worldengine:node:use', function(id)
  local src = source
  if not id then return end
  local ok, result = M.consumeNode(src, id)
  if not ok then
    TriggerClientEvent('ox_lib:notify', src, {type='error', description=tostring(result) })
  end
end)

RegisterNetEvent('worldengine:requestNearbyNodes', function(pos)
  local src = source
  if type(pos) ~= 'vector3' and type(pos) ~= 'table' then return end
  local list = M.getNearbyNodes(src, 20.0, nil)
  TriggerClientEvent('worldengine:nearbyNodes', src, list)
end)

return M