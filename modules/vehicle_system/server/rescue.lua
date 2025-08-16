local RES = {}

function RES.canTow(args)
  -- ตรวจ slope / มวล (placeholder)
  return true
end

function RES.tow(src, vehNetId, targetNetId)
  if not RES.canTow({}) then return false, 'bad_conditions' end
  -- ให้ client ทำ attach/physics (server validate แล้วจึงสั่ง)
  TriggerClientEvent('vehicleSystem:tow:attach', -1, vehNetId, targetNetId)
  return true
end

function RES.winch(src, vehNetId, anchor)
  TriggerClientEvent('vehicleSystem:winch:start', -1, vehNetId, anchor)
  return true
end

return RES