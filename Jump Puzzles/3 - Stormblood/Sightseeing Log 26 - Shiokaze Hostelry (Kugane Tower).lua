--[=====[
[[SND Metadata]]
author: pot0to
version: 2.0.0
description: |
  Support via https://ko-fi.com/pot0to
  Kugane Tower jump puzzle and sightseeing log: https://youtu.be/paXx-tiXkh0?t=118
  (Not the palace! There's no sightseeing jump puzzle at the palace!)
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

import("System")
import("System.Numerics")
GenericListType = Type.GetType("System.Collections.Generic.List`1[System.Numerics.Vector3]")

-- wait=0       for a standing jump
-- wait=0.08    for a running short jump
-- wait=0.1     for a running long jump
-- no wait      for no jump
JumpPoints = {
    { position=Vector3(-41.07, 15.49, -37.5), wait=0.08 },  -- 1, jump on railing
    { position=Vector3(-40.89, 15.52, -35.79) },            -- 2, adjust on railing
    { position=Vector3(-39.36, 17.2, -38.42), wait=0.05 },  -- 3, jump on peg
    { position=Vector3(-39.3, 17.2, -37.9) },
    { position=Vector3(-36.97, 17.41, -39.1), wait=0.00 },
    { position=Vector3(-36.92, 17.41, -39.15) },
    { position=Vector3(-33.76, 19.21, -38.91), wait=0.08 },
    { position=Vector3(-30.42, 20.91, -38.71), wait=0.08 },
    { position=Vector3(-32.01, 22.85, -40.35), wait=0.1},    -- 9, green roof 

    { position=Vector3(-28.05, 23.63, -45.98) },
    { position=Vector3(-27.65, 24.18, -70.36) },
    { position=Vector3(-38.29, 24.09, -80.26) },
    { position=Vector3(-41.47, 25.55, -78.20) },
    { position=Vector3(-43.11, 26.60, -78.66), wait=0.08 }, -- 14, edge of balcony
    { position=Vector3(-44.11, 28.10, -78.84), wait=0.08 }, -- 15, railing
    { position=Vector3(-50.62, 26.60, -79.85) },
    { position=Vector3(-52.48, 28.30, -81.71), wait=0.00 }, -- 17, post
    { position=Vector3(-52.18, 28.3, -81.52) },
    { position=Vector3(-53.99, 30.0, -82.9), wait=0.00 },   -- 19, peg
    { position=Vector3(-54.31, 31.76, -80.30), wait=0.08 }, -- 20, roof

    { position=Vector3(-45.89, 40.81, -70.41) },
    { position=Vector3(-46.56, 42.11, -70.26), wait=0.00 }, -- 22, peg 1
    { position=Vector3(-46.41, 42.11, -70.47) },
    { position=Vector3(-49.59, 43.81, -70.29), wait=0.08 }, -- 24, peg 2
    { position=Vector3(-49.44, 43.8, -70.45) },
    { position=Vector3(-52.57, 45.31, -70.33), wait=0.05 }, -- 26, peg 3
    { position=Vector3(-49.62, 47.11, -70.24), wait=0.08 }, -- 27, peg 4
    { position=Vector3(-49.14, 47.11, -70.67) },
    { position=Vector3(-46.39, 48.91, -70.69), wait=0.08 }, -- 29, 2nd to last jump before 3rd roof
    { position=Vector3(-46.00, 48.91, -71.08) },
    { position=Vector3(-49.02, 50.44, -70.56), wait=0.08 }, -- 31, jump to roof

    { position=Vector3(-53.22, 52.1, -66.66) },
    { position=Vector3(-53.89, 53.68, -65.98), wait=0.00 }, -- 33
    { position=Vector3(-55.72, 54.51, -66.72), wait=0.00 },
    { position=Vector3(-55.64, 53.44, -65.25) },
    { position=Vector3(-56.31, 54.82, -63.22), wait=0.08 },
    { position=Vector3(-57.34, 54.78, -62.79) },
    { position=Vector3(-57.14, 54.95, -58.82) },
    { position=Vector3(-55.81, 56.47, -58.96) },
    { position=Vector3(-54.50, 57.74, -58.44), wait=0.08 }, -- 40 jump onto wood area
    { position=Vector3(-54.48, 57.73, -56.56) },
    { position=Vector3(-55.06, 59.53, -55.71), wait=0.00 }, -- 42, peg 1
    { position=Vector3(-54.74, 61.31, -58.41), wait=0.00 }, -- 43, peg 2
    { position=Vector3(-54.46, 62.75, -56.34), wait=0.08 }, -- 44, flat board
    { position=Vector3(-54.48, 62.75, -56.67) },
    { position=Vector3(-55.01, 64.31, -59.55), wait=0.08 }, -- 46, jump to circle
    { position=Vector3(-55.05, 65.94, -62.18), wait=0.08 }, -- 47, jump above the circle
    { position=Vector3(-54.32, 68.48, -64.66) },
    { position=Vector3(-52.49, 67.19, -65.71) },
    { position=Vector3(-49.14, 68.41, -65.81), wait=0.08 }, -- 50, peg 1
    { position=Vector3(-46.84, 70.21, -65.81), wait=0.00 }, -- 51, peg 2
    { position=Vector3(-44.77, 72.01, -65.78), wait=0.00 }, -- 52, peg 3
    { position=Vector3(-49.23, 73.51, -65.64), wait=0.08 }, -- 53, peg 4
    { position=Vector3(-50.92, 75.11, -66.13), wait=0.00 }, -- 54, peg 5
    { position=Vector3(-47.11, 76.41, -65.88), wait=0.08 }, -- 55, peg 6
    { position=Vector3(-45.46, 77.25, -65.47), wait=0.00 }, -- 56, corner

    { position=Vector3(-41.58, 79.05, -65.55), wait=0.08 }, -- 57, peg 1
    { position=Vector3(-41.07, 79.05, -65.93) },            -- 58, repositioning
    { position=Vector3(-39.84, 80.85, -63.60), wait=0.08 }, -- 59, peg 2
    { position=Vector3(-41.53, 82.24, -61.86), wait=0.08 }, -- 60, right side of flag
    { position=Vector3(-41.54, 82.25, -56.47), wait=0.08 }, -- 61, left side of flag

    { position=Vector3(-40.99, 83.75, -55.39), wait=0.00 }, -- 62, peg 1
    { position=Vector3(-40.4, 83.75, -55.31) },             -- 63, reposition
    { position=Vector3(-39.12, 85.55, -51.90), wait=0.1 }, -- 64, peg 2
    { position=Vector3(-40.05, 87.35, -54.45), wait=0.08 }, -- 65, peg 3
    { position=Vector3(-40.35, 88.49, -54.42), wait=0.00 }, -- 66, jumping to ledge
    { position=Vector3(-39.96, 89.65, -52.00), wait=0.08 }, -- 67, peg 4
    { position=Vector3(-39.49, 89.65, -52.34) },
    { position=Vector3(-40.81, 90.89, -51.97), wait=0.00 }, -- 69, outer Ledge
    { position=Vector3(-42.18, 89.16, -53.73) },            -- 70, going down to lower edge
    { position=Vector3(-41.64, 89.15, -65.36) },            -- 71, walk across
    { position=Vector3(-46.15, 89.15, -65.34) },            -- 72, turn the corner
    { position=Vector3(-48.28, 90.88, -66.2), wait=0.00 },  -- 73, jumping up 
    { position=Vector3(-44.86, 90.89, -66.22) },            -- 74, position for peg 3
    { position=Vector3(-39.95, 91.01, -68.30), wait=0.1 }, -- 75, last peg #3
    --{ position=Vector3(-40.21, 91.01, -68.62) },            -- 76, positioning
    { position=Vector3(-40.25, 91.01, -68.85) },
    --{ position=Vector3(-37.76, 92.81, -67.00), wait=0.1 }
    { position=Vector3(-36.94, 92.81, -67.0), wait=0.1 },
    { position=Vector3(-37.46, 94.6, -65.43), wait=0.00 },
    { position=Vector3(-38.51, 95.38, -65.56), wait=0.00 },
}

function Jump()
    local jumpData = JumpPoints[JumpNumber]
    if jumpData.sprint then
        yield("/generalaction sprint")
        yield("/wait 1")
    end

    local vectorList = Activator.CreateInstance(GenericListType)
    vectorList:Add(jumpData.position)
    IPC.vnavmesh.MoveTo(vectorList, false)
    if jumpData.wait ~= nil then
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
if JumpNumber == 1 then
    IPC.vnavmesh.PathfindAndMoveTo(Vector3(-41.66, 14.02, -34.77), false) -- Getting to jump puzzle
    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        yield("/wait 1")
    end
end
while JumpNumber <= #JumpPoints do
    Jump()
end