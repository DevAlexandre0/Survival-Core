# WorldEngine (World Hooks + Looting)

- จัดการ **Zones**: shelter/heat/water/danger และ dynamic props ที่กลายเป็นโซน
- จัดการ **Resources**: nodes (mining/wood/forage/fishing/salvage) และ containers/scavenge
- ออกแบบ **เบา**: สแกนปรับตามกิจกรรม, event-based enter/leave, batch updates
- ปลอดภัย: server-authoritative drop tables, tokens, LOS/distance checks, rate-limit

## อีเวนต์สำคัญ
- `worldengine:zone:enter/leave` (server→client)
- `worldengine:flags` (server→client) – สรุป flag ให้โมดูลอื่น (EnvMeter/Needs/ฯลฯ)
- `worldengine:resources:result` (server→client) – ผลการเก็บ/เปิดกล่อง

## API (server)
- `WorldAPI.getZoneAt(vec3)` → zone info
- `WorldAPI.getNearbyNodes(src, radius, type?)` → nodes list
- `WorldAPI.claimContainer(src, id)` → lock + token
- `WorldAPI.forceRescan()` / `WorldAPI.forceRespawn(type?)`

ติดตั้ง: วางโฟลเดอร์ `worldengine` ใน `survival_core/modules/` และ start หลัง Core