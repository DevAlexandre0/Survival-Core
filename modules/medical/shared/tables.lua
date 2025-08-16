BloodTypes = { 'O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+' }

Treatment = {
  bandage   = { needs = { item='bandage',  count=1 }, effect = function(st,w) w.bleeding=false; w.dirty=false end },
  hemostat  = { needs = { item='hemostat', count=1 }, effect = function(st,w) w.bleeding=false end },
  suture    = { needs = { item='suture',   count=1 }, effect = function(st,w) w.sev=math.max(1, w.sev-1) end },
  splint    = { needs = { item='splint',   count=1 }, effect = function(st,w) if w.kind=='fracture' then w.sev=1 end end },
  disinfect = { needs = { item='disinfect',count=1 }, effect = function(st,w) w.dirty=false end },
  painkiller= { needs = { item='painkiller',count=1 }, effect = function(st) st.fx.pain=math.max(0, st.fx.pain-25) end },
  antibiotic= { needs = { item='antibiotic',count=1 }, effect = function(st) for _,s in ipairs(st.sick) do s.until = GetGameTimer()+ 60*1000 end end },
  salineIV  = { needs = { item='saline',  count=1 }, effect = function(st) st.blood.volume = math.min(100, st.blood.volume+15) end },
  bloodIV   = { needs = { item='bloodbag',count=1 }, effect = function(st) st.blood.volume = math.min(100, st.blood.volume+30) end },
}