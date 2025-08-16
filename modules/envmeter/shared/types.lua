---@class EnvState
---@field temp number        -- 0..100
---@field wet number         -- 0..100
---@field speed number       -- m/s
---@field slope number       -- deg
---@field mat string         -- material name/hash string
---@field flags number       -- bitmask: rain=1, water=2, indoors=4, shelter=8
---@field motion number      -- bitmask: walk=1, run=2, sprint=4, swim=8, crouch=16, prone=32

EnvBands = {
  temp = { cold=0, cool=1, comfort=2, warm=3, hot=4 },
  wet  = { dry=0, damp=1, wet=2, soaked=3 },
}