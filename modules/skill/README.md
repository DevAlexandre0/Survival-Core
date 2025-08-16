# Skill Progression (M19)

- ทักษะเป็นกุญแจเบา ๆ ให้โบนัสเล็กน้อย (5–15%) ไม่โกง ไม่ทำให้ PVP/เศรษฐกิจพัง
- คำนวณแบบ **event-driven**: ได้ XP จาก "การใช้งานจริง" เท่านั้น (ไม่มีการปั๊มจาก AFK)
- **Rank Bands**: novice → adept → expert → master (0..3) บนสเกล XP โค้งนุ่ม
- **Diminishing Returns** รายวัน: ทำซ้ำ ๆ จะได้ XP น้อยลง (รีเซ็ตเป็นช่วง)
- **Anti-exploit**: rate-limit, source tokens, server-authoritative
- Persistence: เก็บในหน่วยความจำ (พร้อมจุด hook ไป Core/DB ถ้าคุณเปิด persistence)

## ทักษะเริ่มต้น
`mechanic, driver, survival, cooking, foraging, medicine, fishing, athletics, marksman (สงวนไว้)`

## API (server)
- `SkillAPI.addXP(src, key, amount, cause?)`
- `SkillAPI.get(src, key) -> { xp, rank }`
- `SkillAPI.getRank(src, key) -> 0..3`
- `SkillAPI.getAll(src) -> table<key,{xp,rank}>`

## Events
- `skill:changed` (server→client) payload: `{ key, xp, rank }`
- `skill:snapshot` (server→client on join)