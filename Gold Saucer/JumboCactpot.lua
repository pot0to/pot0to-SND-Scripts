--[[

****************************************
*            Jumbo Cactpot             * 
****************************************

Created by: pot0to (https://ko-fi.com/pot0to)
Description: Teleports to Gold Saucer, picks up last week's cactpot prizes (if you had any), and
purchases 3 new tickets using random numbers.

***********
* Version *
*  1.0.0  *
***********

*********************
*  Required Plugins *
*********************
1. Telepoter
2. Lifestream
3. TextAdvance
4. Vnavmesh
]]

function Teleport(aetheryteName)
    yield("/tp "..aetheryteName)
    while not GetCharacterCondition(45) do
        yield("/wait 0.1")
    end
    while GetCharacterCondition(45) do
        yield("/wait 0.1")
    end
end

function Start()
    if not IsInZone(144) then
        Teleport("Gold Saucer")
        return
    end

    yield("/target Aetheryte")

    if not HasTarget() or GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 7 then
        PathfindAndMoveTo(-4.82, 1.04, 2.21)
    elseif GetDistanceToTarget() <= 7 then
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
    elseif not HasTarget() or GetTargetName() ~= "Cactpot Cashier" or GetDistanceToTarget() > 7 then
        PathfindAndMoveTo(123.25, 13.00, -19.35)
    elseif GetDistanceToTarget() <= 7 then
        yield("/vnav stop")
        yield("/interact")
        RewardClaimed = true
    end
end

TicketsPurchased = false
function PurchaseNewTickets()
    yield("/target Jumbo Cactpot Broker")

    if IsAddonVisible("LotteryWeeklyRewardList") then
        yield("/echo You have already purchased tickets this week!")
        yield("/callback LotteryWeeklyRewardList true -1")
        State = CharacterStates.endState
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("LotteryWeeklyInput") then
        yield("/wait 1")
        yield("/callback LotteryWeeklyInput true "..math.random(9999))
    elseif TicketsPurchased and not GetCharacterCondition(32) then
        State = CharacterStates.endState
    elseif not HasTarget() or GetTargetName() ~= "Jumbo Cactpot Broker" or GetDistanceToTarget() > 7 then
        PathfindAndMoveTo(120.26, 13.00, -10.9)
    elseif GetDistanceToTarget() <= 7 then
        yield("/vnav stop")
        yield("/interact")
        TicketsPurchased = true
    end

end

function EndState()
    if IsAddonVisible("SelectString") then
        yield("/callback SelectString true -1")
    else
        StopFlag = true
    end
end

CharacterStates =
{
    start = Start,
    claimPrize = ClaimPrize,
    purchaseNewTickets = PurchaseNewTickets,
    endState = EndState
}

StopFlag = false
State = CharacterStates.start
yield("/at y")
while not StopFlag do
    State()
    yield("/wait 0.1")
end