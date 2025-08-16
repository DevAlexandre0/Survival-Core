local DB = {}
local ox = exports.oxmysql
local SCHEMA_VERSION = 1

function DB.migrate()
  ox:executeSync([[
    CREATE TABLE IF NOT EXISTS sc_kv (
      k VARCHAR(64) PRIMARY KEY,
      v LONGTEXT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );
  ]], {})
  -- Module tables
  ox:executeSync([[CREATE TABLE IF NOT EXISTS sc_players_needs (
    identifier VARCHAR(64) PRIMARY KEY,
    hunger INT NOT NULL, thirst INT NOT NULL, sleep INT NOT NULL,
    stamina INT NOT NULL, stress INT NOT NULL, lung INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    schema_version INT NOT NULL DEFAULT 1
  );]], {})
  ox:executeSync([[CREATE TABLE IF NOT EXISTS sc_medical (
    identifier VARCHAR(64) PRIMARY KEY,
    blood_type VARCHAR(4) NOT NULL,
    blood_volume INT NOT NULL,
    wounds_json LONGTEXT NOT NULL,
    sick_json LONGTEXT NOT NULL,
    fx_json LONGTEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    schema_version INT NOT NULL DEFAULT 1
  );]], {})
  ox:executeSync([[CREATE TABLE IF NOT EXISTS sc_skill (
    identifier VARCHAR(64) NOT NULL,
    k VARCHAR(32) NOT NULL,
    xp INT NOT NULL,
    rank INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    schema_version INT NOT NULL DEFAULT 1,
    PRIMARY KEY(identifier, k)
  );]], {})
  ox:executeSync([[CREATE TABLE IF NOT EXISTS sc_vehicle (
    id VARCHAR(80) PRIMARY KEY,
    plate VARCHAR(16),
    model VARCHAR(32),
    parts_json LONGTEXT NOT NULL,
    heat FLOAT NOT NULL,
    fuel FLOAT NOT NULL,
    oil INT NOT NULL,
    coolant INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    schema_version INT NOT NULL DEFAULT 1
  );]], {})
  print('[SC/DB] core + module migration complete')
end

function DB.save(tableName, data, builderWrap)
  local q, params = builderWrap.builder(tableName, data)
  return exports.oxmysql:executeSync(q, params)
end

function DB.fetch(query, params)
  return exports.oxmysql:executeSync(query, params or {})
end

return DB
