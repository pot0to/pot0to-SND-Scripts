--[[

********************************************************************************
*                 Orange Crafter Scrips (Solution Nine Patch 7.1)              *
*                                Version 0.2.3                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
State Machine Diagram: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/FateFarmingStateMachine.drawio.png

Crafts orange scrip item matching whatever class you're on, turns it in, buys
Condensed Solution, repeat.

    -> 0.2.3    Added check for ArtisanX crafting
                Fixed some bugs with stop condition
                Stops script when you're out of mats
                Fixed some bugs related to /li inn

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat
    -> Artisan
    -> Vnavmesh for finding your way to the turn in npcs

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************

IMPORTANT: Make sure this box is checked: /artisan -> Endurance -> Max Quantity Mode
]]

ArtisanIntermediatesListId = "42199"    --Id of Artisan list for crafting all the intermediate materials (eg black star, claro walnut lumber, etc.)
HomeCommand = "" --"/li inn"                 --Command you use if you want to hide somewhere. Leave blank to stay in Solution Nine

--#region Settings

--[[
********************************************************************************
*            Code: Don't touch this unless you know what you're doing          *
********************************************************************************
]]

OrangeScripRecipes =
{
    { className="Carpenter", classId=8, itemId=44190, recipeId=35787 },
    { className="Blacksmith", classId=9, itemId=44196, recipeId=35793 },
    { className="Armorer", classId=10, itemId=44202, recipeId=35799 },
    { className="Goldsmith", classId=11, itemId=44208, recipeId=35805 },
    { className="Leatherworker", classId=12, itemId=44214, recipeId=35817 },
    { className="Weaver", classId=13, itemId=44220, recipeId=35817 },
    { className="Alchemist", classId=14, itemId=44226, recipeId=35823 },
    { className="Culinarian", classId=15, itemId=44232, recipeId=35829 }
}

OrangeCrafterScripId = 41784
SolutionNineZoneId = 1186

local Npcs =
{
    turnInNpc = "Collectable Appraiser",
    scripExchangeNpc = "Scrip Exchange",
    x=-157.96, y=0.92, z=-38.06,
    aethernetShortcut = { x=-157.74, y=0.29, z=17.43 }
}

CharacterCondition =
{
    craftingMode = 5,
    casting=27,
    occupiedInQuestEvent=32,
    occupiedMateriaExtractionAndRepair=39,
    executingCraftingSkill = 40,
    craftingModeIdle = 41,
    betweenAreas=45,
    beingMoved=70,
}

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[FATE] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
end

function OutOfCrystals()
    local crystalsRequired1 = tonumber(GetNodeText("RecipeNote", 28, 4))
    local crystalsInInventory1 = tonumber(GetNodeText("RecipeNote", 28, 3))
    if crystalsRequired1 > crystalsInInventory1 then
        return true
    end

    local crystalsRequired2 = tonumber(GetNodeText("RecipeNote", 29, 4))
    local crystalsInInventory2 = tonumber(GetNodeText("RecipeNote", 29, 3))
    if crystalsRequired2> crystalsInInventory2 then
        return true
    end

    return false
end

function OutOfMaterials()
    for i=0,5 do
        local materialCount = GetNodeText("RecipeNote", 18 + i, 8)
        local materialRequirement = GetNodeText("RecipeNote", 18 + i, 15)
        if materialCount ~= "" and materialRequirement ~= "" then
            if tonumber(materialCount) < tonumber(materialRequirement) then
                return true
            end
        end
    end

    if OutOfCrystals() then
        yield("/echo Out of crystals. Stopping script.")
        StopFlag = true
        return true
    end
    return false
end

function Crafting()
    if LifestreamIsBusy() then
        yield("/wait 1")
        return
    elseif not AtInn and HomeCommand ~= "" then
        yield(HomeCommand)
        AtInn = true
        return
    end

    local slots = GetInventoryFreeSlotCount()
    if ArtisanIsListRunning() or IsAddonVisible("Synthesis") then
        yield("/wait 1")
    elseif slots == 0 then
        LogInfo("[OrangeCrafters] Out of inventory space")
        if IsAddonVisible("RecipeNote") then
            yield("/callback RecipeNote true -1")
        elseif not GetCharacterCondition(CharacterCondition.craftingMode) then
            State = CharacterState.turnIn
            LogInfo("State Change: TurnIn")
        end
    elseif IsAddonVisible("RecipeNote") and OutOfMaterials() then
        LogInfo("[OrangeCrafters] Out of materials")
        if not StopFlag then
            if (GetItemCount(ItemId) == 0) and (ArtisanTimeoutStartTime == 0) then
                LogInfo("[OrangeCrafters] Attempting to craft intermediate materials")
                yield("/artisan lists "..ArtisanIntermediatesListId.." start")
                ArtisanTimeoutStartTime = os.clock()
            elseif GetItemCount(ItemId) > 0 then
                LogInfo("[OrangeCrafters] Turning In")
                yield("/callback RecipeNote true -1")
                State = CharacterState.turnIn
                LogInfo("[OrangeCrafters] State Change: TurnIn")
            elseif os.clock() - ArtisanTimeoutStartTime > 5 then
                LogInfo("[OrangeCrafters] Artisan not starting, StopFlag = true")
                -- if artisan has not entered crafting mode within 15s of being called,
                -- then you're probably out of mats so just stop the script
                yield("/echo Artisan took too long to start. Are you out of intermediate mat materials?")
                StopFlag = true
            end
        end
    elseif not GetCharacterCondition(CharacterCondition.craftingMode) then
        LogInfo("[OrangeCrafters] Attempting to craft "..slots.." of recipe #"..RecipeId)
        ArtisanTimeoutStartTime = 0
        ArtisanCraftItem(RecipeId, slots)
        yield("/wait 5")
    end
