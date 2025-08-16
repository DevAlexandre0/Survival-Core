SC_CFG = {
  version = 'v2-full-upgrade-prod',
  name = 'SurvivalCore',
  modules = { status_bridge = true, needs = true, medical = true, skill = true, vehicle_system = true, weather = true, nutrition = true },
  save = { enabled = true, interval_ms = 120000 },
  dev = { ace = 'sc.dev' }
}
