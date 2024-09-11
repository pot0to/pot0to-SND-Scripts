if not IsInZone(144) then
    yield("/tp Gold Saucer")
    yield("/wait 3")
end
while not IsInZone(144) do
    yield("/wait 1")
end
PathfindAndMoveTo(-4.821474, 1.0425026, 2.2151544)
while PathIsRunning() or PathfindInProgress() do
    yield("/wait 1")
end
yield("/li Cactpot Board")
yield("/wait 10")
PathfindAndMoveTo(120.26248, 13.00115, -10.966645)
while PathIsRunning() or PathfindInProgress() do
    yield("/wait 1")
end

-- target Mini Cactpot NPC
repeat
    yield("/target Jumbo Cactpot Broker")
    yield("/wait 0.1")
until HasTarget() and GetTargetName() == "Jumbo Cactpot Broker"
repeat
    yield("/interact")
    yield("/wait 0.1")
until GetCharacterCondition(32)

-- fast forward through dialog
repeat
    yield("/wait 0.1")
until IsAddonVisible("Talk")
yield("/wait 0.1")
repeat
    yield("/click Talk Click")
    yield("/wait 0.1")
until not IsAddonVisible("Talk")

-- purchase first ticket
repeat
    yield("/wait 0.1")
until IsAddonVisible("SelectString")
yield("/wait 0.1")
yield("/callback SelectString true 0")
yield("/wait 1")

-- for each cactpot ticket
for i=0, 2 do
    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    end
    repeat
        yield("/wait 0.1")
    until IsAddonVisible("LotteryWeeklyInput")
    yield("/wait 1")
    yield("/callback LotteryWeeklyInput true "..math.random(9999))
    yield("/wait 0.1")
    yield("/callback SelectYesno true 0")
    yield("/wait 1")
end
repeat
    yield("/click Talk Click")
    yield("/wait 0.1")
until not IsAddonVisible("Talk")