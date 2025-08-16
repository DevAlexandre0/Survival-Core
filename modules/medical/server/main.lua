local P = require 'server/pipeline'
local Co = require 'core/coalesce'

CreateThread(function()
    if not MED_CFG.enabled then
        return
    end

    print('[Medical] server started (persist + coalesced)')

    local shard, SHARDS = 0, 4

    while true do
        local interval = MED_CFG.tick.idle_ms

        for _, src in ipairs(GetPlayers()) do
            if (tonumber(src) or 0) % SHARDS == shard then
                local st = exports['survival_core'] and
                    exports['survival_core'].sc_call and
                    ({ exports['survival_core']:sc_call('medical', 'getState', src) })[2] or
                    nil

                if not st then
                    st = require('server/api').MedAPI.getState(src)
                end

                local before = st.blood.volume

                P.step(src, st)

                if math.abs(st.blood.volume - before) >= 1.0 then
                    Co.push(src, 'medical', { blood = st.blood })
                    interval = MED_CFG.tick.event_ms
                end
            end
        end

        shard = (shard + 1) % SHARDS
        Wait(interval)
    end
end)
