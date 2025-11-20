--[=====[
[[SND Metadata]]
author: pot0to
version: 2.0.0
description: |
  Support via https://ko-fi.com/pot0to
  Tulliyolal Tower jump puzzle and sightseeing log: https://youtu.be/paXx-tiXkh0?t=118
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

-- wait=0       for a standing jump
-- wait=0.08    for a running short jump
-- wait=0.1     for a running long jump
-- no wait      for no jump
JumpPoints = {
    { x=270.23, y=42.43, z=-376.12 },
    { x=269.36, y=43.44, z=-376.01, wait=0 },
    { x=268.4, y=45.0, z=-375.98, wait=0 },
    { x=267.35226, y=45, z=-377.7382 }, -- 4, beginning of jump puzzle
    { x=267.35, y=46.71, z=-378.15, wait=0},
    { x=267.34, y=48.43, z=-381.26, wait=0.1 },
    { x=267.38, y=49.95, z=-384.29, wait=0.1 },
    { x=267,00, y=51.66, z=-387.12, wait=0.1 },
    { x=267.16, y=51.66, z=-390.14, wait=0.08 },
    { x=267.17, y=51.66, z=-390.26 },
    { x=267.02, y=53.37, z=-393.00, wait=0.1 },
    { x=265.71, y=54.30, z=-393.12, wait=0 }, -- 12, first ledge
    { x=264.78, y=54.30, z=-380.32 },
    { x=264.86, y=55.50, z=-379.61, wait=0 },
    { x=264.68, y=57.10, z=-382.20, wait=0.1 },
    { x=264.74, y=58.80, z=-379.66, wait=0.08 },
    { x=265.08, y=59.72, z=-383.13, wait=0.1 }, -- 17, wooden platform
    { x=265.99, y=59.73, z=-383.1 },
    { x=266.22, y=59.73, z=-384.70 },
    { x=267.57, y=61.00, z=-386.60, wait=0.08 },
    { x=267.88, y=60.99, z=-386.36 },
    { x=267.15, y=62.50, z=-388.92, wait=0.08 },
    { x=266.10, y=63.85, z=-392.89, wait=0.1 },
    { x=265.98, y=63.85, z=-394.98 },
    { x=266.07, y=65.42, z=-397.68, wait=0.1 },
    { x=264.94, y=67.20, z=-400.58, wait=0.1 },
    { x=265.67, y=67.20, z=-401.16 },
    { x=261.56, y=67.18, z=-401.39, wait=0.08 },
    { x=261.39, y=67.18, z=-401.39 },
    { x=257.85, y=68.39, z=-401.48, wait=0.1 },
    { x=257.72, y=69.47, z=-399.87, wait=0.08 }, -- 31, second ledge
    { x=263.72, y=69.47, z=-399.47 },
    { x=263.33, y=69.47, z=-388.31 },
    { x=261.44, y=70.94, z=-388.12, wait=0 },
    { x=262.32, y=70.94, z=-385.76 },
    { x=262.78, y=72.46, z=-384.46, wait=0 },
    { x=262.61, y=74.01, z=-382.58, wait=0.08 },
    { x=262.75, y=75.59, z=-384.71, wait=0.08 },
    { x=262.62, y=77.18, z=-382.51, wait=0.08 },
    { x=262.78, y=78.77, z=-384.70, wait=0.08 },
    { x=263.05, y=80.49, z=-388.04, wait=0.1 }, -- 41, wooden platform
    { x=263.02, y=80.49, z=-389.04 },
    { x=260.92, y=82.25, z=-389.25, wait=0.08 },
    { x=262.02, y=83.75, z=-386.71, wait=0.08 },
    { x=260.95, y=85.25, z=-389.16, wait=0.08 },
    { x=261.43, y=86.72, z=-391.51, wait=0.08 },
    { x=263.18, y=88.25, z=-389.18, wait=0.08 },
    { x=262.39, y=89.62, z=-392.74, wait=0.1 }, -- 48, top of pillar
    { x=261.82, y=89.62, z=-394.66 },
    { x=261.69, y=91.17, z=-395.34, wait=0 },
    { x=261.89, y=92.67, z=-393.13, wait=0.08 },
    { x=262.96, y=94.17, z=-395.23, wait=0.1 },
    { x=263.0, y=94.17, z=-395.06 },
    { x=261.91, y=95.67, z=-393.01, wait=0.08 },
    { x=263.12, y=97.17, z=-395.33, wait=0.08 },
    { x=260.77, y=98.88, z=-395.47, wait=0.08 }, -- 56, ledge
    { x=260.61, y=98.88, z=-392.94 },
    { x=260.58, y=98.88, z=-387.28, wait=0.2 }, -- 58, jump over skinny platform entirely bc wide routes are safer
    { x=260.73, y=100.44, z=-386.35, wait=0 },
    { x=260.81, y=102.02, z=-383.72, wait=0.08 },
    { x=261.38, y=103.52, z=-386.15, wait=0.08 },
    { x=260.94, y=105.02, z=-383.52, wait=0.08 },
    { x=261.27, y=106.52, z=-386.47, wait=0.08 },
    { x=261.86, y=107.93, z=-388.47, wait=0.08 }, -- 64, wooden platform
    { x=261.14, y=109.52, z=-386.19, wait=0.08 },
    { x=260.85, y=111.02, z=-383.81, wait=0.08 },
    { x=261.29, y=112.52, z=-386.00, wait=0.08 },
    { x=261.07, y=114.02, z=-383.70, wait=0.08 },
    { x=261.08, y=114.67, z=-387.83, wait=0.1 }, -- 69, wooden platform
    { x=259.23, y=115.64, z=-385.93, wait=0.08 },
    { x=258.92, y=115.64, z=-384.63 },
    { x=260.62, y=116.85, z=-383.23, wait=0.08 },
    { x=259.54, y=118.62, z=-381.82, wait=0.08 },
    { x=261.17, y=120.39, z=-382.38, wait=0.08 },
    { x=259.81, y=122.15, z=-381.66, wait=0.08 },
    { x=260.68, y=123.92, z=-383.02, wait=0.08 },
    { x=260.49, y=124.56, z=-386.01, wait=0.08 },
    { x=260.38, y=125.4, z=-388.32, wait=0.08 }, -- 78, wooden platform
    { x=258.12, y=126.32, z=-386.61, wait=0.1 }, -- 79, base of 4 pillars + center column
    { x=258.56, y=126.32, z=-387.90 },
    { x=259.77, y=127.94, z=-385.39, wait=0.08 },
    { x=259.29, y=129.44, z=-387.91, wait=0.1 },
    { x=259.8, y=130.94, z=-385.46, wait=0.08 },
    { x=259.54, y=132.44, z=-387.91, wait=0.08 },
    { x=260.08, y=133.94, z=-385.45, wait=0.08 },
    { x=260.83, y=135.44, z=-387.72, wait=0.08 }, -- 86, wooden platform
    { x=261.39, y=136.94, z=-385.6, wait=0.08 },
    { x=260.97, y=138.44, z=-387.69, wait=0.08 }, -- 88, wooden platform
    { x=260.20, y=139.61, z=-390.68, wait=0.08 }, -- 89, on railing
    { x=258.93, y=141.31, z=-389.49, wait=0 },
    { x=259.04, y=143.02, z=-391.6, wait=0.08 },
    { x=257.28, y=144.21, z=-390.92, wait=0.1 }
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
while JumpNumber <= #JumpPoints do
    Jump()
end