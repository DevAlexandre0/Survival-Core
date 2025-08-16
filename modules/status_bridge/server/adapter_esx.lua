server = server or {}
local started = false
local ESX

local function tryGetESX()
  if ESX then return ESX end
  if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended'] and exports['es_extended']:getSharedObject()
  end
  return ESX
end

local function onUseItem(name, cb)
  if GetResourceState('ox_inventory') == 'started' then
    exports.ox_inventory:registerUsableItem(name, function(src, item, data)
      local ok, err = pcall(cb, src, item, data)
      if not ok then print('[SB][useitem] error:', err) end
    end)
  end
end

-- Map common survival items -> Needs/Nutrition
local function registerDefaultItems()
  local needsAdd = function(src, key, delta) exports[GetCurrentResourceName()]:sc_call('needs', 'add', src, key, delta) end
  onUseItem('water', function(src) needsAdd(src,'thirst', 25) end)
  onUseItem('bread', function(src) needsAdd(src,'hunger', 20) end)
  onUseItem('coffee', function(src) needsAdd(src,'stress', -5); needsAdd(src,'stamina', 10) end)
end

server.start = function()
  if started then return end
  started = true
  tryGetESX()
  registerDefaultItems()
  print('[SB] ESX/ox adapter started')
end

server.stop = function() started=false end
