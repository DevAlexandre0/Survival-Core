return {
  -- Framework
  strict_framework = false,        -- 'esx'|'qb'|'ox'|'standalone'|false (auto)

  -- Persistence (oxmysql-first)
  persistence = 'oxmysql',
  schema_version = 1,              -- core schema version (bump when needed)

  -- Tick / Performance
  perf = {
    tick_base_ms = 1000,
    tick_idle_ms = 2500,
    tick_burst_ms = 500,
    batch_save_size = 25,
    max_replication_per_tick = 64,
  },

  -- Replication
  statebag_prefix = 'svv_',
  replication = {
    allowlist = { 'inv', 'job', 'group', 'flags', 'telemetry', 'public' },
    budget = { max_keys = 24, max_bytes = 16 * 1024, policy = 'queue' }, -- queue|drop|merge
  },

  -- Security / Rate-limit
  security = {
    schema_strict = true,
    max_payload_bytes = 8 * 1024,
    max_depth = 4,
    replay_window = 8, -- seconds
  },
  ratelimit = {
    telemetry = { rate = 1, window = 2 },    -- 1/2s
    ui        = { rate = 4, window = 3 },
    inventory = { rate = 5, window = 3 },
  },

  -- Recovery
  recovery = {
    flush_timeout_ms = 5000,
    retry_backoff_ms = 750,
    max_retries = 5,
    breaker_window_ms = 4000,
  },

  -- Inventory
  inventory = {
    provider = 'auto',      -- auto|fallback|ox_inventory
    fallback = {
      max_stack = 100,
      max_meta_bytes = 1024,
      max_meta_depth = 3,
      ui = {
        enabled = true,
        command = 'inv',
        keybind = nil,      -- e.g. 'F2'
        nearby_radius = 3.0,
        allow_drop = false
      }
    },
    migrate = { on_switch = true }
  },

  -- Join preload (deferrals)
  join = { preload = { enabled = true } },

  -- Dev UI & Logging
  dev_ui = { enabled = true, command = 'svcore', permission = 'admin' },
  debug = { logging = 'info', structured = true },

  -- Profiles (quick switch via admin command)
  profiles = {
    dev =   { debug = { logging='debug' }, dev_ui = { enabled=true } },
    staging={ debug = { logging='info'  }, dev_ui = { enabled=true } },
    prod =  { debug = { logging='warn'  }, dev_ui = { enabled=false } },
  }
}