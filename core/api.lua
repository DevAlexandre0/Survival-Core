local api = {}

api.TOPIC = {
  PLAYER_LOADED   = 'svcore:playerLoaded',
  PLAYER_UNLOADED = 'svcore:playerUnloaded',
  STATE_CHANGED   = 'svcore:stateChanged',
  TICK            = 'svcore:tick',
}

function api.on(ev, cb) AddEventHandler(ev, cb) end
function api.emit(ev, ...)  TriggerEvent(ev, ...) end

-- These are set by sv_core exports
function api.getState(src) return exports['survival_core']:getState(src) end
function api.setState(src, key, val) return exports['survival_core']:setState(src, key, val) end

-- Filled by sv_boot (selected adapter)
api.cl = {}

return api