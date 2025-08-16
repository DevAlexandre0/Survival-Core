local A = {}
local QBCore

CreateThread(function()
  while not QBCore do TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end); Wait(100) end
end)

function A.getPlayer(src)
  local p = QBCore.Functions.GetPlayer(src)
  if not p then return { id=src, name=GetPlayerName(src) } end
  local job = p.PlayerData and p.PlayerData.job
  local group = (p.PlayerData and p.PlayerData.group) or nil
  return { id=src, identifier=p.PlayerData.citizenid or ('qb:'..src), name=GetPlayerName(src),
           job=job and job.name or nil, jobGrade=job and job.grade.level or 0, group=group }
end

function A.notify(src, data)
  if lib and lib.notify then lib.notify(src, { title=data.title or 'Survival', description=data.msg or data.description or '', type=data.type or 'inform' })
  else TriggerClientEvent('QBCore:Notify', src, data.msg or data.description or '', data.type or 'primary') end
end

return setmetatable(A, { __index = require('core/adapters/standalone.lua') })