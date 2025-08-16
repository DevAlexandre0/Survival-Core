local name = 'status_bridge'
Core.RegisterModule(name, {
  enabled = (SC_CFG.modules[name] ~= false),
  meta = { version = '1.1.0', author = 'Upgrader', desc = 'Framework status normalization (ESX/ox stack)' },
  __start = function() if server and server.start then server.start() end end,
  __stop  = function() if server and server.stop  then server.stop()  end end,
  exports = { }
})
