local zones    = require 'server/zones'
local res      = require 'server/resources'

WorldAPI = {}

function WorldAPI.getZoneAt(pos) return zones.getZoneAt(pos) end
function WorldAPI.getNearbyNodes(src, radius, typeFilter) return res.getNearbyNodes(src, radius, typeFilter) end
function WorldAPI.claimContainer(src, id) return res.claimContainer(src, id) end
function WorldAPI.forceRescan() zones.forceRescan() end
function WorldAPI.forceRespawn(t) res.forceRespawn(t) end