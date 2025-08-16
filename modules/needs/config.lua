NEEDS_CFG = {
  enabled = true,

  keys = { 'hunger','thirst','sleep','stamina','stress','lung_capacity' },

  -- base drain/regen per second (normalized 0..100)
  rate = {
    hunger_base   = -0.003,   -- อิ่มค่อย ๆ ลด
    thirst_base   = -0.006,
    sleep_base    = -0.002,   -- ง่วงเพิ่ม (ค่า status.sleep หมายถึง "พลังงานการนอน" เหลือ)
    stamina_regen =  +0.50,   -- ต่อวินาทีเมื่อยืนเฉย ๆ
    stress_decay  =  -0.08,   -- ลดความเครียดพื้นฐาน
    lung_regen    =  +0.80,   -- ฟื้นบนบก
  },

  -- activity multipliers (EnvMeter motion flags)
  activity = {
    walk   = { hunger=1.3, thirst=1.4, stamina=-2.0 },
    run    = { hunger=1.8, thirst=2.2, stamina=-4.0 },
    sprint = { hunger=2.5, thirst=3.0, stamina=-8.0, stress=+0.5 },
    swim   = { hunger=2.2, thirst=3.5, stamina=-6.0, lung=-2.0 },
    crouch = { hunger=1.1, thirst=1.1, stamina=-1.0 },
  },

  -- environment modifiers (from EnvMeter)
  env = {
    cold_band   = { threshold=1, hunger=+0.4, thirst=+0.2, stress=+0.4 },
    hot_band    = { threshold=3, thirst=+0.8, stress=+0.4, stamina=-1.0 },
    soaked_band = { threshold=3, hunger=+0.3, stress=+0.5, stamina=-0.5 },
  },

  -- sleep mechanics
  sleep = {
    enable = true,
    circadian_amp = 0.002,  -- ง่วงเพิ่มช่วงกลางคืน
    restore_rate  = 0.80,   -- ฟื้นขณะนอน
    min_bed_time_s= 30,     -- เวลานอนขั้นต่ำ
  },

  -- replication (server→client)
  replication = {
    interval_ms = 1200,
    hysteresis  = 1.0,   -- % change
  },

  -- integration flags
  integrate = {
    status_bridge = true,
    envmeter      = true,
    worldengine   = true,
  },

  -- clamps
  min = 0, max = 100,
}