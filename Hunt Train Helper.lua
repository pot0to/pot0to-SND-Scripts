if not GetCharacterCondition(4) then
    yield('/gaction "mount roulette"')
    yield("/wait 3")
end
yield("/vnav flyflag")
yield("/wait 3")
yield("/rotation manual")

while PathfindInProgress() or PathIsRunning() do
    yield("/wait 1")
end

repeat
    yield('/ac dismount')
    yield("/wait 1")
until not GetCharacterCondition(4)

yield("/targetenemy")

if HasTarget() and GetTargetHuntRank() == 2 then
    if GetDistanceToTarget() > 20 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        end
    else
        yield("/vnav stop")
    end
else
    yield("/nexttarget")
end