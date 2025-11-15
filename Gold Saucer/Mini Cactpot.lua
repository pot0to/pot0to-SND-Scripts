--[[

********************************************************************************
*                                 Mini Cactpot                                 *
*                                Version 2.0.0                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
Description: Teleports to Gold Saucer, runs mini cactpot.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

1. Lifestream
3. TextAdvance
4. IPC.vnavmesh
5. Saucy

********************************************************************************
*            Code: Don't touch this unless you know what you're doing          *
********************************************************************************
]]
import("System.Numerics")

LogPrefix   = "[MiniCactpot]"

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

function Ready()
    if Svc.ClientState.TerritoryType ~= 144 then
        Teleport("Gold Saucer")
    else
        State = CharacterStates.goToCashier
    end
end

function GetDistanceToPoint(vec3)
    local px = Svc.ClientState.LocalPlayer.Position.X
    local py = Svc.ClientState.LocalPlayer.Position.Y
    local pz = Svc.ClientState.LocalPlayer.Position.Z
    local distance = math.sqrt((vec3.X - px)^2 + (vec3.Y-py)^2 + (vec3.Z-pz)^2)
    return distance
end

local Npc = { name = "Mini Cactpot Broker", position=Vector3(-50, 1, 22) }
local Aetheryte = Vector3(-1, 3, -1)
RewardClaimed = false
function GoToCashier()
    if GetDistanceToPoint(Aetheryte) <= 8 and IPC.vnavmesh.IsRunning() then
        yield("/gaction jump")
        yield("/wait 3")
        return
    end

    if GetDistanceToPoint(Npc.position) > 5 then
        if not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
            IPC.vnavmesh.PathfindAndMoveTo(Npc.position, false)
        end
        return
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
    end

    State = CharacterStates.playMiniCactpot
end

TicketsPurchased = false
function PlayMiniCactpot()
    -- TODO: replace with mini cactpot name
    
    if Addons.GetAddon("LotteryDaily").Ready then
        yield("/wait 1")
    elseif Addons.GetAddon("SelectIconString").Ready then
        yield("/callback SelectIconString true 0")
    elseif Addons.GetAddon("Talk").Ready then
        if not Addons.GetAddon("TextAdvance").Ready then
            yield("/click Talk Click")
        end
    elseif Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
    elseif GetDistanceToPoint(Npc.position) > 5 then
        IPC.vnavmesh.PathfindAndMoveTo(Npc.x, Npc.y, Npc.z)
    elseif IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress() then
        yield("/vnav stop")
    elseif TicketsPurchased and not Svc.Condition[CharacterCondition.occupiedShopkeeper] then
        State = CharacterStates.endState
    elseif Svc.Targets.Target == nil or Svc.Targets.Target.Name.TextValue ~= Npc.name then
        yield("/target "..Npc.name)
    else
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
    ready = Ready,
    goToCashier = GoToCashier,
    playMiniCactpot = PlayMiniCactpot,
    endState = EndState
}

StopFlag = false
State = CharacterStates.ready
yield("/at y")
while not StopFlag do
    State()
    yield("/wait 0.1")
end

yield(string.format("/echo %s MiniCactpot script completed successfully..!!", LogPrefix))
Dalamud.Log(string.format("%s MiniCactpot script completed successfully..!!", LogPrefix))