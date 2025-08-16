# Vehicle System

- ระบบ “ยานพาหนะมีชีวิต”: เชื้อเพลิง, ความร้อน, แบตเตอรี่, สภาพชิ้นส่วน (engine/tires/brakes/transmission/battery/filter/suspension)
- สึกหรอตามพื้นผิว/ความชัน/สภาพอากาศ/สไตล์การขับ + เหตุการณ์ชน/ลุยน้ำ
- ซ่อม/บำรุงแบบ procedure (quick / standard / overhaul) ใช้อะไหล่/คิท + เวิร์กช็อป/ลิฟต์
- ช่วยเหลือ: tow/winch แบบเบา, jump-start, drain/refill ของเหลว
- เชื่อม **Skill (mechanic/driver)** → โบนัสเวลา/คุณภาพ/โอกาสพลาด
- ประสิทธิภาพ: อัปเดตเฉพาะ “รถที่มีผู้ขับ/ใกล้ผู้เล่น”, event-driven + batch/delta

## Server API
- `VehAPI.inspect(src)` → รายงานสภาพรถที่ขับอยู่ (ตาราง)
- `VehAPI.repair(src, part, level)` → quick/standard/overhaul
- `VehAPI.service(src, action, args)` → drain/refill, jumpstart ฯลฯ
- `VehAPI.getStateByNet(netId)` / `VehAPI.getStateByPlate(plate)`

## Events (compat)
- ใช้ใหม่: `vehicleSystem:*`
- เดิมยังใช้ได้ (ถูก map): `vehicle:*` / `mechanic:*` → ดู `server/events.lua`