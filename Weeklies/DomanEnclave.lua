function Teleport(aetheryteName)
    yield("/tp "..aetheryteName)
    while not GetCharacterCondition(45) do
        yield("/wait 0.1")
    end
    while GetCharacterCondition(45) do
        yield("/wait 0.1")
    end
end

if not IsInZone(759) then
    Teleport("Doman Enclave")
end

PathfindAndMoveTo(29.96, 0.27, 26.06)
while PathfindInProgress() or PathIsRunning() do
    yield("/wait 1")
end

yield("/target Donation Box")
yield("/wait 0.5")
yield("/interact")

while not IsAddonVisible("ReconstructionBox") do
    yield("/wait 1")
end
