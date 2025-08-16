SKILL_CFG = {
  enabled = true,

  keys = { 'mechanic','driver','survival','cooking','foraging','medicine','fishing','athletics','marksman' },

  xp_curve = {
    -- XP ต้องใช้ต่อ rank (สะสม): 0→1, 1→2, 2→3
    bands = { 200, 600, 1400 }  -- รวมสะสมเพื่อ master ≈ 2200 XP
  },

  daily_dr = {
    enable = true,
    window_min = 24*60,      -- 24 ชม.
    base = 1.0,              -- 100%
    min_mult = 0.25,         -- ต่ำสุด 25% ถ้าฟาร์มหนัก
    decay_per_award = 0.05,  -- ลดครั้งละ 5%
    recover_per_min = 0.005, -- ฟื้นตัวตามเวลา
  },

  rate_limit = {
    per_key_per_min = 20,    -- กันสแปมอีเวนต์ XP
    per_player_per_min = 60,
  },

  grant = {
    -- ชุดแนะนำ (คุณเพิ่ม/แก้ใน rules.lua เพื่อ hook event จริง)
    mechanic = { min=2, max=6 },
    driver   = { min=1, max=4 },
    survival = { min=1, max=3 },
    cooking  = { min=1, max=3 },
    foraging = { min=1, max=3 },
    medicine = { min=1, max=4 },
    fishing  = { min=1, max=3 },
    athletics= { min=1, max=3 },
    marksman = { min=1, max=2 },
  },

  integration = {
    vehicle_system = true,
    nutrition = true,
    medical = true,
    worldengine = true,
  }
}
