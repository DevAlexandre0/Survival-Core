RegisterNetEvent('core:registry:update', function(reg)
  local options = {}
  for name, info in pairs(reg.modules or {}) do
    local title = ('[%s] %s'):format(info.enabled and 'ON' or 'OFF', name)
    options[#options+1] = {
      title = title,
      description = (info.meta and (info.meta.desc or '')) or '',
      onSelect = function()
        lib.notify({ title='SurvivalCore', description='Module: '..name, type='inform' })
      end
    }
  end
  options[#options+1] = { title='Toggle Audit Level', onSelect=function() TriggerServerEvent('core:audit:toggle') end }
  lib.registerContext({ id='sc_dev_panel', title='SurvivalCore Dev ('..((SC_CFG and SC_CFG.version) or 'v2')..')', options=options })
  lib.showContext('sc_dev_panel')
end)

RegisterCommand('sc_dev', function()
  TriggerServerEvent('core:registry:request')
end)
