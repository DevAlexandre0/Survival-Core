WORLD_CFG = {
  enabled = true,

  scan = {
    interval_ms = { idle = 9000, active = 3500 },
    radius = 120.0,       -- รัศมีแคชต่อผู้เล่น
    prop_whitelist = {    -- props ที่จับแล้วแปลงเป็นโซน/โนด
      heat = {'prop_campfire', 'prop_bbq_3'},
      water= {'prop_water_cooler', 'prop_water_barrel'},
      shelter={'prop_gazebo', 'prop_tent_01'},
      danger={'prop_barrel_02a', 'prop_gas_tank_02a'}
    }
  },

  zones = {
    shelter = { temp_bonus = 6,  wind_block = 0.5 },
    heat    = { temp_bonus = 12, dry_rate = 1.0, range = 6.0 },
    water   = { thirst_restore = 20, wet_gain = 0.3, range = 3.0 },
    danger  = { sickness_gain = 0.1, damage_min=0, damage_max=0 }
  },

  surface = {
    weather_awareness = true,
    materials = {
      ice  = { slip_chance = 0.2, temp_bias = -5 },
      mud  = { speed_mult = 0.8,  wet_gain = 0.2 },
      hot_asphalt = { temp_bias = 4 }
    }
  },

  -- Resources / Looting (consumed by server/resources.lua)
  resources = {
      limits = {
        per_player_per_min = 5,  -- resource_limit
        per_node_cooldown_s = 50,
        per_container_lock_s = 10
      },
    nodes = {
      mining  = { tools={'pickaxe'},  respawn_min=15*60, respawn_max=45*60, stamina_cost=6 },
      woodcut = { tools={'hatchet'},  respawn_min=10*60, respawn_max=30*60, stamina_cost=5 },
      forage  = { tools={},           respawn_min=5*60,  respawn_max=20*60, stealth_bonus=true },
      fishing = { tools={'rod'},      respawn_min=2*60,  respawn_max=5*60,  weather_bonus={ rain=0.1 } },
      salvage = { tools={'crowbar'},  respawn_min=20*60, respawn_max=60*60, injury_risk=0.02 },
    },
    containers = {
      urban_crate = { lockpick=true, respawn_min=30*60, respawn_max=90*60, party_instance=true }
    },
    drops = { -- ตัวอย่างโครง; แก้/เพิ่มได้
      mining = {
        common = {
          { item='stone', min=1, max=3, weight=60 },
          { item='iron_ore', min=1, max=2, weight=30 },
        },
        rare = {
          { item='gold_ore', min=1, max=1, weight=7 },
          { item='gem', min=1, max=1, weight=3 },
        },
        modifiers = { biome={ mountain=0.20 }, season={ winter=0.05 }, weather={ storm=0.05 } }
      },
      forage = {
        common = { {item='herb',min=1,max=3,weight=70}, {item='berry',min=1,max=4,weight=30} },
        rare   = { {item='truffle',min=1,max=1,weight=2} },
        modifiers = { after_rain=0.10, night=0.05 }
      }
    }
  },

  integration = {
    ox_target = true,
    ox_inventory = 'auto',   -- 'auto' | 'ox' | 'fallback'
  },

  security = {
    whitelist_strict = true,
    los_check = true,
    max_interact_dist = 2.2,
  }
}

