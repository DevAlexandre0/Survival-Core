local cfg = require('config/core.lua')
local api = require('core/api.lua')
local Util = require('core/utils.lua')
local hasLib = lib ~= nil

-- server actions called from client dev UI (use ox_lib callbacks if present)
if hasLib then
  lib.callback.register('svcore:getOverview', function(src)
    local st = api.getState(src) or {}
    return {
      adapter = 'active',
      db = 'ok',
      player = { id = src, keys = (st and next(st)) and 1 or 0 }
    }
  end)

  lib.callback.register('svcore:flushPlayer', function(src, target)
    local t = tonumber(target) or src
    local st = api.getState(t)
    if not st then return false end
    local lic
    for _, id in ipairs(GetPlayerIdentifiers(t)) do if id:find('license:') == 1 then lic = id break end end
    if not lic then return false end
    local Storage = require('core/storage/oxmysql.lua')
    Storage.savePlayer(lic, st)
    return true
  end)
end