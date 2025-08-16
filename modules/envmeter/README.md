# EnvMeter (Telemetry + Exposure)

- รวมข้อมูลสภาพแวดล้อมและการเคลื่อนไหวของผู้เล่นไว้ในโมดูลเดียว
- สร้างค่า `env.*` กลาง: temperature (0–100), wetness (0–100), motion, terrain, flags
- ออกแบบให้เบา: dynamic tick, by-band replication, event-driven boost
- รับค่า ambient จาก Weather module (ถ้ามี) หรือ native fallback หากไม่มี

## คีย์ State ที่เผยแพร่
- env.temperature     (0–100)
- env.wetness         (0–100)
- env.motion.speed    (m/s)
- env.motion.flags    (bitmask: walk/run/sprint/swim/crouch/prone)
- env.terrain.slope   (deg)
- env.terrain.mat     (hash/name)
- env.flags           (bitmask: in_rain/in_water/indoors/sheltered)

## อีเวนต์สำคัญ
- `envmeter:changed` (client→server throttled) – แจ้งเมื่อค่าข้าม band หรือเปลี่ยนเกิน threshold
- `envmeter:snapshot` (server→client) – ส่ง snapshot ล่าสุดให้ผู้เล่นใหม่

## ติดตั้ง
1) วางโฟลเดอร์ `envmeter` ใน `survival_core/modules/`
2) ตรวจให้แน่ใจว่ามี `ox_lib`
3) เพิ่มใน start order หลัง core และก่อนโมดูลที่พึ่งพา envmeter