local cfg = require('config/core.lua')
local prefix = cfg.statebag_prefix or 'svv_'

-- client-side debug cmd (optional)
RegisterCommand('svv_debug', function()
  local keys = {}
  for k,v in pairs(LocalPlayer.state) do
    if type(k) == 'string' and k:sub(1,#prefix) == prefix then
      keys[#keys+1] = k
    end
  end
  print('Replicated keys:', table.concat(keys, ', '))
end)