# Medical System

- อาการหลัก: wounds (cut/bruise/fracture/burn), bleeding, infection, sickness (flu/food/water), pain, shock
- เลือด: `blood.volume` (0..100), `blood.type` (A/B/AB/O; +/−) ใช้ใน transfusion ได้
- การรักษา: bandage, hemostat, suture, splint, disinfect, painkiller, antibiotics, IV/Saline/Blood
- เชื่อม Needs/EnvMeter/WorldEngine: หนาว/เปียก/โคลนเพิ่มโอกาสติดเชื้อ, อด/กระหายทำแผลช้า
- ออกแบบเบา: event-driven + stage tick เป็น batch, by-stage replication

## Server API
- `MedAPI.getState(src)` → table (read-only copy)
- `MedAPI.applyInjury(src, kind, severity, cause?)`
- `MedAPI.treat(src, action, args)`  -- ทำหัตถการรักษา
- `MedAPI.setBloodType(src, type)` / `MedAPI.getBloodType(src)`
- `MedAPI.addEffect(src, key, seconds)` -- บัฟ/ดีบัฟชั่วคราว (painkiller, fever, etc.)

## Events
- `medical:snapshot` (server→client on join)
- `medical:changed`  (server→client throttled by stage)
- `medical:notify`   (server→client short text)