end

function GoToSolutionNine()
    if not IsPlayerAvailable() then
        yield("/wait 1")
    elseif not IsInZone(SolutionNineZoneId) then
        TeleportTo("Solution Nine")
        yield("/echo teleported ")
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > (DistanceBetween(Npcs.aethernetShortcut.x, Npcs.aethernetShortcut.y, Npcs.aethernetShortcut.z, Npcs.x, Npcs.y, Npcs.z) + 10) then
        yield("/li nexus arcade")
        yield("/wait 1") -- give it a moment to register
    elseif IsAddonVisible("TelepotTown") then
        LogInfo("TelepotTown open")
        yield("/callback TelepotTown false -1")
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("Path not running")
            PathfindAndMoveTo(Npcs.x, Npcs.y, Npcs.z)
        end
    else
        State = CharacterState.turnIn
        LogInfo("State Change: TurnIn")
    end
end

function TurnIn()
    AtInn = false

    if IsAddonVisible("RecipeNote") then
        yield("/callback RecipeNote true -1")
    elseif not IsInZone(SolutionNineZoneId) or GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        State = CharacterState.goToSolutionNine
        LogInfo("State Change: Go to Solution Nine")
    elseif GetItemCount(OrangeCrafterScripId) >= 3800 then
        if IsAddonVisible("CollectablesShop") then
            yield("/callback CollectablesShop true -1")
        else
            State = CharacterState.scripExchange
            LogInfo("State Change: ScripExchange")
        end
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Npcs.x, Npcs.y, Npcs.z)
        end
    else
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if not IsAddonVisible("CollectablesShop") then
            yield("/target "..Npcs.turnInNpc)
            yield("/wait 0.5")
            yield("/interact")
            yield("/wait 1")
        elseif GetItemCount(ItemId) == 0 then
            yield("/callback CollectablesShop true -1")
            if GetItemCount(OrangeCrafterScripId) >= 3800 then
                State = CharacterState.scripExchange
                LogInfo("State Change: ScripExchange")
            else
                State = CharacterState.crafting
                LogInfo("State Change: Crafting")
            end
            LogInfo("State Change: Crafting")
        else
            yield("/callback CollectablesShop true 15 0")
            yield("/wait 1")
        end
    end
end

function ScripExchange()
    if GetItemCount(OrangeCrafterScripId) < 3800 then
        if IsAddonVisible("InclusionShop") then
            yield("/callback InclusionShop true -1")
        else
            State = CharacterState.crafting
            LogInfo("State Change: Crafting")
        end
    elseif not IsInZone(SolutionNineZoneId) or GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        State = CharacterState.goToSolutionNine
        LogInfo("State Change: Go to Solution Nine")
    elseif IsAddonVisible("ShopExchangeItemDialog") then
        yield("/callback ShopExchangeItemDialog true 0")
        yield("/wait 1")
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("InclusionShop") then
        -- yield("/callback InclusionShop true 12 1")
        -- yield("/wait 1")
        -- yield("/callback InclusionShop true 13 10")
        -- yield("/wait 1")
        -- yield("/callback InclusionShop true 14 0 "..GetItemCount(OrangeCrafterScripId)//125)
        yield("/callback InclusionShop true 12 2")
        yield("/wait 1")
        yield("/callback InclusionShop true 13 2")
        yield("/wait 1")
        yield("/callback InclusionShop true 14 2 "..GetItemCount(OrangeCrafterScripId)//500)
    else
        yield("/wait 1")
        yield("/target "..Npcs.scripExchangeNpc)
        yield("/wait 0.5")
        yield("/interact")
    end
end

CharacterState =
{
    crafting = Crafting,
    goToSolutionNine = GoToSolutionNine,
    turnIn = TurnIn,
    scripExchange = ScripExchange
}

if GetInventoryFreeSlotCount() > 0 then
    State = CharacterState.crafting
else
    State = CharacterState.turnIn
end
local classId = GetClassJobId()
ItemId = 0
RecipeId = 0
for _, data in ipairs(OrangeScripRecipes) do
    if data.classId == classId then
        ItemId = data.itemId
        RecipeId = data.recipeId
    end
end

AtInn = false
StopFlag = false
ArtisanTimeoutStartTime = 0
while not StopFlag do
    if not (
        IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.beingMoved) or
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        State()
    end
    yield("/wait 0.1")
end