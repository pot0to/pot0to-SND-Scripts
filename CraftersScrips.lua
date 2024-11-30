--[[

********************************************************************************
*                 Orange Crafter Scrips (Solution Nine Patch 7.1)              *
*                                Version 0.3.3                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
State Machine Diagram: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/FateFarmingStateMachine.drawio.png

Crafts orange scrip item matching whatever class you're on, turns it in, buys
stuff, repeat.

    -> 0.3.2    Added HQ item count to out of materials check, continue turn in
                    items after dumping scrips
                Fixed up some bugs
                Fixed out of crystals check if recipe only needs one type of
                    crystal, added option to select what you want to buy with
                    scrips
                Added check for ArtisanX crafting
                Fixed some bugs with stop condition
                Stops script when you're out of mats
                Fixed some bugs related to /li inn

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

1. SND
2. Artisan
3. Vnavmesh
4. Optional: Lifestream (for hiding in inn)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************

]]

CrafterClass                = "Carpenter"
ScripColor                  = "Orange"
ArtisanIntermediatesListId  = 42199                     --Id of Artisan list for crafting all the intermediate materials (eg black star, claro walnut lumber, etc.)
ItemToBuy                   = "Crafter's Command Materia XII"
HomeCommand                 = "/li inn"                 --Command you use if you want to hide somewhere. Leave blank to stay in Solution Nine
HubCity                     = "Solution Nine"           --Options:Limsa/Gridania/Ul'dah/Solution Nine. Where to turn in the scrips and access retainer bell

Potion                      = "Superior Spiritbond Potion <hq>"     -- WARNING: This will overwrite any crafter's pots you have.

Retainers                   = true
GrandCompanyTurnIn          = true
MinInventoryFreeSlots       = 1

-- IMPORTANT: Your scrip exchange list may be different depending on whether
-- you've unlocked Skystell tools. Please make sure the menu item #s match what
-- you have in game.
ScripExchangeItems = {
    {
        itemName = "Condensed Solution",
        categoryMenu = 1,
        subcategoryMenu = 10,
        listIndex = 0,
        price = 125
    },
    {
        itemName = "Crafter's Command Materia XII",
        categoryMenu = 2,
        subcategoryMenu = 2,
        listIndex = 2,
        price = 500
    }
}

--#endregion Settings

--[[
********************************************************************************
*            Code: Don't touch this unless you know what you're doing          *
********************************************************************************
]]

OrangeCrafterScripId = 41784
OrangeScripRecipes =
{
    {
        className="Carpenter",
        classId=8,
        itemName="Rarefied Claro Walnut Fishing Rod",
        itemId=44190,
        recipeId=35787
    },
    {
        className="Blacksmith",
        classId=9,
        itemName="Rarefied Ra'Kaznar Round Knife",
        itemId=44196,
        recipeId=35793
    },
    {
        className="Armorer",
        classId=10,
        itemName="Rarefied Ra'Kaznar Ring",
        itemId=44202,
        recipeId=35799
    },
    {
        className="Goldsmith",
        classId=11,
        itemName="Rarefied Black Star Earrings",
        itemId=44208,
        recipeId=35805
    },
    {
        className="Leatherworker",
        classId=12,
        itemName="Rarefied Gargantuaskin Hat",
        itemId=44214,
        recipeId=35817
    },
    {
        className="Weaver",
        classId=13,
        itemName="Rarefied Thunderyard Silk Culottes",
        itemId=44220,
        recipeId=35817
    },
    {
        className="Alchemist",
        classId=14,
        itemName="Rarefied Claro Walnut Flat Brush",
        itemId=44226,
        recipeId=35823
    },
    {
        className="Culinarian",
        classId=15,
        itemName="Rarefied Tacos de Carne Asada",
        itemId=44232,
        recipeId=35829
    }
}

