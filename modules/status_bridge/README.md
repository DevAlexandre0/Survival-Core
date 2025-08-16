# Status Bridge

- ตรวจจับเฟรมเวิร์กอัตโนมัติ (ESX/QBCore/ox_core) หรือทำงานแบบ standalone
- แมปคีย์สถานะให้เป็นมาตรฐาน `status.*` เช่น hunger/thirst/sleep/stamina/stress/lung_capacity
- ปลอดภัย: validate ชนิดข้อมูล/ขอบเขต, rate-limit เขียน, deny-by-default
- เชื่อมกับ Status Engine ของ Core (ถ้าเปิด) โดยการส่งอีเวนต์/exports กลาง

## State Keys (normalized)
- `status.hunger`        (0..100, 100 = อิ่ม)
- `status.thirst`        (0..100)
- `status.sleep`         (0..100)
- `status.stamina`       (0..100)
- `status.stress`        (0..100)
- `status.lung_capacity` (0..100)

> ปรับแมปได้ใน `shared/map.lua` และเปิด/ปิดคีย์ใน `shared/config.lua`.

## Server API
- `StatusAPI.get(src, key) -> number|nil`
- `StatusAPI.set(src, key, value, cause?) -> boolean`
- `StatusAPI.bulkSet(src, tbl, cause?)`
- `StatusAPI.getAll(src) -> table`

## Events
- `status:changed` (server→client) payload: `{ key=..., value=..., cause='bridge|module' }`
- `status:requestSnapshot` (client→server) → ส่งสถานะล่าสุดกลับไป
