--[[

********************************************************************************
*                                Atma Farming                                  *
*                                Version 1.0.0                                 *
********************************************************************************

Atma farming script meant to be used with `Fate Farming.lua`. This will go down
the list of atma farming zones and farm fates until you have 12 of the required
atmas in your inventory, then teleport to the next zone and restart the fate
farming script.

Created by: pot0to (https://ko-fi.com/pot0to)
        
    -> 1.0.0    First release

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

FateMacro = "Fate Farming"
NumberToFarm = 3                -- How many of each atma to farm

--#endregion Settings

------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
**************************************************************
*  Code: Don't touch this unless you know what you're doing  *
**************************************************************
]]
Atmas =
{
    { zoneName = "Urqopacha", zoneId = 1187, itemName="Azurite Demiatma", itemId=47744 },
    { zoneName = "Kozama'uka", zoneId = 1188, itemName="Verdigris Demiatma", itemId=47745 },
    { zoneName = "Yak T'el", zoneId = 1189, itemName="Malachite Demiatma", itemId=47746 },
    { zoneName = "Shaaloani", zoneId = 1190, itemName="Realgar Demiatma", itemId=47747 },
    { zoneName = "Heritage Found", zoneId = 1191, itemName="Caput Mortuum Demiatma", itemId=47748 },
    { zoneName = "Living Memory", zoneId = 1192, itemName="Orpiment Demiatma", itemId=47749 }
}

CharacterCondition = {
    casting=27,
    betweenAreas=45
}

function GetNextAtmaTable()
    for _, atmaTable in pairs(Atmas) do
        if GetItemCount(atmaTable.itemId) < NumberToFarm then
            return atmaTable
        end
    end
end

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

NextAtmaTable = GetNextAtmaTable()
while NextAtmaTable ~= nil do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        if GetItemCount(NextAtmaTable.itemId) >= NumberToFarm then
            NextAtmaTable = GetNextAtmaTable()
        elseif not IsInZone(NextAtmaTable.zoneId) then
            TeleportTo(GetAetheryteName(GetAetherytesInZone(NextAtmaTable.zoneId)[0]))
        else
            yield("/snd run "..FateMacro)
        end
    end
    yield("/wait 1")
end