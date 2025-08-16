local cfg = require('config/core.lua')
local Util = require('core/utils.lua')

local A = {}
local hasOxInv   = exports and exports.ox_inventory
local hasOxLib   = lib ~= nil
local hasOxTarget= exports and exports.ox_target

-- ensure player state skeleton
local function ensure(src)
  local st = exports['survival_core']:getState(src); if not st then return nil end
  st.identity = st.identity or {}
  st.job = st.job or { name='unemployed', grade=0 }
  st.group = st.group or 'user'

  if (cfg.inventory.provider ~= 'ox_inventory') and (not hasOxInv) then
    st.inv = st.inv or {}
  end
  return st
end

function A.getPlayer(src)
  local st = ensure(src) or {}
  return { id=src, identifier=st.identity.identifier or ('temp:'..src), name=GetPlayerName(src), job=st.job.name, jobGrade=st.job.grade, group=st.group }
end

-- notify
function A.notify(src, data)
  local title = data.title or 'Survival'; local msg = data.msg or data.description or ''; local typ = data.type or 'inform'
  if hasOxLib and lib.notify then lib.notify(src, { title=title, description=msg, type=typ })
  else TriggerClientEvent('chat:addMessage', src, { args = { title, msg } }) end
end

-- inventory provider
if hasOxInv or cfg.inventory.provider == 'ox_inventory' then
  function A.invAdd(src, item, count, meta) return exports.ox_inventory:AddItem(src, item, count or 1, meta) end
  function A.invRemove(src, item, count, meta) return exports.ox_inventory:RemoveItem(src, item, count or 1, meta) end
  function A.invHas(src, item, count) return (exports.ox_inventory:Search(src, 'count', item) or 0) >= (count or 1) end
else
  -- ultralight fallback
  local function count(st, item) return (st.inv[item] and st.inv[item].count) or 0 end
  function A.invHas(src, item, n) local st=ensure(src); if not st then return false end return count(st,item) >= (n or 1) end
  function A.invAdd(src, item, n, meta) local st=ensure(src); if not st then return false end
    local slot = st.inv[item] or { count=0, meta={} }
    slot.count = math.min((slot.count or 0) + (n or 1), cfg.inventory.fallback.max_stack or 100)
    if meta then slot.meta = meta end
    st.inv[item]=slot
    exports['survival_core']:setState(src, 'inv', st.inv)
    return true
  end
  function A.invRemove(src, item, n)
    local st=ensure(src); if not st then return false end
    local slot=st.inv[item]; if not slot or slot.count < (n or 1) then return false end
    slot.count = slot.count - (n or 1)
    if slot.count <= 0 then st.inv[item]=nil else st.inv[item]=slot end
    exports['survival_core']:setState(src, 'inv', st.inv)
    return true
  end
end

-- target (optional)
function A.targetAdd(subj, options) if exports.ox_target and options then return exports.ox_target:addModel(subj, options) end end
function A.targetRemove(id) if exports.ox_target then exports.ox_target:removeZone(id) end end

return A