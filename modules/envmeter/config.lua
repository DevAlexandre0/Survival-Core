ENV_CFG = {
  enabled = true,

  -- timing (ms)
  timing = {
    idle     = 1800,
    changing = 900,
    event    = 500,
  },

  -- thresholds for change (avoid spam)
  thresholds = {
    speed   = 0.25,   -- m/s
    slope   = 1.0,    -- deg
    temp    = 1.5,    -- absolute delta (0-100)
    wetness = 2.0,    -- absolute delta (0-100)
  },

  -- band replication (send only when band changed)
  replication = {
    by_band      = true,
    interval_ms  = 1500, -- min interval between sends
    hysteresis_p = 2,    -- % change minimum to consider changed
  },

  -- temperature model
  temp_model = {
    comfort      = 50,
    cold_th      = 30,
    heat_th      = 75,
    k_env        = 0.03,
    k_wet        = 0.05,
    k_wind       = 0.035,
    k_activity   = -0.02,  -- activity warms up (negative pulls toward comfort)
    wind_chill   = true,
    heat_index   = true,
  },

  -- wetness model
  wet_model = {
    rain_gain      = 0.8,  -- /s under rain
    water_gain     = 3.0,  -- /s in water
    ground_splash  = 0.2,  -- /s on wet ground while running
    dry_rate_base  = 0.5,  -- /s
    dry_wind_amp   = 0.3,
    dry_fire_bonus = 1.2,
  },

  -- terrain/material multipliers (affects stamina externally, here for flags)
  material_cost = {
    asphalt = 1.0,
    dirt    = 1.1,
    mud     = 1.3,
    sand    = 1.25,
    snow    = 1.5,
  },

  -- integration switches
  integrate = {
    weather     = true, -- pull ambient from Weather if present
    worldengine = true, -- read zones: shelter/heat/water/danger
  },

  -- payload compaction (server-side)
  compact_payload = true,
}