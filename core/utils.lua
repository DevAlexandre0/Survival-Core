local M = {}

function M.clamp(v, a, b) return math.max(a, math.min(b, v)) end
function M.isTable(x) return type(x) == 'table' end

function M.safeJsonEncode(t)
  local ok, out = pcall(json.encode, t); if ok then return out end
  return '{}'
end

function M.safeJsonDecode(s)
  if type(s) ~= 'string' then return {} end
  local ok, out = pcall(json.decode, s); if ok and out then return out end
  return {}
end

-- simple token bucket per key
local buckets = {}
function M.rateLimit(key, rate, window)
  local now = GetGameTimer()
  local b = buckets[key]
  if not b or now - b.windowStart > (window * 1000) then
    b = { count = 0, windowStart = now }
  end
  if b.count >= rate then buckets[key] = b; return false end
  b.count = b.count + 1
  buckets[key] = b
  return true
end

function M.loglvl() return (require('config/core.lua').debug or {}).logging or 'info' end
function M.log(level, ...)
  local target = M.loglvl()
  local order = { off=0, error=1, warn=2, info=3, debug=4 }
  if (order[level] or 0) <= (order[target] or 0) then
    print(('[SurvivalCore][%s] %s'):format(level:upper(), table.concat({...}, ' ')))
  end
end

return M