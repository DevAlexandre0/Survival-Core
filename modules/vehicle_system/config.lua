VEH_CFG = {
  enabled = true,

  tick = {
    idle_ms   = 2500,    -- ไม่มีคนขับ/ไม่เคลื่อนที่
    active_ms = 900,     -- มีคนขับ/เคลื่อนที่
    event_ms  = 450,     -- เหตุการณ์เร่ง (ชน/ลุยน้ำ/เร่งหนัก)
  },

  fuel = {
    per_km        = 0.08,      -- ลิตรต่อกม. (ขึ้นกับรถจริง ๆ ได้)
    idle_drain    = 0.005,     -- ลิตรต่อนาที
    tank_capacity = 65.0,      -- ลิตร (ค่าเริ่มต้นถ้าอ่านไม่ได้)
  },

  heat = {
    overheat_at = 92.0,        -- °C (สมมติ)
    cool_rate   = 0.8,         -- °C/s
    heat_gain_per_rpm = 0.015, -- °C/s per 1000rpm
    water_wade_amp   = 1.4,    -- ลุยน้ำทำให้ร้อนขึ้น/เสี่ยงดับ
  },

  wear = {
    per_km = {
      engine=0.08, tires=0.20, brakes=0.16, transmission=0.10, battery=0.04, filter=0.07, suspension=0.10
    },
    terrain_amp = { asphalt=1.0, dirt=1.15, mud=1.35, sand=1.25, snow=1.5 },
    style_amp   = { normal=1.0, aggressive=1.5, stunt=2.0 },
    weather_amp = { rain=1.15, storm=1.25, heatwave=1.10 },
    crash_amp   = 3.0, -- ชนแรงคูณ wear burst
  },

  repair = {
    procedures = { quick=6, standard=18, overhaul=45 }, -- seconds
    workshop_bonus = 0.85,
    roadside_penalty = 1.15,
    kits = { quick='toolkit_basic', standard='toolkit_adv', overhaul='toolkit_master' }, -- ox_inventory items
    parts = {
      engine='part_engine', tires='part_tire', brakes='part_brake',
      transmission='part_tranny', battery='part_battery', filter='part_filter', suspension='part_susp'
    }
  },

  rescue = {
    tow=true, winch=true, slope_max=18.0, mass_max=3500.0
  },

  integration = {
    skill=true,     -- ใช้สกิล mechanic/driver ถ้ามี
    weather=true,   -- ambient/ฝน
    envmeter=true,  -- flags น้ำ/โคลน
    world=true,     -- zone workshop/lift
    ox_inventory='auto',
    ox_target=true
  },

  security = {
    rate_limit = { telemetry_per_s=10, repair_per_min=6, service_per_min=8 },
    lock_during_procedure = true, -- ล็อครถขณะซ่อม
    max_interact_dist = 3.0
  }
}