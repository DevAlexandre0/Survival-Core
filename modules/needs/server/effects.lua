local FX = {}

-- ปรับสเตตอื่นตาม Needs (hook ได้)
-- ตัวอย่าง: stamina ต่ำ → ลดความเร็วเล็กน้อย, thirst ต่ำ → เพิ่มโอกาสหน้ามืด (ผ่าน Medical)
function FX.applyDerived(src, st)
  -- ส่ง event ให้ระบบอื่น (HUD/Movement/Medical) ใช้
  TriggerClientEvent('needs:derived', src, {
    stamina_mult = (st.stamina >= 60 and 1.0) or (st.stamina >= 30 and 0.9) or 0.8,
    stress_level = st.stress
  })
end

return FX