PurpleCrafterScripId = 33913
PurpleScripRecipes =
{
    {
        className="Carpenter",
        classId=8,
        itemName="Rarefied Claro Walnut Grinding Wheel",
        itemId=44189,
        recipeId=35786
    },
    {
        className="Blacksmith",
        classId=9,
        itemName="Rarefied Ra'Kaznar War Scythe",
        itemId=44195,
        recipeId=35792
    },
    {
        className="Armorer",
        classId=10,
        itemName="Rarefied Ra'Kaznar Greaves",
        itemId=44201,
        recipeId=35798
    },
    {
        className="Goldsmith",
        classId=11,
        itemName="Rarefied Ra'Kaznar Orrery",
        itemId=44207,
        recipeId=35804
    },
    {
        className="Leatherworker",
        classId=12,
        itemName="Rarefied Gargantuaskin Trouser",
        itemId=44213,
        recipeId=35816
    },
    {
        className="Weaver",
        classId=13,
        itemName="Rarefied Thunderyards Silk Gloves",
        itemId=44219,
        recipeId=35816
    },
    {
        className="Alchemist",
        classId=14,
        itemName="Rarefied Gemdraught of Vitality",
        itemId=44225,
        recipeId=35822
    },
    {
        className="Culinarian",
        classId=15,
        itemName="Rarefied Stuffed Peppers",
        itemId=44231,
        recipeId=35828
    }
}

HubCities =
{
    {
        zoneName="Limsa",
        zoneId = 129,
        aethernet = {
            aethernetZoneId = 129,
            aethernetName = "Hawkers' Alley",
            x=-213.61108, y=16.739136, z=51.80432
        },
        retainerBell = { x=-123.88806, y=17.990356, z=21.469421, requiresAethernet=false },
        scripExchange = { x=-258.52585, y=16.2, z=40.65883, requiresAethernet=true }
    },
    {
        zoneName="Gridania",
        zoneId = 132,
        aethernet = {
            aethernetZoneId = 133,
            aethernetName = "Leatherworkers' Guild & Shaded Bower",
            x=131.9447, y=4.714966, z=-29.800903
        },
        retainerBell = { x=168.72, y=15.5, z=-100.06, requiresAethernet=true },
        scripExchange = { x=142.15, y=13.74, z=-105.39, requiresAethernet=true },
    },
    {
        zoneName="Ul'dah",
        zoneId = 130,
        aethernet = {
            aethernetZoneId = 131,
            aethernetName = "Sapphire Avenue Exchange",
            x=101, y=9, z=-112
        },
        retainerBell = { x=171, y=15, z=-102, requiresAethernet=true },
        scripExchange = { x=142.68, y=13.75, z=-104.59, requiresAethernet=true },
    },
    {
        zoneName="Solution Nine",
        zoneId = 1186,
        aethernet = {
            aethernetZoneId = 1186,
            aethernetName = "Nexus Arcade",
            x=-161, y=-1, z=21
        },
        retainerBell = { x=-152.465, y=0.660, z=-13.557, requiresAethernet=true },
        scripExchange = { x=-158.019, y=0.922, z=-37.884, requiresAethernet=true }
    }
}

