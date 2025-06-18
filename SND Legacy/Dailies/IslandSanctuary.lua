--[[
********************************************************************************
*                           Island Sanctuary Dailies                           *
*                                Version 0.0.7                                 *
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
--#region Settings

********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

FeedToCraft = "Island Greenfeed"
    Quantity = 99

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
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

Feed =
{
    types =
    {
        { name="Island Sweetfeed", id=37612, recipeIndex=0, requiredMaterialsCount=0 },
        { name="Island Greenfeed", id=37613, recipeIndex=1, requiredMaterialsCount=1 },
        { name="Premium Island Greenfeed", id=37614, recipeIndex=2, requiredMaterialsCount=2 }
    },
    ingredients =
    {
        { name="Island Popoto", id=25204 },
        { name="Island Cabbage", id=25208 },
        { name="Isleberry", id=25306 },
        { name="Island Pumpkin", id=25232 },
        { name="Island Onion", id=25203 },
        { name="Island Tomato", id=25209 },
        { name="Island Wheat", id=25357 },
        { name="Island Corn", id=25352 },
        { name="Island Parsnip", id=25215 },
        { name="Island Radish", id=25233 }
    }
}

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[IslandSanctuary] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[IslandSanctuary] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
end

function EnterIslandSanctuary()
    local distanceToFerryman = GetDistanceToPoint(Locations.moraby.ferryman.x, Locations.moraby.ferryman.y, Locations.moraby.ferryman.z)

    if IsInZone(Locations.sanctuary.zoneId) then
        State = CharacterState.openWorkshop
        LogInfo("[IslandSanctuary] OpenWorkshop")
    elseif not IsInZone(Locations.moraby.zoneId) or distanceToFerryman > 30 then
        TeleportTo(Locations.moraby.aetheryte)
    elseif distanceToFerryman > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Locations.moraby.ferryman.x, Locations.moraby.ferryman.y, Locations.moraby.ferryman.z)
        elseif distanceToFerryman > 13 then
            yield("/gaction jump")
            yield("/wait 1")
        end
    elseif PathfindInProgress() or PathIsRunning() then
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
    local feed = GetFeed()
    if GetItemCount(feed.id) < 10 then
        CraftFeed()
    else
        OpenAndCloseNpc(Locations.sanctuary.ranch, CharacterState.garden, "Garden")
    end
end

function CollectGarden()
    OpenAndCloseNpc(Locations.sanctuary.garden, CharacterState.talkToFurball, "GoToFurball")
end

PathToFurball = "H4sIAAAAAAAACu1WTY/TMBD9K5XPIYodO4lzQ2VbFbRL2S0qLOLgEreJlHiK44BWVf874yT7UeDAFbW+eN6TPfM8ebJzIDeq0SQnS+XKyuwmWwvNZK5sYbSdOJjMOrtRdU0CMrfQ7XHlR7PzkS6QmwEUJI8Ccq1Mp+o+XCm7026O+bRdON305Fo97KEyriX5lwNZQlu5CgzJD+QTyV8xIcNMsiQNyGeSCxFSiQPRPckpj8JYCkGPCMHoxRvkIiECcquKqsOEcegFwA/daONIzoL+MNvKoDRnOx2QhXHaqm9uXbnyvU8QnXJjD8gp+5vKyJdBef18388oqS3h5+MmXItytqpuX9TsE9CAXDXg9GNtbMsYvu5XjOBDp1v3Mr7T34f2wmak7xzsp2CKURky76q6nkLnj47oFjqnn88zLZWbQtMo3wxPeL1rVblnoR7NwJ4m9eSqavR1ewKvVn82A5uwaJelMg6ap6T+C5DcdHWNxumtgOZaPexRlpR+ww0U+mm1B29hg+mOwV/cEcmQpVzwviIXYcwzniaDO5IoTGQiL+44X3dkYUoFZYM7WJgyyTgf3JElIac0yy53x7m6I8G7I2JcDO7Akn4M7mAxviw0SsTFHWfsjjiVcTK4g44vO6MY8Zj/86OC4PLL8d8a4+vxFx+sRHEGCwAA"
TalkedToFurball = false
function TalkToFurball()
    local npc = Locations.sanctuary.furball
    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 20 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            yield('/gaction "mount roulette"')
            yield("/wait 1")
            return
        elseif not IsVislandRouteRunning() then
            VislandStartRoute(PathToFurball, true)
            return
        end
    elseif IsVislandRouteRunning() then
        return
    end

    if not HasTarget() or GetTargetName() ~= npc.name then
        yield("/target ".. npc.name)
    elseif GetCharacterCondition(CharacterCondition.flying) then
        yield("/ac dismount")
        yield("/wait 1")
    elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        if TalkedToFurball then
            State = CharacterState.export
            LogInfo("[IslandSanctuary] State Change: Export")
        else
            yield("/interact")
        end
    elseif IsAddonVisible("SelectString") then
        TalkedToFurball = true
        yield("/callback SelectString true 2")
    end
end

function Export()
    OpenAndCloseNpc(Locations.sanctuary.export, CharacterState.endState, "EndState")
end

function End()
end

function GetFeed()
    for _, feed in ipairs(Feed.types) do
        if feed.name == FeedToCraft then
            return feed
        end
    end
end

function SortTopIngredients(i1, i2)
    return i1.quantity > i2.quantity
end

function GetTopIngredients(count)
    local ingredients = {}
    for i=1,#Feed.ingredients do
        local quantity = GetNodeText("ContextIconMenu", 2, i, 1, 6)
        table.insert(ingredients, { contextMenuParam=Feed.ingredients[i], quantity=quantity })
    end
    
    local topIngredients = {}
    table.sort(ingredients, SortTopIngredients)
    for i=1,count do
        table.insert(topIngredients, ingredients[i])
    end
    return topIngredients
end

function CraftFeed()
    if not IsAddonVisible("MJIRecipeNoteBook") then
        yield("/callback MJIHud true 15")
    elseif GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
        yield("/wait 3")
    else
        yield("/wait 1")
        yield("/callback MJIRecipeNoteBook true 11 1")
        yield("/wait 1")
        local feed = GetFeed()
        yield("/callback MJIRecipeNoteBook true 12 "..feed.recipeIndex)
        yield("/wait 1")
        local topIngredients = GetTopIngredients(feed.requiredMaterialsCount)
        local maxCrafts = Quantity
        for i=0,(feed.requiredMaterialsCount-1) do
            local ingredient = topIngredients[i+1]

            yield("/callback MJIRecipeNoteBook true 20 "..i)
            yield("/wait 1")
            yield("/callback ContextIconMenu true 0 0 "..ingredient.contextMenuParam.." 0 0")
            yield("/wait 1")
            local requiredQty = GetNodeText("MJIRecipeNoteBook", 24-i, 12)
            local crafts = ingredient.quantity/requiredQty
            if crafts < maxCrafts then
                maxCrafts = crafts
            end
        end
        yield("/wait 1")
        yield("/callback MJIRecipeNoteBook true 14 "..maxCrafts)
    end
end

CharacterState =
{
    enter = EnterIslandSanctuary,
    openWorkshop = OpenWorkshop,
    setWorkshop = SetWorkshopSchedule,
    granary = SetGranary,
    ranch = CollectRanch,
    garden = CollectGarden,
    talkToFurball = TalkToFurball,
    export = Export,
    endState = End
}

yield("/at y")
State = CharacterState.enter
while State ~= CharacterState.endState do
    if not GetCharacterCondition(CharacterCondition.betweenAreas) then
        State()
    end
    yield("/wait 0.1")
end