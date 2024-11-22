--[[

********************************************************************************
*                 Orange Crafter Scrips (Solution Nine Patch 7.1)              *
*                                Version 0.0.0                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
State Machine Diagram: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/FateFarmingStateMachine.drawio.png

Crafts orange scrip item matching whatever class you're on, turns it in, buys
Condensed Solution, repeat.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat
    -> Artisan

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

ArtisanIntermediatesListId = "42199"

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

local Npcs =
{
    turnInNpc = "Collectable Appraiser",
    scripExchangeNpc = "Scrip Exchange",
    x=-157.96, y=0.92, z=-38.06
}

CharacterCondition =
{
    craftingMode = 5,
    occupiedInQuestEvent=32,
    executingCraftingSkill = 40,
    craftingModeIdle = 41
}

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
    return false
end

function Crafting()
    local slots = GetInventoryFreeSlotCount()
    if ArtisanIsListRunning() then
        yield("/wait 1")
    elseif slots == 0 then
        if IsAddonVisible("RecipeNote") then
            yield("/callback RecipeNote true -1")
        elseif not GetCharacterCondition(CharacterCondition.craftingMode) then
            yield("/echo no inventory slots left, not in crafting mode")
            State = CharacterState.turnIn
            LogInfo("State Change: TurnIn")
        end
    elseif IsAddonVisible("RecipeNote") and OutOfMaterials() then
        yield("/echo out of materials")
        if GetItemCount(ItemId) == 0 then
            yield("/echo crafting intermediates")
            yield("/artisan lists "..ArtisanIntermediatesListId.." start")
        elseif not GetCharacterCondition(CharacterCondition.craftingMode) then
            yield("/echo out of materials, turnin")
            yield("/callback RecipeNote true -1")
            State = CharacterState.turnIn
            LogInfo("State Change: TurnIn")
        end
    elseif not GetCharacterCondition(CharacterCondition.craftingMode) then
        yield("/e not in crafting mode")
        ArtisanCraftItem(RecipeId, slots)
        yield("/echo recipeid: "..RecipeId)
        yield("/wait 5")
    end
end

function TurnIn()
    if IsAddonVisible("RecipeNote") then
        yield("/callback RecipeNote true -1")
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
    if GetItemCount(OrangeCrafterScripId) < 125 then
        if IsAddonVisible("InclusionShop") then
            yield("/callback InclusionShop true -1")
        else
            State = CharacterState.crafting
            LogInfo("State Change: Crafting")
        end
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Npcs.x, Npcs.y, Npcs.z)
        end
    elseif IsAddonVisible("ShopExchangeItemDialog") then
        yield("/callback ShopExchangeItemDialog true 0")
        yield("/wait 1")
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("InclusionShop") then
        yield("/callback InclusionShop true 12 1")
        yield("/wait 1")
        yield("/callback InclusionShop true 13 10")
        yield("/wait 1")
        yield("/callback InclusionShop true 14 0 "..GetItemCount(OrangeCrafterScripId)//125)
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
    turnIn = TurnIn,
    scripExchange = ScripExchange
}

State = CharacterState.crafting
local classId = GetClassJobId()
ItemId = 0
RecipeId = 0
for _, data in ipairs(OrangeScripRecipes) do
    if data.classId == classId then
        ItemId = data.itemId
        RecipeId = data.recipeId
    end
end
while true do
    State()
    yield("/wait 0.1")
end
