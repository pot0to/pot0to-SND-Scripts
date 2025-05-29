--[[

********************************************************************************
*                        Anima Luminous Crystal Farming                        *
*                                Version 1.0.1                                 *
********************************************************************************

Anima luminous crystal farming script meant to be used with `Fate Farming.lua`.
This will go down the list of zones and farm fates until you have enough of the
required crystals in your inventory, then teleport to the next zone and restart
the fate farming script.

Created by: pot0to (https://ko-fi.com/pot0to)
        
    -> 1.0.1    Added mounted character condition
                First release

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

FateMacro = "Fate Farming"
NumberToFarm = 1                -- How many of each atma to farm

--#endregion Settings

------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
**************************************************************
*  Code: Don't touch this unless you know what you're doing  *
**************************************************************
]]
Atmas =
{
    {zoneName = "Coerthas Western Highlands", zoneId = 397, itemName = "Luminous Ice Crystal", itemId = 13569},
    {zoneName = "The Dravanian Forelands", zoneId = 398, itemName = "Luminous Earth Crystal", itemId = 13572},
    {zoneName = "The Dravanian Hinterlands", zoneId = 399, itemName = "Luminous Water Crystal", itemId = 13574},
    {zoneName = "The Churning Mists", zoneId = 400, itemName = "Luminous Lightning Crystal", itemId = 13573},
    {zoneName = "Sea of Clouds", zoneId = 401, itemName = "Luminous Wind Crystal", itemId = 13570},
    {zoneName = "Azys Lla", zoneId = 402, itemName = "Luminous Fire Crystal", itemId = 13571}
}

CharacterCondition = {
    mounted=4,
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

function GoToDravanianHinterlands()
    if GetCharacterCondition(CharacterCondition.betweenAreas) then
        return
    elseif IsInZone(478) then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.mounting
            LogInfo("[DailyHunts] State Change: Mounting")
        elseif not PathIsRunning() and not PathfindInProgress() then
            PathfindAndMoveTo(148.51, 207.0, 118.47)
        end
    else
        TeleportTo("Idyllshire")
    end
end

yield("/at y")
NextAtmaTable = GetNextAtmaTable()
while NextAtmaTable ~= nil do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        if GetItemCount(NextAtmaTable.itemId) >= NumberToFarm then
            NextAtmaTable = GetNextAtmaTable()
        elseif not IsInZone(NextAtmaTable.zoneId) then
            if NextAtmaTable.zoneId == 399 then
                GoToDravanianHinterlands()
            else
                TeleportTo(GetAetheryteName(GetAetherytesInZone(NextAtmaTable.zoneId)[0]))
            end
        else
            yield("/snd run "..FateMacro)
        end
    end
    yield("/wait 1")
end