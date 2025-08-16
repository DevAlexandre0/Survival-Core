# Modules Guide (Clean Layout)
Load order is deterministic via `modules/_init.lua`:
1) status_bridge
2) needs
3) nutrition
4) medical
5) skill
6) vehicle_system
7) weather

Each module has:
- `shared/config.lua` (configs only)
- `server/*.lua` (server logic)
- `client/*.lua` (client logic)
- `init.lua` registers module with Core

Admin command:
- `/sc_health` (ACE `sc.dev`) prints module registry snapshot to server console.
