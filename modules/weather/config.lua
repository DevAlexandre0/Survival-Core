
WEATHER_CFG = {
  enabled = true,

  mode = 'own',     -- 'own' | 'follow' | 'locked'
  scope = 'server', -- 'server' | 'bucket'  (ถ้า 'bucket' จะใช้ weather ต่อบัคเก็ต)

  sync = {
    interval_ms = 6000,
    join_blend_sec = { min = 30, max = 60 }, -- ผสานค่าค่อย ๆ เมื่อผู้เล่นเข้าใหม่
    transition_sec = { min = 35, max = 90 }, -- เวลาทรานซิชันระหว่าง preset
  },

  ambient = {
    base_tempC = 24.0,     -- อุณหภูมิพื้นฐาน
    diurnal_amp = 6.0,     -- ความต่างวัน/คืน (°C)
    humidity_base = 0.55,
    wind_base = 1.6,
  },

  -- ตาราง preset สำหรับโหมด own
  presets = {
    CLEAR   = { cloud=0.1, precip=0.0, wind=1.0, humidity=0.40, temp_bias=+1 },
    CLOUDS  = { cloud=0.5, precip=0.0, wind=2.0, humidity=0.55, temp_bias= 0 },
    FOG     = { cloud=0.7, precip=0.0, wind=0.6, humidity=0.80, temp_bias=-1 },
    RAIN    = { cloud=0.8, precip=0.6, wind=2.5, humidity=0.85, temp_bias=-1 },
    STORM   = { cloud=1.0, precip=1.0, wind=4.0, humidity=0.95, temp_bias=-2 },
    HEATWAVE= { cloud=0.2, precip=0.0, wind=1.2, humidity=0.35, temp_bias=+5 },
    COLD    = { cloud=0.4, precip=0.0, wind=2.0, humidity=0.50, temp_bias=-5 },
  },

  schedule = {
    -- โอกาสเกิด preset ตามฤดู/ช่วงเวลา (ง่าย ๆ)
    weights = {
      day   = { CLEAR=30, CLOUDS=30, FOG=5, RAIN=20, STORM=5, HEATWAVE=7, COLD=3 },
      night = { CLEAR=20, CLOUDS=40, FOG=10, RAIN=20, STORM=6, HEATWAVE=2, COLD=2 },
    },
    min_hold_min = 10,  -- อย่างน้อยกี่นาทีต่อสภาพ
    max_hold_min = 35,
  },

  external_follow = {
    -- โหมด follow: map จากสคริปต์อื่น → preset ในนี้
    map = {
      EX_CLEAR='CLEAR', EX_SMOG='FOG', EX_RAIN='RAIN', EX_STORM='STORM'
    }
  }
}