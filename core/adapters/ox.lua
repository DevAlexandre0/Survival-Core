-- ox_core mapping is thin now; rely on standalone for inventory fallback, ox_inventory when present
local A = {}

function A.getPlayer(src)
  local name = GetPlayerName(src)
  -- ox_core often uses state/exports; keep it minimal
  return { id=src, identifier=('ox:'..src), name=name, job=nil, jobGrade=0, group=nil }
end

function A.notify(src, data)
  if lib and lib.notify then lib.notify(src, { title=data.title or 'Survival', description=data.msg or data.description or '', type=data.type or 'inform' })
  else TriggerClientEvent('chat:addMessage', src, { args={ data.title or 'Info', data.msg or '' } }) end
end

return setmetatable(A, { __index = require('core/adapters/standalone.lua') })