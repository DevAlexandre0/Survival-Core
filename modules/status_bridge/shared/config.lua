STATUS_CFG = {
  enabled = true,

  keys = { 'hunger', 'thirst', 'sleep', 'stamina', 'stress', 'lung_capacity' },

  -- hard limits
  min = 0,
  max = 100,

  -- rate-limit writes per player
  write_limits = {
    per_second = 10,   -- สูงพอสำหรับเกมเพลย์ ป้องกัน spam
    burst = 15
  },

  -- framework auto-detect order
  detect_order = { 'ox', 'qb', 'esx', 'standalone' },

  -- when framework provider missing certain keys, fill with defaults
  defaults = {
    hunger = 50, thirst = 50, sleep = 70, stamina = 100, stress = 0, lung_capacity = 100
  },

  -- replication
  replication = {
    interval_ms = 800,    -- coalesce
    hysteresis = 1.0,     -- % change required
  },

  -- security
  deny_external_write = false, -- ถ้า true: ยอมรับเฉพาะจาก adapters/whitelist
  whitelist_resources = {      -- ถ้าอยากจำกัดสคริปต์ที่ใช้ set()
    -- 'your_resource_name'
  },
}