ClassList =
{
    crp = { classId=8, className="Carpenter" },
    bsm = { classId=9, className="Blacksmith" },
    arm = { classId=10, className="Armorer" },
    gsm = { classId=11, className="Goldsmith" },
    ltw = { classId=12, className="Leatherworker" },
    wvr = { classId=13, className="Weaver" },
    alc = { classId=14, className="Alchemist" },
    cul = { classId=15, className="Culinarian"}
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
    occupiedSummoningBell=50,
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
    if crystalsRequired1 ~= nil and crystalsInInventory1 ~= nil and crystalsRequired1 > crystalsInInventory1 then
        return true
    end

    local crystalsRequired2 = tonumber(GetNodeText("RecipeNote", 29, 4))
    local crystalsInInventory2 = tonumber(GetNodeText("RecipeNote", 29, 3))
    if crystalsRequired2 ~= nil and crystalsInInventory2 ~= nil and crystalsRequired2> crystalsInInventory2 then
        return true
    end

    return false
end

function OutOfMaterials()
    for i=0,5 do
        local materialCountNQ = GetNodeText("RecipeNote", 18 + i, 8)
        local materialCountHQ = GetNodeText("RecipeNote", 18 + i, 5)
        local materialRequirement = GetNodeText("RecipeNote", 18 + i, 15)
        if materialCountNQ ~= "" and materialCountHQ ~= "" and materialRequirement ~= "" then
            if tonumber(materialCountNQ) + tonumber(materialCountHQ) < tonumber(materialRequirement) then
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
    if HasPlugin("Lifestream") and LifestreamIsBusy() then
        yield("/wait 1")
        return
    elseif not AtInn and HomeCommand ~= "" then
        yield(HomeCommand)
        while LifestreamIsBusy() do
            yield("/wait 1")
        end
        AtInn = true
        return
    end

    local slots = GetInventoryFreeSlotCount()
    if (ArtisanIsListRunning() and not ArtisanIsListPaused()) or IsAddonVisible("Synthesis") then
        yield("/wait 1")
    elseif slots <= MinInventoryFreeSlots then
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
    elseif not IsAddonVisible("Synthesis") then -- GetCharacterCondition(CharacterCondition.craftingMode) then
        LogInfo("[OrangeCrafters] Attempting to craft "..(slots - MinInventoryFreeSlots).." of recipe #"..RecipeId)
        ArtisanTimeoutStartTime = 0
        ArtisanCraftItem(RecipeId, slots - MinInventoryFreeSlots)
        yield("/wait 5")
    end
end

function GoToHubCity()
    if not IsPlayerAvailable() then
        yield("/wait 1")
    elseif not IsInZone(SelectedHubCity.zoneId) then
        TeleportTo(SelectedHubCity.aetheryte)
    else
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    end
end

function TurnIn()
    AtInn = false

    if GetItemCount(ItemId) == 0 or GetItemCount(CrafterScripId) >= 3800 then
        if IsAddonVisible("CollectablesShop") then
            yield("/callback CollectablesShop true -1")
        else
            State = CharacterState.ready
            LogInfo("State Change: Ready")
        end
    elseif not IsInZone(SelectedHubCity.zoneId) and
        (not SelectedHubCity.scripExchange.requiresAethernet or (SelectedHubCity.scripExchange.requiresAethernet and not IsInZone(SelectedHubCity.aethernet.aethernetZoneId)))
    then
        State = CharacterState.goToHubCity
        LogInfo("State Change: GoToHubCity")
    elseif not LogInfo("Logging 1") and SelectedHubCity.scripExchange.requiresAethernet and not LogInfo("Logging 2") and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or
        GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) + 10) then
        if not LifestreamIsBusy() then
            LogInfo("[OrangeCrafters] /li "..SelectedHubCity.aethernet.aethernetName)
            yield("/li "..SelectedHubCity.aethernet.aethernetName)
        end
        yield("/wait 3")
    elseif IsAddonVisible("TelepotTown") then
        LogInfo("TelepotTown open")
        yield("/callback TelepotTown false -1")
    elseif GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("Path not running")
            PathfindAndMoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
        end
    else
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if not IsAddonVisible("CollectablesShop") then
            yield("/target Collectable Appraiser")
            yield("/wait 0.5")
            yield("/interact")
            yield("/wait 1")
        else
            yield("/callback CollectablesShop true 15 0")
            yield("/wait 1")
        end
    end
end

