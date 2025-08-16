local tempBand, wetBand = -1, -1

local function band_temp(v)
  local t = ENV_CFG.temp_model
  if v < t.cold_th then return 0 end
  if v < t.comfort then return 1 end
  if v < t.heat_th then return 2 end
  if v < 90 then return 3 end
  return 4
end

local function band_wet(v)
  if v < 10 then return 0 end
  if v < 35 then return 1 end
  if v < 75 then return 2 end
  return 3
end

local M = {}

function M.computeBands(temp, wet)
  local tb = band_temp(temp)
  local wb = band_wet(wet)
  local changed = (tb ~= tempBand) or (wb ~= wetBand)
  tempBand, wetBand = tb, wb
  return tb, wb, changed
end

function M.getBands()
  return tempBand, wetBand
end

return M