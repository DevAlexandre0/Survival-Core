local name = 'weather'
Core.RegisterModule(name, {
  enabled = (SC_CFG.modules[name] ~= false),
  meta = { version = '1.0.0', author = 'Upgrader', desc = 'weather module' },
  __start = function() print('[Module]', name, 'started') end,
  __stop  = function() print('[Module]', name, 'stopped') end,
  exports = { }
})
