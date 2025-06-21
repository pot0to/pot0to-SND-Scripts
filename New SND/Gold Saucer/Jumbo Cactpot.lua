--[[SND Metadata]]
author: pot0to
version: 2.0.1
description: Teleports to Gold Saucer, picks up last week's cactpot prizes (if you had any), and purchases 3 new tickets using random numbers.\rhttps://ko-fi.com/pot0to
plugin_dependencies: vnavmesh, TextAdvance, Lifestream
--[[End Metadata]]
--[[

********************************************************************************
*                                                                              *
*                                Jumbo Cactpot                                 *
*                                                                              *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
Description: Teleports to Gold Saucer, picks up last week's cactpot prizes (if
you had any), and purchases 3 new tickets using random numbers.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

1. Lifestream
2. TextAdvance
3. Vnavmesh

********************************************************************************
*            Code: Don't touch this unless you know what you're doing          *
********************************************************************************
]]

import("System.Numerics")

CharacterCondition =
{
    casting=27,
    occupiedShopkeeper = 32,
    betweenAreas=45
}

function Teleport(aetheryteName)
    yield("/li tp "..aetheryteName)
    yield("/wait 1")
    while Svc.Condition[CharacterCondition.casting] do
        yield("/wait 0.1")
    end
    yield("/wait 1")
    while Svc.Condition[CharacterCondition.betweenAreas] do
        yield("/wait 0.1")
    end
end

function GetDistanceToPoint(vec3)
    local px = Svc.ClientState.LocalPlayer.Position.X
    local py = Svc.ClientState.LocalPlayer.Position.Y
    local pz = Svc.ClientState.LocalPlayer.Position.Z
    local distance = math.sqrt((vec3.X - px)^2 + (vec3.Y-py)^2 + (vec3.Z-pz)^2)
    return distance
end

function Start()
    if IPC.Lifestream.IsBusy() then
        return
    end

    if Svc.ClientState.TerritoryType ~= 144 then
        Teleport("Gold Saucer")
        return
    end

    yield("/target Aetheryte")

    if  Svc.Targets.Target == nil or
        Svc.Targets.Target.Name.TextValue ~= "aetheryte" or
        GetDistanceToPoint(Svc.Targets.Target.Position) > 7
    then
        IPC.vnavmesh.PathfindAndMoveTo(Vector3(-4.82, 1.04, 2.21), false)
    elseif GetDistanceToPoint(Svc.Targets.Target.Position) <= 7 then
        yield("/echo close")
        yield("/vnav stop")
        yield("/li Cactpot Board")
        State = CharacterStates.claimPrize
    end
end

RewardClaimed = false
function ClaimPrize()
    yield("/target Cactpot Cashier")

    if Addons.GetAddon("LotteryWeeklyRewardList").Ready then
        yield("/callback LotteryWeeklyRewardList true -1")
    elseif Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
    elseif RewardClaimed and not Svc.Condition[CharacterCondition.occupiedShopkeeper] then
        State = CharacterStates.purchaseNewTickets
    elseif Svc.Targets.Target == nil or
        Svc.Targets.Target.Name.TextValue ~= "Cactpot Cashier" or
        GetDistanceToPoint(Svc.Targets.Target.Position) > 7
    then
        IPC.vnavmesh.PathfindAndMoveTo(Vector3(123.25, 13.00, -19.35), false)
    elseif GetDistanceToPoint(Svc.Targets.Target.Position) <= 7 then
        yield("/vnav stop")
        yield("/interact")
        RewardClaimed = true
    end
end

TicketsPurchased = false
function PurchaseNewTickets()
    yield("/target Jumbo Cactpot Broker")

    if Addons.GetAddon("LotteryWeeklyRewardList").Ready then
        yield("/echo You have already purchased tickets this week!")
        yield("/callback LotteryWeeklyRewardList true -1")
        State = CharacterStates.endState
    elseif Addons.GetAddon("SelectString").Ready then
        yield("/callback SelectString true 0")
    elseif Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
    elseif Addons.GetAddon("LotteryWeeklyInput").Ready then
        yield("/wait 1")
        yield("/callback LotteryWeeklyInput true "..math.random(9999))
    elseif TicketsPurchased and not Svc.Condition[CharacterCondition.occupiedShopkeeper] then
        State = CharacterStates.endState
    elseif Svc.Targets.Target == nil or
        Svc.Targets.Target.Name.TextValue ~= "Jumbo Cactpot Broker" or
        GetDistanceToPoint(Svc.Targets.Target.Position) > 7
    then
        IPC.vnavmesh.PathfindAndMoveTo(Vector3(120.26, 13.00, -10.9), false)
    elseif GetDistanceToPoint(Svc.Targets.Target.Position) <= 7 then
        yield("/vnav stop")
        yield("/interact")
        TicketsPurchased = true
    end

end

function EndState()
    if Addons.GetAddon("SelectString").Ready then
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