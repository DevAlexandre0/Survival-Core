local M = {}
local buckets = {}
local INTERVAL = 900
function M.push(src, evt, payload)
  local b = buckets[src] or {}
  b[#b+1] = { e=evt, p=payload }
  buckets[src] = b
end
CreateThread(function()
  while true do
    Wait(INTERVAL)
    for _,src in ipairs(GetPlayers()) do
      local b = buckets[src]
      if b and #b>0 then
        TriggerClientEvent('core:coalesced', src, b)
        buckets[src] = {}
      end
    end
  end
end)
return M
