fx_version 'cerulean'
game 'gta5'
name 'SurvivalCore (Full Upgrade • PROD)'
description 'Core + modules monolithic autoload, persistence, sharded ticking, coalesced network'
author 'YourName'
version 'v2-full-upgrade-prod'
lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'core/config.lua',
  'modules/**/shared/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'core/mod_api.lua',
  'core/db.lua',
  'core/guard.lua',
  'core/audit.lua',
  'core/coalesce.lua',
  'core/save.lua',
  'modules/_init.lua',
  'modules/**/server/*.lua',
}

client_scripts {
  'core/mod_client.lua',
  'core/devpanel.lua',
  'core/client_coalesced.lua',
  'modules/**/client/*.lua'
}

server_exports { 'sc_call', 'sc_modules', 'sc_version' }
dependencies { 'ox_lib', 'oxmysql' }
