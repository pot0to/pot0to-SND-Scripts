--[=====[
[[SND Metadata]]
author: pot0to
version: 2.0.0
description: |
  Support via https://ko-fi.com/pot0to
  Bokairo Inn jump puzzle and sightseeing log: https://www.youtube.com/watch?v=Wl_3FUdCo-o
plugin_dependencies:
- vnavmesh
configs:
  Starting Jump Number:
    description: Start with step 1, but if you fall due to server tick issues,
        you can use this to restart the jump puzzle from any step. See the
        "Jump Points" list 
    default: 1
[[End Metadata]]
--]=====]

-- wait=0       for a standing jump
-- wait=0.08    for a running short jump
-- wait=0.1     for a running long jump
-- no wait      for no jump
JumpPoints = {
    { x=-71.08, y=18.0, z=-163.48 },
    { x=-70.51, y=19.56, z=-163.55, wait=0 },
    { x=-68.75, y=20.67, z=-163.53, wait=0.08 },
    { x=-50.73, y=20.36, z=-164.27 },                   -- 4, edge of roof, right before stepping on rope
    { x=-50.73, y=18.84, z=-166.43 },                   -- 5, on rope
    { x=-50.72, y=18.82, z=-173.75 },                   -- 6, other end of rope
    { x=-50.73, y=20.37, z=-175.9, wait=0.08 },         -- 7, on other roof
    { x=-48.93, y=22.54, z=-178.88 },
    { x=-47.27, y=24.4, z=-180.06, wait=0.08 },
    { x=-49.88, y=24.43, z=-180.03 },                   -- 10
    { x=-51.06, y=25.18, z=-180.01 },
    { x=-61.88, y=31.76, z=-179.93 },
    { x=-62.9, y=32.85, z=-179.99, wait=0.08 },
    { x=-66.15, y=29.84, z=-184.13 },
    { x=-70.91, y=29.79, z=-184.0, wait=0.1 },          -- 15, long jump onto outside edge of balcony
    { x=-79.75, y=29.79, z=-184.13 },
    { x=-79.85, y=29.47, z=-180.2 },
    { x=-81.35, y=31.41, z=-179.91, wait=0 },           -- 18, jump onto sign
    { x=-86.32, y=33.2, z=-180.04 },
    { x=-90.8, y=31.41, z=-179.86 },                    -- 20
    { x=-92.22, y=29.47, z=-180.28 },                   -- 21, drop down off other edge of sign
    { x=-92.2, y=29.79, z=-184.14 },
    { x=-92.34, y=29.79, z=-186.24, wait=0.08 },        --23, jump onto balcony
    { x=-98.73, y=29.79, z=-186.06 },
    { x=-103.13, y=30.7, z=-186.13, wait=0.08 },        -- 25, jump out onto roof
    { x=-105.47, y=35.42, z=-211.49 },
    { x=-103.32, y=35.76, z=-211.88 },
    { x=-101.19, y=37.0, z=-209.27 },
    { x=-101.01, y=38.26, z=-211.8, wait=0.08 },
    { x=-100.51, y=40.01, z=-211.58, wait=0.08 },       -- 30, onto railing
    { x=-100.56, y=40.01, z=-213.45 },                  -- 31, onto balcony
    { x=-72.41, y=38.26, z=-213.77 },
    { x=-71.68, y=40.01, z=-213.41, wait=0 },           -- 33, onto railing
    { x=-71.41, y=40.01, z=-212.62 },
    { x=-71.47, y=40.01, z=-185.29 },
    { x=-81.17, y=39.96, z=-185.46 },
    { x=-81.07, y=41.7, z=-181.94, wait=0.1 },
    { x=-81.05, y=43.5, z=-184.65, wait=0.08 },
    { x=-81.25, y=43.5, z=-184.66 },
    { x=-75.84, y=43.6, z=-184.49, wait=0.2 },
    { x=-72.41, y=45.31, z=-184.6, wait=0.1 },          -- 40
    { x=-72.48, y=46.82, z=-185.38, wait=0.08 },        -- 41, on roof
    { x=-85.15, y=52.28, z=-191.26 },
    { x=-86.25, y=53.35, z=-193.51, wait=0.08 },
}

import ("System")
import("System.Numerics")
GenericListType = Type.GetType("System.Collections.Generic.List`1[System.Numerics.Vector3]")

function Jump()
    local jumpData = JumpPoints[JumpNumber]
    if jumpData.sprint then
        yield("/generalaction sprint")
        yield("/wait 1")
    end

    local vectorList = Activator.CreateInstance(GenericListType)
    vectorList:Add(Vector3(jumpData.x, jumpData.y, jumpData.z))
    IPC.vnavmesh.MoveTo(vectorList, false)
    if jumpData.wait ~=nil then
        yield("/wait "..jumpData.wait)
        yield("/gaction jump")
    end
    repeat
        yield("/wait 0.1")
    until not IPC.vnavmesh.IsRunning()
    yield("/wait 0.5")
    JumpNumber = JumpNumber + 1
end

JumpNumber = Config.Get("Starting Jump Number")
while JumpNumber <= #JumpPoints do
    Jump()
end