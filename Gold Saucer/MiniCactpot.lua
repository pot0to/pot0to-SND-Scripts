--[[

********************************************************************************
*                                 Mini Cactpot                                 *
*                                Version 1.1.1                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
Description: Teleports to Gold Saucer, runs mini cactpot.

*********************
*  Required Plugins *
*********************
1. Telepoter
3. TextAdvance
4. Vnavmesh
5. Saucy
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
    else
        State = CharacterStates.goToCashier
    end
end

local Npc = { name = "Mini Cactpot Broker", x=-50, y=1, z=22 }
RewardClaimed = false
function GoToCashier()
    

    if GetDistanceToPoint(Npc.x, Npc.y, Npc.z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Npc.x, Npc.y, Npc.z)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end

    State = CharacterStates.playMiniCactpot
end

TicketsPurchased = false
function PlayMiniCactpot()
    -- TODO: replace with mini cactpot name
    
    if IsAddonVisible("LotteryDaily") then
        yield("/wait 1")
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("Talk") then
        if not HasPlugin("TextAdvance") then
            yield("/click Talk Click")
        end
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif GetDistanceToPoint(Npc.x, Npc.y, Npc.z) > 5 then
        PathfindAndMoveTo(Npc.x, Npc.y, Npc.z)
    elseif PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
    elseif TicketsPurchased and not GetCharacterCondition(32) then
        State = CharacterStates.endState
    elseif not HasTarget() or GetTargetName() ~= Npc.name then
        yield("/target "..Npc.name)
    else
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
    goToCashier = GoToCashier,
    playMiniCactpot = PlayMiniCactpot,
    endState = EndState
}

StopFlag = false
State = CharacterStates.start
yield("/at y")
while not StopFlag do
    State()
    yield("/wait 0.1")
end