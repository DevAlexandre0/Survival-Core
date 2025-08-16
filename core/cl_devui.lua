local cfg = require('config/core.lua')
if not lib then return end

-- Dev UI command
if cfg.dev_ui and cfg.dev_ui.enabled then
  RegisterCommand(cfg.dev_ui.command or 'svcore', function()
    local ov = lib.callback.await('svcore:getOverview', false)
    lib.print.info('Survival Core – Overview:', json.encode(ov or {}))
    lib.notify({ title='Survival Core', description='Dev UI opened (console overview).', type='inform' })
  end)
end

-- Fallback inventory context/menu (only shows if provider != ox_inventory)
local provider = (cfg.inventory and cfg.inventory.provider) or 'auto'
if provider ~= 'ox_inventory' and (cfg.inventory and cfg.inventory.fallback and cfg.inventory.fallback.ui.enabled) then
  local cmd = cfg.inventory.fallback.ui.command or 'inv'
  RegisterCommand(cmd, function()
    -- This is a lightweight placeholder context
    lib.registerContext({
      id = 'svv_inv',
      title = 'Inventory (Fallback)',
      options = {
        { title='Refresh', event='svv:inv:refresh' },
        { title='Close' }
      }
    })
    lib.showContext('svv_inv')
  end)
end