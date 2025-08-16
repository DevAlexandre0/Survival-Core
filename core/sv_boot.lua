local cfg = require('config/core.lua')
local api = require('core/api.lua')
local Utils = require('core/utils.lua')

local function resExists(name) return GetResourceState(name) ~= 'missing' end

local function detectFramework()
  if cfg.strict_framework == 'esx' or (not cfg.strict_framework and resExists('es_extended')) then return 'esx' end
  if cfg.strict_framework == 'qb'  or (not cfg.strict_framework and resExists('qb-core'))     then return 'qb'  end
  if cfg.strict_framework == 'ox'  or (not cfg.strict_framework and resExists('ox_core'))     then return 'ox'  end
  return 'standalone'
end

CreateThread(function()
  local fw = detectFramework()
  if fw == 'esx' then
    api.cl = require('core/adapters/esx.lua')
  elseif fw == 'qb' then
    api.cl = require('core/adapters/qb.lua')
  elseif fw == 'ox' then
    api.cl = require('core/adapters/ox.lua')
  else
    api.cl = require('core/adapters/standalone.lua')
  end
  Utils.log('info', ('Adapter: %s'):format(fw))
end)