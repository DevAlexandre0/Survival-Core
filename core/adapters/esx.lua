local A = {}
local ESX

CreateThread(function()
  while not ESX do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end); Wait(100) end
end)

function A.getPlayer(src)
  local x = ESX.GetPlayerFromId(src)
  if not x then return { id=src, name=GetPlayerName(src) } end
  return { id=src, identifier=x.getIdentifier(), name=GetPlayerName(src),
           job=x.job and x.job.name or nil, jobGrade=x.job and x.job.grade or 0, group = (x.getGroup and x.getGroup()) or nil }
end

-- notify (uses ox_lib if available, else chat)
function A.notify(src, data)
  if lib and lib.notify then lib.notify(src, { title=data.title or 'Survival', description=data.msg or data.description or '', type=data.type or 'inform' })
  else TriggerClientEvent('chat:addMessage', src, { args={ data.title or 'Info', data.msg or '' } }) end
end

-- inventory provider (prefer ox_inventory; else fallback like standalone)
return setmetatable(A, { __index = 
require('core/adapters/standalone.lua') })