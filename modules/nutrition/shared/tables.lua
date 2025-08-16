-- ตารางสูตร/โปรไฟล์อาหาร
FoodProfiles = {
  raw_meat = { calories=350, water=0, warmth=2, base_spoil_mod=1.2 },
  veggie   = { calories=120, water=20, warmth=0, base_spoil_mod=1.0 },
  soup     = { calories=180, water=35, warmth=6, base_spoil_mod=0.9 },
  fish     = { calories=220, water=5,  warmth=1, base_spoil_mod=1.1 },
}

-- mapping จาก item name → โปรไฟล์ + meta เริ่มต้น
FoodItems = {
  ['meat_raw']   = { profile='raw_meat', meta={ kind='raw_meat', opened=false, doneness=0, spoil=0 } },
  ['meat_cooked']= { profile='raw_meat', meta={ kind='raw_meat', opened=true,  doneness=50, spoil=0 } },
  ['veggie_raw'] = { profile='veggie',   meta={ kind='veggie',  opened=false, doneness=0,  spoil=0 } },
  ['soup_broth'] = { profile='soup',     meta={ kind='soup',    opened=true,  doneness=50, spoil=0 } },
  ['fish_raw']   = { profile='fish',     meta={ kind='fish',    opened=false, doneness=0,  spoil=0 } },
}

-- ไอเท็มภาชนะน้ำ
WaterItems = {
  ['water_bottle'] = { meta={ quality='clean', liters=0.5, container='bottle' } },
  ['canteen']      = { meta={ quality='natural', liters=1.0, container='canteen' } },
  ['jerrycan']     = { meta={ quality='contaminated', liters=10.0, container='jerry' } },
}

-- ผลจากการบริโภค (รวมอาหาร/น้ำ)
function ComputeConsumeEffect(item, meta)
  local res = { hunger=0, thirst=0, stress=0, stamina=0, warmth=0, risk_food_poison=0, risk_cholera=0 }

  if FoodItems[item] then
    local prof = FoodProfiles[FoodItems[item].profile]
    local don  = meta.doneness or 0
    local cooked = (don >= NUT_CFG.cooking.safe_at)
    res.hunger = math.floor(prof.calories / 10)
    res.thirst = prof.water
    res.warmth = prof.warmth + (don>=50 and 2 or 0)
    local rawRisk = NUT_CFG.cooking.safety_risk_raw
    res.risk_food_poison = cooked and 0 or rawRisk
    -- spoil สูง → เสี่ยงเพิ่ม
    res.risk_food_poison = res.risk_food_poison + (meta.spoil or 0)/100 * 0.15
  elseif WaterItems[item] then
    local q = (meta.quality or 'natural')
    if q == 'clean' then res.thirst = 25
    elseif q == 'natural' then res.thirst = 20
    else res.thirst = 15 end
    -- เสี่ยงจากคุณภาพน้ำ
    local riskmap = NUT_CFG.water.cholera_risk
    res.risk_cholera = (q=='clean' and 0) or (q=='natural' and riskmap.natural) or riskmap.contaminated
  end

  return res
end