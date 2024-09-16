function Start()
    if not IsInZone(144) then
        Teleport("Gold Saucer")
        return
    end

    yield("/target Aetheryte")

    if not HasTarget() or GetTargetName() ~= "aetheryte" then
        yield("/echo "..GetTargetName())
        PathfindAndMoveTo(-4.82, 1.04, 2.21)
    elseif GetDistanceToTarget() < 7 then
        yield("/vnav stop")
        yield("/li Cactpot Board")
        State = CharacterStates.claimPrize
    end
end

RewardClaimed = false
function ClaimPrize()
    yield("/target Cactpot Cashier")

    if IsAddonVisible("LotteryWeeklyRewardList") then
        yield("/callback LotteryWeeklyRewardList true -1")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif RewardClaimed and not GetCharacterCondition(32) then
        State = CharacterStates.purchaseNewTickets
    elseif not HasTarget() or GetTargetName() ~= "Cactpot Cashier" then
        PathfindAndMoveTo(123.25, 13.00, -19.35)
    elseif GetDistanceToTarget() < 7 then
        yield("/vnav stop")
        yield("/interact")
        RewardClaimed = true
    end
end

TicketsPurchased = false
function PurchaseNewTickets()
    yield("/target Jumbo Cactpot Broker")

    if IsAddonVisible("LotteryWeeklyInput") then
        yield("/wait 1")
        yield("/callback LotteryWeeklyInput true "..math.random(9999))
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif TicketsPurchased and not GetCharacterCondition(32) then
        State = CharacterStates.endState
    elseif not HasTarget() or GetTargetName() ~= "Jumbo Cactpot Broker" then
        PathfindAndMoveTo(120.26, 13.00, -10.9)
    elseif GetDistanceToTarget() < 7 then
        yield("/vnav stop")
        yield("/interact")
        TicketsPurchased = true
    end

end

function EndState()
end

CharacterStates =
{
    start = Start,
    claimPrize = ClaimPrize,
    purchaseNewTickets = PurchaseNewTickets,
    endState = EndState
}

State = CharacterStates.start
yield("/at y")
while true do
    if State == CharacterStates.endState then
        break
    else
        State()
        yield("/wait 0.1")
    end
end