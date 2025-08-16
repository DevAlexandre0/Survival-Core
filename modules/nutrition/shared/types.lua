---@class FoodMeta { kind:string, opened:boolean, doneness:number, spoil:number } -- spoil 0..100
---@class WaterMeta { quality:'clean'|'natural'|'contaminated', liters:number, container:'bottle'|'canteen'|'jerry' }

---@class ConsumeResult { hunger:number, thirst:number, stress:number, stamina:number, warmth:number, risk_food_poison:number, risk_cholera:number }