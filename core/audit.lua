local A = {}
A.level = 'info'
local function out(tag,msg,data)
  if A.level=='off' then return end
  print(('[AUDIT][%s] %s %s'):format(tag,msg,data and json.encode(data) or ''))
end
function A.note(tag, src, msg, data) out(tag or 'NOTE', ('src:%s %s'):format(src, msg or ''), data) end
AddEventHandler('core:audit:toggle', function()
  A.level = (A.level=='info' and 'detail') or (A.level=='detail' and 'off') or 'info'
  print('[AUDIT] level ->', A.level)
end)
return A
