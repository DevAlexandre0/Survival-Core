NUT_CFG = {
  enabled = true,
  tick_ms = 6000,

  spoil = {
    enabled = true,
    tick_ms = 10000,
    base_rate = 0.05,
    open_multiplier = 1.5,
    env = { temp_amp_per_C = 0.02, humidity_amp = 0.3, rain_bonus = 0.5 },
    container_mod = { bottle = 0.5, can = 0.3 },
  },
}
