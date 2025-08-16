---@class Wound { kind: 'cut'|'bruise'|'fracture'|'burn', sev: 1|2|3, bleeding: boolean, dirty: boolean }
---@class Sickness { key: 'flu'|'food'|'cholera', until: number }
---@class Effects { pain:number, shock:number, fever:number, buffs:table<string,number> }

---@class MedState
---@field blood { volume:number, type:string }
---@field wounds Wound[]
---@field sick Sickness[]
---@field fx Effects