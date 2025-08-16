WEATHER_CFG = {
  enabled = true,
  interval_ms = 7000,
  mode = 'locked', -- 'own' | 'follow' | 'locked'

  ambient = {
    base_tempC = 24.0,
    wind_base = 0.1,
    humidity_base = 0.55,
  },

  sync = {
    transition_sec = { min = 5, max = 15 },
    join_blend_sec = { min = 5, max = 10 },
  },

  external_follow = {
    map = {
      EX_CLEAR = 'CLEAR',
      EX_SMOG  = 'FOG',
      EX_RAIN  = 'RAIN',
      EX_STORM = 'STORM',
    }
  }
}
