local Util = require('core/utils.lua')
local Storage = {}

-- compat helpers
local DB = {}
DB.single = function(q, p) if MySQL and MySQL.single then return MySQL.single.await(q, p) else return exports.oxmysql:single(q, p) end end
DB.query  = function(q, p) if MySQL and MySQL.query  then return MySQL.query.await(q, p)  else return exports.oxmysql:query(q, p)  end end
DB.update = function(q, p) if MySQL and MySQL.update then return MySQL.update.await(q, p) else return exports.oxmysql:update(q, p) end end
DB.execute= function(q, p) if MySQL and MySQL.query  then return MySQL.query.await(q, p)  else return exports.oxmysql:execute(q, p) end end

-- ensure tables
CreateThread(function()
  DB.execute([[
    CREATE TABLE IF NOT EXISTS survival_players (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      identifier VARCHAR(64) NOT NULL,
      last_name VARCHAR(64) NULL,
      schema_version INT NOT NULL DEFAULT 1,
      data JSON NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY ux_survival_identifier (identifier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]], {})

  DB.execute([[
    CREATE TABLE IF NOT EXISTS survival_inventories (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      identifier VARCHAR(64) NOT NULL,
      items JSON NOT NULL,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY ux_survival_inv_identifier (identifier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]], {})

  Util.log('info', 'oxmysql storage ready (tables ensured)')
end)

function Storage.loadPlayer(identifier)
  local row = DB.single('SELECT data, schema_version FROM survival_players WHERE identifier = ?', { identifier })
  if not row then return {} end
  local data = (type(row.data) == 'string') and Util.safeJsonDecode(row.data) or (row.data or {})
  data._schema = row.schema_version or 1
  return data
end

function Storage.savePlayer(identifier, state)
  local blob = Util.safeJsonEncode(state or {})
  DB.update([[
    INSERT INTO survival_players (identifier, data, schema_version)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE
      data = VALUES(data),
      schema_version = VALUES(schema_version),
      updated_at = CURRENT_TIMESTAMP
  ]], { identifier, blob, (state and state._schema) or 1 })

  -- save fallback inventory if exists
  if state and state.inv then
    local items = Util.safeJsonEncode(state.inv)
    DB.update([[
      INSERT INTO survival_inventories (identifier, items)
      VALUES (?, ?)
      ON DUPLICATE KEY UPDATE
        items = VALUES(items),
        updated_at = CURRENT_TIMESTAMP
    ]], { identifier, items })
  end
end

return Storage