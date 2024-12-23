--[[
********************************************************************************
*                           Island Sanctuary Dailies                           *
*                                Version 0.0.0                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Description:
0. Teleports to Moraby Drydocks and enters Island Sanctuary
1. Workshop
2. Granary
3. Ranch
4. Garden
5. Exporter

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. Visland
2. Vnavmesh
3. Teleporter
4. TextAdvance
]]

FlyingUnlocked = false -- don't change this bc the pathing sucks

CharacterCondition = {
    normal=1,
    mounted=4,
    gathering=6,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDutyDiadem=34,
    occupiedMateriaExtractionAndRepair=39,
    gathering42=42,
    fishing=43,
    betweenAreas=45,
    jumping48=48,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    jumpPlatform=61,
    mounting64=64,
    beingMoved=70,
    flying=77
}

Locations =
{
    moraby = {
        zoneId = 135, -- Lower La Noscea
        aetheryte = "Moraby Drydocks",
        ferryman = { name="Baldin", x=174, y=14, z=667 },
    },
    sanctuary = {
        zoneId = 1055,
        workshop = {
            name="Tactful Taskmaster",
            x=-277, y=39, z=229,
            addonName="MJICraftSchedule",
        },
        granary = {
            name="Excitable Explorer",
            x=-264, y=39, z=234,
            addonName="MJIGatheringHouse"
        },
        ranch = {
            name="Creature Comforter",
            x=-270, y=55, z=134,
            addonName="MJIAnimalManagement"
        },
        garden = {
            name="Produce Producer",
            x=-257, y=55, z=134,
            addonName="MJIFarmManagement"
        },
        furball = {
            name="Felicitous Furball",
            x=-273, y=41, z=210,
            waypointX=-257.56, waypointY=40.0, waypointZ=210.0
        },
        export = {
            name="Enterprising Exporter",
            x=-267, y=41, z=207,
            addonName="MJIDisposeShop"
        },
        blueCowries = {
            name="Horrendous Hoarder",
            x=-265, y=41, z=207,
            addonName="ShopExchangeCurrency"
        }
    }
}

function EnterIslandSanctuary()
    if IsInZone(Locations.sanctuary.zoneId) then
        State = CharacterState.openWorkshop
        LogInfo("[IslandSanctuary] OpenWorkshop")
    elseif not IsInZone(Locations.moraby.zoneId) or
        GetDistanceToPoint(Locations.moraby.ferryman.x, Locations.moraby.ferryman.y, Locations.moraby.ferryman.z) > 30 then
        TeleportTo(Locations.moraby.aetheryte)
    elseif GetDistanceToPoint(Locations.moraby.ferryman.x, Locations.moraby.ferryman.y, Locations.moraby.ferryman.z) > 30 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Locations.moraby.ferryman.x, Locations.moraby.ferryman.y, Locations.moraby.ferryman.z)
        end
    elseif PathfindInProgress or PathIsRunning() then
        yield("/vnav stop")
    elseif not HasTarget() or GetTargetName() ~= Locations.moraby.ferryman.name then
        yield("/target "..Locations.moraby.ferryman.name)
    elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        yield("/interact")
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    end
end

function OpenNpc(npc, nextState)
    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 20 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            yield('/gaction "mount roulette"')
            yield("/wait 1")
            return
        elseif GetCharacterCondition(CharacterCondition.casting) or GetCharacterCondition(CharacterCondition.mounting57) then
            return
        end
    end
    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 5 then
        local shouldFly = FlyingUnlocked and GetCharacterCondition(CharacterCondition.mounted)
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(npc.x, npc.y, npc.z, shouldFly)
        end
    elseif PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    elseif not HasTarget() or GetTargetName() ~= npc.name then
        yield("/target ".. npc.name)
    elseif GetCharacterCondition(CharacterCondition.flying) then
        yield("/ac dismount")
        yield("/wait 1")
    elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        yield("/interact")
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
    elseif IsAddonVisible(npc.addonName) then
        State = nextState
        LogInfo("[IslandSanctuary] State Change: "..tostring(nextState))
    end
