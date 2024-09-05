if not IsInZone(144) then
    yield("/tp Gold Saucer")
end
PathfindAndMoveTo(-46.09, 1.60, 20.81)
while PathIsRunning() or PathfindInProgress() do
    yield("/wait 1")
end

-- target Mini Cactpot NPC
repeat
    yield("/target Mini Cactpot Broker")
    yield("/wait 1")
    yield("/interact")
until HasTarget() and GetTargetName() == "Mini Cactpot Broker"

-- yes play mini cactpot
repeat
    yield("/wait 1")
until IsAddonVisible("SelectIconString")
yield("/wait 1")
yield("/callback SelectIconString true 0")

-- fast forward through dialog
repeat
    yield("/wait 1")
until IsAddonVisible("Talk")
yield("/wait 1")
repeat
    yield("/click Talk Click")
    yield("/wait 1")
until not IsAddonVisible("Talk")

-- for each cactpot ticket
while GetCharacterCondition(32) do
    repeat
        yield("/wait 1")
    until IsAddonVisible("SelectYesno")
    yield("/wait 1")
    yield("/callback SelectYesno true 0")
    repeat
        yield("/wait 1")
    until IsAddonVisible("Talk")
    repeat
        yield("/click Talk Click")
        yield("/wait 1")
    until not IsAddonVisible("Talk")
end