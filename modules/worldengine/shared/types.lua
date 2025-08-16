---@class Zone
---@field id string
---@field type 'shelter'|'heat'|'water'|'danger'
---@field center vector3
---@field range number
---@field meta table

---@class Node
---@field id string
---@field type 'mining'|'woodcut'|'forage'|'fishing'|'salvage'
---@field pos vector3
---@field ready boolean
---@field respawnAt number -- os.time()

---@class Container
---@field id string
---@field class string
---@field pos vector3
---@field lockedUntil number

WorldFlags = {
  SHELTER = 1, HEAT = 2, WATER = 4, DANGER = 8
}