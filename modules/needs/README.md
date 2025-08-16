# Needs

โมดูลจัดการความต้องการพื้นฐานของผู้เล่น:
- `hunger`, `thirst`, `sleep`, `stamina`, `stress`, `lung_capacity`
- ทำงานแบบ **server-authoritative** + อัปเดตแบบเบา (adaptive tick + by-band)
- เชื่อม `Status Bridge (M01)` ถ้ามี, ไม่มีก็เก็บสถานะเอง
- รับอินพุตจาก `EnvMeter` (อุณหภูมิ/ความเปียก/กิจกรรม) และ `WorldEngine` (shelter/heat/water)

## ฟีเจอร์ย่อ
- Drain/regen ตามกิจกรรมและสภาพแวดล้อม (cold/heat, wetness, sprint/swim)
- Sleep/Circadian: ง่วงตามเวลา + recovery เมื่อหลับ (optional)
- Stamina: ใช้ตามกิจกรรม, regen ช้าลงเมื่อหิว/กระหาย/เครียด
- Stress: เพิ่มจากหนาว/ร้อน/บาดเจ็บ/เหตุการณ์, ลดเมื่ออุ่น/กินอิ่ม/อยู่เป็นกลุ่ม (hook ได้)
- Lung Capacity: ลดขณะดำน้ำ/สูงชัน, ฟื้นบนบก; ผูก Medical/World ได้

## API (server)
- `NeedsAPI.getAll(src)` → table
- `NeedsAPI.set(src, key, value, cause?)`
- `NeedsAPI.add(src, key, delta, cause?)`
- `NeedsAPI.consume(src, itemMeta)` → ใช้เมื่อกิน/ดื่ม (เชื่อม Food/Water)

## Events
- `needs:changed` (server→client, throttled)
- `needs:snapshot` (server→client, on join)