# Weather (M07)

- โหมดทำงาน:
  - **own**: เซิร์ฟเวอร์ควบคุมเต็มรูปแบบตาม scheduler/profiles
  - **follow**: ตามสคริปต์อากาศภายนอก (อ่านค่าแล้วกระจายเฉย ๆ)
  - **locked**: ล็อกสภาพอากาศคงที่ (ดีสำหรับอีเวนต์)
- ซิงก์ทั้งเซิร์ฟเวอร์/บัคเก็ต, ทรานซิชันนุ่ม (fade), และ broadcast "ambient" ให้ EnvMeter

## Ambient payload (server→client)
```lua
{ tempC=26.0, wind=2.0, precip=0.0, humidity=0.55, cloud=0.2, weather='CLEAR' }