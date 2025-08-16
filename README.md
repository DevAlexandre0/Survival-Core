# Survival Core

Lightweight hub/state/persistence core for FiveM. oxmysql-first, adapters for ESX/QB/ox_core/standalone, with ultralight fallback inventory (optional) and ox_lib context UI.

## Requirements
- `@oxmysql` (required)
- `@ox_lib` (optional, for Dev UI and fallback inventory UI)
- Optional: `ox_inventory`, `ox_target`

## Install
1. Put `survival_core/` into `resources/`.
2. Ensure `@oxmysql/lib/MySQL.lua` is available.
3. Add `ensure survival_core` to your server cfg.
4. Start server. Check logs: adapter used + `storage ready (tables ensured)`.

## Config (config/core.lua)
- `strict_framework`: false | 'esx' | 'qb' | 'ox' | 'standalone'
- `persistence`: 'oxmysql'
- `perf`: tick/batch settings
- `replication`: allowlist + budget
- `security`: schema, payload limits
- `ratelimit`: telemetry/ui/inventory
- `recovery`: flush/watchdog/breaker
- `inventory`: provider + fallback UI (ox_lib context)
- `dev_ui`: enabled/command/permission
- `profiles`: dev/staging/prod presets

## API / Events
- `exports['survival_core']:getState(source) -> table`
- `exports['survival_core']:setState(source, key, value)`
- Events:
  - `svcore:playerLoaded(source, state)`
  - `svcore:playerUnloaded(source)`
  - `svcore:stateChanged(source, key, old, new)`
  - `svcore:tick`

## Admin commands (console)
- `core:metrics`
- `core:flushall`
- `core:profile <dev|staging|prod>`
- `core:reload-config`

## Notes
- No money system in core.
- Auto-create DB tables (non-destructive).
- Fallback inventory is count-based server-side; ox_lib used only for lightweight context UI.