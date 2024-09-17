-- wait=0 for a standing jump
-- wait=0.1 for a running jump
-- no wait for no jump
JumpPoints = {
    { x=267.35226, y=45, z=-377.7382 },
    { x=267.35, y=46.71, z=-378.15, wait=0},
    { x=267.34, y=48.43, z=-381.26, wait=0.1 },
    { x=267.38, y=49.95, z=-384.29, wait=0.1 },
    { x=267,00, y=51.66, z=-387.12, wait=0.1 },
    { x=267.16, y=51.66, z=-390.14, wait=0.1 }
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

JumpNumber = 1
PathfindAndMoveTo(267.35226, 45, -377.7382)
while PathIsRunning() do
    yield("wait 1")
end
while JumpNumber <= #JumpPoints do
    Jump()
end