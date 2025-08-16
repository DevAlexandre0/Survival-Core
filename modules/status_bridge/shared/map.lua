-- แมประหว่าง framework ต่าง ๆ -> status.* กลาง
StatusMap = {
  esx = {
    provider = 'es_extended',   -- resource name
    -- ถ้ามี esx_status: คีย์มักเป็น hunger/thirst
    keys = {
      hunger = 'hunger',
      thirst = 'thirst',
      stress = 'stress',        -- บางเซิร์ฟอาจไม่มี ให้ปล่อย nil แล้ว fallback
      sleep  = nil,
      stamina= nil,
      lung_capacity = nil
    }
  },
  qb = {
    provider = 'qb-core',
    keys = {
      hunger = 'hunger',
      thirst = 'thirst',
      stress = 'stress',        -- QBCore บางที่ใช้ metadata หรือ status system แยก
      sleep  = nil,
      stamina= nil,
      lung_capacity = nil
    }
  },
  ox = {
    provider = 'ox_core',
    keys = {
      hunger = 'hunger',
      thirst = 'thirst',
      stress = 'stress',
      sleep  = 'sleep',
      stamina= 'stamina',
      lung_capacity = 'lung_capacity'
    }
  },
  standalone = {
    provider = nil,
    keys = {
      hunger = 'hunger',
      thirst = 'thirst',
      stress = 'stress',
      sleep  = 'sleep',
      stamina= 'stamina',
      lung_capacity = 'lung_capacity'
    }
  }
}