CreateThread(function()
  if not STATUS_CFG.enabled then return end
  print('[StatusBridge] started')

  -- ensure defaults (สำหรับ provider ที่ไม่มีคีย์บางตัว)
  for _,src in ipairs(GetPlayers()) do
    for _,k in ipairs(STATUS_CFG.keys) do
      if StatusAPI.get(src, k) == nil then
        StatusAPI.set(src, k, STATUS_CFG.defaults[k] or 0, 'init')
      end
    end
  end
end)