local DB = require 'core/db'
local states = {}

local function ensureState(id, model)
  if not states[id] then
    local rows = DB.fetch('SELECT plate,model,parts_json,heat,fuel,oil,coolant FROM sc_vehicle WHERE id=?', { id })
    if rows and rows[1] then
      local r = rows[1]
      local parts = (r.parts_json and json.decode(r.parts_json)) or { engine=90, tires=90, brakes=90, transmission=90, battery=90, filter=90, suspension=90 }
      states[id] = { id=id, plate=r.plate, model=r.model, parts=parts, heat=tonumber(r.heat) or 70.0, fluids={ fuel=tonumber(r.fuel) or 0, oil=tonumber(r.oil) or 100, coolant=tonumber(r.coolant) or 100 }, lastKm=0.0, locked=false }
    else
      local Parts = require 'server/parts'
      states[id] = Parts.newState(id, model)
    end
  end
  return states[id]
end

VehAPI = {}
function VehAPI.get(id) return states[id] end
function VehAPI.touch(id, model) return ensureState(id, model) end
function VehAPI.setPart(id, part, val) local st=ensureState(id); st.parts[part]=math.max(0, math.min(100, math.floor(val or 0))); return true, st.parts[part] end

exports('get', VehAPI.get); exports('touch', VehAPI.touch); exports('setPart', VehAPI.setPart)

AddEventHandler('core:flush:all', function()
  for id,st in pairs(states) do
    DB.save('sc_vehicle', {
      id=id, plate=st.plate or nil, model=st.model,
      parts_json=json.encode(st.parts), heat=st.heat,
      fuel=st.fluids.fuel, oil=st.fluids.oil, coolant=st.fluids.coolant, schema_version=1
    }, {
      builder=function(tbl,d)
        return ([=[
          INSERT INTO sc_vehicle(id,plate,model,parts_json,heat,fuel,oil,coolant,schema_version)
          VALUES(?,?,?,?,?,?,?,?,?)
          ON DUPLICATE KEY UPDATE plate=VALUES(plate), model=VALUES(model), parts_json=VALUES(parts_json),
            heat=VALUES(heat), fuel=VALUES(fuel), oil=VALUES(oil), coolant=VALUES(coolant),
            schema_version=VALUES(schema_version)
        ]=]), {d.id,d.plate,d.model,d.parts_json,d.heat,d.fuel,d.oil,d.coolant,d.schema_version}
      end
    })
  end
end)
