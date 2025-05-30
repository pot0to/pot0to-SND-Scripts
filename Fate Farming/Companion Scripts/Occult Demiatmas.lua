--[[

********************************************************************************
*                          Occult Demiatma Farming                             *
*                                Version 1.0.2                                 *
********************************************************************************

Atma farming script meant to be used with `Fate Farming.lua`. This will go down
the list of atma farming zones and farm fates until you have 12 of the required
atmas in your inventory, then teleport to the next zone and restart the fate
farming script.

Created by: pot0to (https://ko-fi.com/pot0to)
    
    -> 1.0.2    Added a 10s wait if you go through all zones without a FATE,
                    meant to prevent you from burning gil on teleports
    -> 1.0.1    Added ability to move to next zone if no eligible fates
    -> 1.0.0    First release

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

FateMacro =             "Fate Farming"
NumberToFarm =          3               -- How many of each atma to farm
WaitTimeBeforeLooping = 10              -- If there are no active fates in any of your areas, wait X seconds before looping through them again

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

FarmingZoneIndex = 1
FullPass = true
DidFateOnPass = false
function GetNextAtmaTable()
    -- ffwd to next zone index, or end of list
    while FarmingZoneIndex <= #Atmas and GetItemCount(Atmas[FarmingZoneIndex].itemId) >= NumberToFarm do
        FarmingZoneIndex = FarmingZoneIndex + 1
    end

    if FarmingZoneIndex <= #Atmas then
        FullPass = false
        return Atmas[FarmingZoneIndex]
    elseif FullPass then
        return nil
    else
        if not DidFateOnPass then
            yield("/wait "..WaitTimeBeforeLooping)
            yield("/echo Went through all zones without a FATE. Waiting "..WaitTimeBeforeLooping.." seconds before going through the zones again.")
        end
        FarmingZoneIndex = 1
        FullPass = true
        DidFateOnPass = false
        return GetNextAtmaTable()   --second run it either finds something, or
                                    --hits the end with FullPass-true
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

yield("/at y")
OldBicolorGemCount = GetItemCount(26807)
NextAtmaTable = GetNextAtmaTable()
while NextAtmaTable ~= nil do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        if GetItemCount(NextAtmaTable.itemId) >= NumberToFarm then
            NextAtmaTable = GetNextAtmaTable()
        elseif not IsInZone(NextAtmaTable.zoneId) then
            TeleportTo(GetAetheryteName(GetAetherytesInZone(NextAtmaTable.zoneId)[0]))
        else
            yield("/snd run "..FateMacro)

            repeat
                yield("/wait 1")
            until not IsMacroRunningOrQueued(FateMacro)
            LogInfo("[DemiatmaFarmer] FateMacro has stopped")
            NewBicolorGemCount = GetItemCount(26807)
            -- yield("/echo Bicolor Count: "..NewBicolorGemCount)
            if NewBicolorGemCount == OldBicolorGemCount then
                FarmingZoneIndex  = FarmingZoneIndex + 1
                NextAtmaTable = GetNextAtmaTable()
            else
                DidFateOnPass = true
                OldBicolorGemCount = NewBicolorGemCount
            end
        end
    end
    yield("/wait 1")
end