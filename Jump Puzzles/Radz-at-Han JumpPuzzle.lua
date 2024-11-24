JumpNumber = 1 -- where to start

-- wait=0       for a standing jump
-- wait=0.08    for a running short jump
-- wait=0.1     for a running long jump
-- no wait      for no jump
JumpPoints = {
    { x=-92.61, y=14.0, z=149.47 },
    { x=-93.97, y=14.61, z=148.17, wait=0.02 },
    { x=-95.24, y=15.48, z=147.02, wait=0 },
    { x=-94.5, y=16.62, z=145.71, wait=0.02 },
    { x=-94.56, y=17.61, z=144.06, wait=0.02 },
    { x=-94.84, y=18.48, z=143.32, wait=0 },
    { x=-95.68, y=19.62, z=141.76, wait=0.08 },
    { x=-97.22, y=20.22, z=144.53, wait=0.08 },
    { x=-97.74, y=21.9, z=146.16, wait=0 },
    { x=-99.49, y=17.51, z=152.82, wait=0.1 },     -- 10, on cart
    { x=-102.47, y=17.74, z=151.43 },
    { x=-104.6, y=19.62, z=151.26, wait=0.08 },
    { x=-108.02, y=19.4, z=154.95 },
    { x=-107.48, y=21.15, z=157.88, wait=0.1 },    -- 14, on lamp post
    { x=-108.82, y=21.98, z=159.65, wait=0.08 },
    { x=-109.32, y=23.78, z=160.26, wait=0.01 },
    { x=-109.86, y=25.49, z=160.13, wait=0.02 },
    { x=-110.08, y=26.94, z=163.32, wait=0.1 },
    { x=-110.82, y=28.25, z=164.09, wait=0.02 },
    { x=-108.48, y=28.25, z=166.44 },
    { x=-108.07, y=29.64, z=166.76, wait=0 },
    { x=-109.1, y=30.82, z=165.82, wait=0.02 },
    { x=-111.13, y=30.82, z=163.77, wait=0.08 },
    { x=-109.65, y=31.81, z=161.06, wait=0.1 },     -- 24, on long angled beam
    { x=-110.19, y=33.43, z=159.93, wait=0.02 },
    { x=-108.68, y=34.81, z=156.45, wait=0.1 },
    { x=-105.81, y=36.46, z=153.77, wait=0.2 },
    { x=-100.80, y=36.54, z=152.05, wait=0.2 },
    { x=-100.75, y=36.54, z=149.71 },
    { x=-98.25, y=37.07, z=148.46, wait=0.08 },     -- 30, on platform with crates
    { x=-92.01, y=37.07, z=144.02 },
    { x=-89.95, y=37.07, z=146.3 },
    { x=-88.58, y=38.16, z=144.65, wait=0.02 },     -- 33, on barrels
    { x=-86.74, y=39.08, z=144.08, wait=0.02 },
    { x=-87.55, y=40.16, z=143.36, wait=0.01 },
    { x=-89.53, y=41.08, z=143.4, wait=0.01 },
    { x=-92.14, y=41.08, z=141.96 },
    { x=-96.66, y=40.34, z=145.5, wait=0.1 },
    { x=-97.45, y=40.34, z=146.42 },
    { x=-98.05, y=41.9, z=148.21, wait=0.08 },
    { x=-99.16, y=42.9, z=148.6, wait=0 },
    { x=-98.63, y=42.9, z=148.5 },
    { x=-97.51, y=44.2, z=148.27, wait=0 },
    { x=-98.72, y=45.19, z=149.13, wait=0 },
    { x=-99.73, y=46.33, z=147.2, wait=0.08 },      -- 44, top
}

function Jump()
    local jumpData = JumpPoints[JumpNumber]
    PathMoveTo(jumpData.x, jumpData.y, jumpData.z)
    if jumpData.wait ~=nil then
        yield("/wait "..jumpData.wait)
        yield("/gaction jump")
    end
    repeat
        yield("/wait 0.1")
    until not PathIsRunning()
    yield("/wait 0.5")
    JumpNumber = JumpNumber + 1
end

while JumpNumber <= #JumpPoints do
    Jump()
end