function ScripExchange()
    if GetItemCount(CrafterScripId) < 3800 then
        if IsAddonVisible("InclusionShop") then
            yield("/callback InclusionShop true -1")
        elseif GetItemCount(ItemId) > 0 then
            State = CharacterState.turnIn
            LogInfo("[OrangeCrafters] State Change: TurnIn")
        else
            State = CharacterState.ready
            LogInfo("[OrangeCrafters] State Change: Ready")
        end
    elseif not IsInZone(SelectedHubCity.zoneId) and
        (not SelectedHubCity.scripExchange.requiresAethernet or (SelectedHubCity.scripExchange.requiresAethernet and not IsInZone(SelectedHubCity.aethernet.aethernetZoneId)))
    then
        State = CharacterState.goToHubCity
        LogInfo("State Change: GoToHubCity")
    elseif SelectedHubCity.scripExchange.requiresAethernet and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or
        GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) + 10) then
        if not LifestreamIsBusy() then
            yield("/li "..SelectedHubCity.aethernet.aethernetName)
        end
        yield("/wait 3")
    elseif IsAddonVisible("TelepotTown") then
        yield("/callback TelepotTown true -1")
    elseif GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("[OrangeCrafters] Path not running")
            PathfindAndMoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
        end
    elseif IsAddonVisible("ShopExchangeItemDialog") then
        yield("/callback ShopExchangeItemDialog true 0")
        yield("/wait 1")
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("InclusionShop") then
        yield("/callback InclusionShop true 12 "..SelectedItemToBuy.categoryMenu)
        yield("/wait 1")
        yield("/callback InclusionShop true 13 "..SelectedItemToBuy.subcategoryMenu)
        yield("/wait 1")
        yield("/callback InclusionShop true 14 "..SelectedItemToBuy.listIndex.." "..GetItemCount(CrafterScripId)//SelectedItemToBuy.price)
    else
        yield("/wait 1")
        yield("/target Scrip Exchange")
        yield("/wait 0.5")
        yield("/interact")
    end
end

function ProcessRetainers()
    CurrentFate = nil
    
    LogInfo("[OrangeCrafters] Handling retainers...")
    if not LogInfo("[OrangeCrafters] check retainers ready") and not ARRetainersWaitingToBeProcessed() or GetInventoryFreeSlotCount() <= 1 then
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    else
        yield("/target Summoning Bell")
        yield("/wait 1")

        if GetTargetName() == "Summoning Bell" then
            if GetDistanceToTarget() > 5 then
                if not PathIsRunning() and not PathfindInProgress() then
                    PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
                end
            else
                if PathIsRunning() or PathfindInProgress() then
                    yield("/vnav stop")
                end
                if not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
                    yield("/interact")
                elseif IsAddonVisible("RetainerList") then
                    yield("/ays e")
                    if Echo == "All" then
                        yield("/echo [OrangeCrafters] Processing retainers")
                    end
                    yield("/wait 1")
                end
            end
        elseif not LogInfo("[OrangeCrafters] is in hub city zone?") and not IsInZone(SelectedHubCity.zoneId) and
            (not SelectedHubCity.scripExchange.requiresAethernet or (SelectedHubCity.scripExchange.requiresAethernet and not IsInZone(SelectedHubCity.aethernet.aethernetZoneId)))
        then
            TeleportTo(SelectedHubCity.aetheryte)
        elseif not LogInfo("[OrangeCrafters] use aethernet?") and
            SelectedHubCity.retainerBell.requiresAethernet and not LogInfo("abc") and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or
            (GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) > (DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) + 10)))
        then
            if not LifestreamIsBusy() then
                yield("/li "..SelectedHubCity.aethernet.aethernetName)
            end
            yield("/wait 3")
        elseif not LogInfo("[OrangeCrafters] close telepot town") and IsAddonVisible("TelepotTown") then
            LogInfo("TelepotTown open")
            yield("/callback TelepotTown false -1")
        elseif not LogInfo("[OrangeCrafters] move to summoning bell") and GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) > 1 then
            if not (PathfindInProgress() or PathIsRunning()) then
                LogInfo("Path not running")
                PathfindAndMoveTo(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z)
            end
        elseif PathfindInProgress() or PathIsRunning() then
            return
        elseif not HasTarget() or GetTargetName() ~= "Summoning Bell" then
            yield("/target Summoning Bell")
            return
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            yield("/interact")
        elseif IsAddonVisible("RetainerList") then
            yield("/ays e")
            if Echo == "All" then
                yield("/echo [FATE] Processing retainers")
            end
            yield("/wait 1")
        end
    end
