RegisterNetEvent('worldengine:resources:result', function(items)
  if type(items) ~= 'table' then return end
  local lines = {}
  for _,it in ipairs(items) do table.insert(lines, ('+ %sx %s'):format(it.count, it.item)) end
  lib.notify({ title='Loot', description=table.concat(lines, '\n'), type='success' })
end)