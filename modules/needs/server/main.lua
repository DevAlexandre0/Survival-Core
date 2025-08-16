local Co = require 'core/coalesce'
CreateThread(function()
  if not NEEDS_CFG.enabled then return end
  print('[Needs] server started (persist + coalesced)')
  local shard, SHARDS = 0, 4
  while true do
    local waitNext = NEEDS_CFG.replication.interval_ms or 1400
    for _,src in ipairs(GetPlayers()) do
      if (tonumber(src) or 0) % SHARDS == shard then
        local st = NeedsAPI.getAll(src)
        if st then
          st.hunger = math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, st.hunger + NEEDS_CFG.rate.hunger_base))
          st.thirst = math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, st.thirst + NEEDS_CFG.rate.thirst_base))
          st.sleep  = math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, st.sleep  + NEEDS_CFG.rate.sleep_base))
          st.stamina= math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, st.stamina+ NEEDS_CFG.rate.stamina_regen))
          st.stress = math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, st.stress + NEEDS_CFG.rate.stress_decay))
          st.lung_capacity = math.max(NEEDS_CFG.min, math.min(NEEDS_CFG.max, st.lung_capacity + NEEDS_CFG.rate.lung_regen))
          Co.push(src, 'needs', { hunger=st.hunger, thirst=st.thirst, sleep=st.sleep, stamina=st.stamina, stress=st.stress, lung=st.lung_capacity })
        end
      end
    end
    shard = (shard + 1) % SHARDS
    Wait(waitNext)
  end
end)
