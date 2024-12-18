--[[

********************************************************************************
*                            Firmament Craft All                               *
*                               Version 1.0.0                                  *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

This script will teleport you to the firmament, switch to each crafter class and
run FirmamentCrafting.lua for each of those classes. You will need
FirmamentCrafting.lua in order for this to work.

********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

MacroName = "Craft Skybuilders' Items"      -- this is what you named the FirmamentCrafting.lua script in SND

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

Classes = {
    "Carpenter",
    "Blacksmith",
    "Armorer",
    "Goldsmith",
    "Leatherworker",
    "Weaver",
    "Alcemist",
    "Culinarian"
}

CharacterCondition = {
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    betweenAreas=45,
    beingMoved=70
}

FoundationZoneId = 418
FirmamentZoneId = 886
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

if not (IsInZone(FoundationZoneId) or IsInZone(FirmamentZoneId)) then
    TeleportTo("Foundation")
end
if IsInZone(FoundationZoneId) then
    yield("/target aetheryte")
    yield("/wait 1")
    if GetTargetName() == "aetheryte" then
        yield("/interact")
    end
    repeat
        yield("/wait 1")
    until IsAddonVisible("SelectString")
    yield("/callback SelectString true 2")
    repeat
        yield("/wait 1")
    until IsInZone(FirmamentZoneId) and not GetCharacterCondition(CharacterCondition.betweenAreas)
end

for _, class in ipairs(Classes) do
    yield("/echo Crafting for "..class)
    yield("/gs change "..class)
    yield("/wait 5")

    yield("/snd run "..MacroName)
    repeat
        yield("/wait 5")
    until not IsMacroRunningOrQueued(MacroName)

    repeat
        yield("/callback RecipeNote true -1")
        yield("/wait 1")
    until not IsAddonVisible("RecipeNote")
end