end

function ExecuteGrandCompanyTurnIn()
    if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        local playerGC = GetPlayerGC()
        local gcZoneIds = {
            129, --Limsa Lominsa
            132, --New Gridania
            130 --"Ul'dah - Steps of Nald"
        }
        if not IsInZone(gcZoneIds[playerGC]) then
            yield("/li gc")
            yield("/wait 1")
        elseif DeliverooIsTurnInRunning() then
            return
        else
            yield("/deliveroo enable")
        end
    else
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    end
end

function PotionCheck()
    --pot usage
    if not HasStatusId(49) and Potion ~= "" then
        yield("/item " .. Potion)
    end
end

function Ready()
    PotionCheck()

    if not IsPlayerAvailable() then
        -- do nothing
    elseif Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1
    then
        State = CharacterState.retainers
        LogInfo("[OrangeCrafters] State Change: ProcessingRetainers")
    elseif GetItemCount(CrafterScripId) >= 3800 then
        State = CharacterState.scripExchange
        LogInfo("[OrangeCrafters] State Change: ScripExchange")
    elseif GetInventoryFreeSlotCount() <= MinInventoryFreeSlots and GetItemCount(ItemId) > 0 then
        State = CharacterState.turnIn
        LogInfo("State Change: TurnIn")
    elseif not LogInfo("[OrangeCrafters] Ready -> GC TurnIn") and GrandCompanyTurnIn and
        GetInventoryFreeSlotCount() <= MinInventoryFreeSlots
    then
        State = CharacterState.gcTurnIn
        LogInfo("[OrangeCrafters] State Change: GCTurnIn")
    else
        State = CharacterState.crafting
        LogInfo("[OrangeCrafters] State Change: Crafting")
    end
end

CharacterState =
{
    ready = Ready,
    crafting = Crafting,
    goToHubCity = GoToHubCity,
    turnIn = TurnIn,
    scripExchange = ScripExchange,
    retainers = ProcessRetainers,
    gcTurnIn = ExecuteGrandCompanyTurnIn
}

State = CharacterState.ready
local classId = 0
for _, class in pairs(ClassList) do
    if CrafterClass == class.className then
        classId = class.classId
    end
end
if classId == 0 then
    yield("/echo Could not find crafter class: "..CrafterClass)
    yield("/snd stop")
end

if ScripColor == "Orange" then
    CrafterScripId = OrangeCrafterScripId
    ScripRecipes = OrangeScripRecipes
elseif ScripColor == "Purple" then
    CrafterScripId = PurpleScripRecipes
    ScripRecipes = PurpleScripRecipes
else
    yield("/echo Cannot recognize crafter scrip color: "..ScripColor)
    yield("/snd stop")
end
ItemId = 0
RecipeId = 0
for _, data in ipairs(ScripRecipes) do
    if data.classId == classId then
        ItemId = data.itemId
        RecipeId = data.recipeId
    end
end

for _, item in ipairs(ScripExchangeItems) do
    if item.itemName == ItemToBuy then
        SelectedItemToBuy = item
    end
end
if SelectedItemToBuy == nil then
    yield("/echo Could not find "..ItemToBuy.." on the list of scrip exchange items.")
    StopFlag = true
end

for _, city in ipairs(HubCities) do
    if city.zoneName == HubCity then
        SelectedHubCity = city
        SelectedHubCity.aetheryte = GetAetheryteName(GetAetherytesInZone(city.zoneId)[0])
    end
end
if SelectedHubCity == nil then
    yield("/echo Could not find hub city: "..HubCity)
    yield("/vnav stop")
end

AtInn = false
StopFlag = false
ArtisanTimeoutStartTime = 0
LogInfo("[OrangeCrafters] Start")
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