end

function OpenAndCloseNpc(npc, nextState, logNextState)
    if IsAddonVisible(npc.addonName) then
        yield("/wait 1") -- give it a moment to process
        yield("/callback "..npc.addonName.." true -1")
        State = nextState
        LogInfo("[IslandSanctuary] State Change: "..logNextState)
    else
        OpenNpc(npc, State)
    end
end

function OpenWorkshop()
    OpenNpc(Locations.sanctuary.workshop, CharacterState.setWorkshop)
end

function SetWorkshopSchedule()
    -- copy to clickboard
    -- set schedule
    repeat
        yield("/callback MJICraftSchedule true -1")
        yield("/wait 0.5")
    until not IsAddonVisible("MJICraftSchedule")
    repeat
        yield("/callback SelectString true -1")
        yield("/wait 0.5")
    until not IsAddonVisible("SelectString")

    State = CharacterState.granary
    LogInfo("[IslandSanctuary] State Change: Granary")
end

function SetGranary()
    OpenAndCloseNpc(Locations.sanctuary.granary, CharacterState.ranch, "Ranch")
end

function CollectRanch()
    OpenAndCloseNpc(Locations.sanctuary.ranch, CharacterState.garden, "Garden")
end

function CollectGarden()
    OpenAndCloseNpc(Locations.sanctuary.garden, CharacterState.goToFurball, "GoToFurball")
end

function GoToFurball()
    local npc = Locations.sanctuary.furball
    if GetDistanceToPoint(npc.waypointX, npc.waypointY, npc.waypointZ) > 20 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            yield('/gaction "mount roulette"')
            yield("/wait 1")
            return
        elseif GetCharacterCondition(CharacterCondition.casting) or GetCharacterCondition(CharacterCondition.mounting57) then
            return
        end
    end

    if GetDistanceToPoint(npc.waypointX, npc.waypointY, npc.waypointZ) > 3 then
        local shouldFly = FlyingUnlocked and GetCharacterCondition(CharacterCondition.mounted)
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(npc.waypointX, npc.waypointY, npc.waypointZ, shouldFly)
        end
        return
    end

    State = CharacterState.talkToFurball
    LogInfo("[IslandSanctuary] State Change: TalkToFurball")
end

function TalkToFurball()
    local npc = Locations.sanctuary.furball

    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 20 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            yield('/gaction "mount roulette"')
            yield("/wait 1")
            return
        elseif GetCharacterCondition(CharacterCondition.casting) or GetCharacterCondition(CharacterCondition.mounting57) then
            return
        end
    end
    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 5 then
        local shouldFly = FlyingUnlocked and GetCharacterCondition(CharacterCondition.mounted)
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(npc.x, npc.y, npc.z, shouldFly)
        end
    elseif PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    elseif not HasTarget() or GetTargetName() ~= npc.name then
        yield("/target ".. npc.name)
    elseif GetCharacterCondition(CharacterCondition.flying) then
        yield("/ac dismount")
        yield("/wait 1")
    elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        yield("/interact")
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
        State = CharacterState.export
        LogInfo("[IslandSanctuary] State Change: Export")
    end
end

function Export()
    OpenAndCloseNpc(Locations.sanctuary.export, CharacterState.endState, "EndState")
end

function End()
end

CharacterState =
{
    enter = EnterIslandSanctuary,
    openWorkshop = OpenWorkshop,
    setWorkshop = SetWorkshopSchedule,
    granary = SetGranary,
    ranch = CollectRanch,
    garden = CollectGarden,
    goToFurball = GoToFurball,
    talkToFurball = TalkToFurball,
    export = Export,
    endState = End
}

yield("/at y")
State = CharacterState.enter
while State ~= CharacterState.endState do
    State()
    yield("/wait 0.1")
end