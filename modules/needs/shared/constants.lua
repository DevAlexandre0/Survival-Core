NeedsKeys = {
  hunger='hunger', thirst='thirst', sleep='sleep',
  stamina='stamina', stress='stress', lung='lung_capacity'
}

-- motion bits (ต้องตรงกับ EnvMeter)
MOT = { WALK=1, RUN=2, SPRINT=4, SWIM=8, CROUCH=16, PRONE=32 }

-- สำหรับ Env bands (ดูจาก EnvMeter)
EnvBandTemp = { cold=0, cool=1, comfort=2, warm=3, hot=4 }
EnvBandWet  = { dry=0, damp=1, wet=2, soaked=3 }