MED_CFG = {
  enabled = true,

  tick = { idle_ms = 2200, event_ms = 600 }, -- adaptive

  replication = {
    by_stage = true,
    interval_ms = 1200
  },

  -- injury base progression (per minute, scaled by severity 1..3)
  injury = {
    bleed_rate = { 0.2, 0.6, 1.2 },  -- blood loss /min
    pain_gain  = { 0.5, 1.0, 2.0 },  -- pain /min
    infect_chance = { 0.02, 0.06, 0.12 }, -- per min if dirty/wet
  },

  sickness = {
    food_poison = { dur_min=10, dur_max=40, thirst_mult=1.4, stamina_mult=0.8 },
    cholera     = { dur_min=20, dur_max=60, thirst_mult=1.8, stamina_mult=0.7 },
    flu         = { dur_min=25, dur_max=90, stamina_mult=0.85, temp_bias=2 },
  },

  blood = { start_volume = 100, transfuse_rate = 2.5 }, -- /sec

  env_mod = {
    cold = { pain_amp=1.1, bleed_amp=1.1 },
    hot  = { infect_amp=1.15 },
    wet  = { infect_amp=1.25 },
  },

  integrate = {
    envmeter = true,
    needs    = true,
    world    = true,
  },

  security = {
    rate_limit_treat_per_min = 8
  }
}
