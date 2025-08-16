local R = {}

local function hasItem(src, name, count)
  if GetResourceState('ox_inventory') ~= 'started' then return true end -- fallback: ไม่บล็อก
  return (exports.ox_inventory:Search(src,'count',name) or 0) >= (count or 1)
end
local function takeItem(src, name, count)
  if GetResourceState('ox_inventory') ~= 'started' then return true end
  return exports.ox_inventory:RemoveItem(src, name, count or 1)
end

local function skillBonus(src)
  if not VEH_CFG.integration.skill or GetResourceState('skill') ~= 'started' then return 0 end
  local rank = exports.skill and exports.skill:getRank and (exports.skill:getRank(src,'mechanic') or 0) or 0
  -- สมมติ rank 0..3 คืน 0..0.15
  return math.min(0.15, 0.05*rank)
end

local function inWorkshopZone(src)
  -- ตรงนี้ให้ WorldEngine ส่ง flag/zone มา (ยกเว้นไม่มี world)
  return true
end

function R.repair(src, st, part, level)
  local proc = VEH_CFG.repair.procedures[level or 'standard'] and (level or 'standard') or 'standard'
  if not st or not st.parts[part] then return false,'invalid_part' end

  -- ค่าเวลา/การใช้ของ
  local time = VEH_CFG.repair.procedures[proc]
  local tool = VEH_CFG.repair.kits[proc]
  if not hasItem(src, tool, 1) then return false,'need_kit' end

  local ws = inWorkshopZone(src)
  if ws then time = time * VEH_CFG.repair.workshop_bonus else time = time * VEH_CFG.repair.roadside_penalty end
  time = time * (1.0 - skillBonus(src))  -- ลดเวลาตามสกิล

  -- อะไหล่ (overhaul ต้องใช้ part เดิม)
  local partItem = VEH_CFG.repair.parts[part]
  if proc ~= 'quick' and not hasItem(src, partItem, 1) then return false,'need_part' end

  -- ล็อคยานพาหนะสั้น ๆ ระหว่างทำ
  st.locked = VEH_CFG.security.lock_during_procedure

  -- ตัดของ
  takeItem(src, tool, 1)
  if proc ~= 'quick' then takeItem(src, partItem, 1) end

  -- “ทำงาน” (ไม่หน่วงจริง — ให้ client แสดง progress เอง)
  local delta = (proc=='quick' and 8) or (proc=='standard' and 22) or 45
  st.parts[part] = math.min(100, st.parts[part] + delta)

  -- ปลดล็อค
  st.locked = false
  return true, { part=part, level=proc, time=time, new=st.parts[part] }
end

function R.service(src, st, action, args)
  if action == 'drain_oil' then
    st.fluids.oil = math.max(0, st.fluids.oil - 40)
    return true, { oil=st.fluids.oil }
  elseif action == 'refill_oil' then
    local ok = hasItem(src,'oil_can',1) and takeItem(src,'oil_can',1)
    if not ok then return false,'need_oil' end
    st.fluids.oil = math.min(100, st.fluids.oil + 60)
    return true, { oil=st.fluids.oil }
  elseif action == 'jump_start' then
    st.parts.battery = math.max(st.parts.battery, 30)
    return true, { battery=st.parts.battery }
  elseif action == 'refuel' then
    local liters = math.min(args and args.liters or 10.0, 40.0)
    st.fluids.fuel = math.min(VEH_CFG.fuel.tank_capacity, st.fluids.fuel + liters)
    return true, { fuel=st.fluids.fuel }
  end
  return false,'invalid_service'
end

return R