--[[

********************************************************************************
*                            Treasure Hunt Helper                              *
********************************************************************************

You must start with an open map in your inventory. This script will
automatically teleport you to the correct zone, fly over, dig, kill enemies,
and open the chest. It will NOT do portals for you.

********************************************************************************
*                               Version 1.1.2                                  *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
    ->  1.1.2   Added Lifestream or Teleporter option
    ->  1.1.1   Fixed some wait times related to Dravanian Hinterland tp
                Added ability to go to Dravanian Hinterlands via Idyllshire
                First release

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : Main Plugin for everything to work   (https://puni.sh/api/repository/croizat)
    -> Globetrotter :               For finding the treasure map spot
    -> VNavmesh :                   For Pathing/Moving    (https://puni.sh/api/repository/veyn)
    -> RSR :                        For fighting things
    -> Teleporter OR Lifestream :   For teleporting

]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupied31=31,
    occupied=33,
    boundByDuty34=34,
    betweenAreas=45,
    jumping48=48,
    betweenAreas51=51,
    jumping61=61,
    mounting57=57,
    mounting64=64,
    beingmoved70=70,
    beingmoved75=75,
    flying=77
}

-- #region Movement

function TeleportTo(aetheryteName)
    if HasPlugin("Lifestream") then
        yield("/li tp "..aetheryteName)
    else
        yield("/tp "..aetheryteName)
    end
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[TreasureHuntHelper] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while not IsPlayerAvailable() or GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.betweenAreas51) do
        LogInfo("[TreasureHuntHelper] Teleporting...")
        yield("/wait 1")
    end
    LogInfo("[TreasureHuntHelper] Finished teleporting")
    yield("/wait 1")
end

function TeleportToFlag()
    local aetheryteName = GetAetheryteName(GetAetherytesInZone(GetFlagZone())[0])
    TeleportTo(aetheryteName)
end

function GoToMapLocation()
    local flagZone = GetFlagZone()
    if not IsInZone(flagZone) then
        if flagZone == 399 then
            if not IsInZone(478) then
                TeleportTo("Idyllshire")
            else
                if GetTargetName() ~= "aetheryte" then
                    yield("/target aetheryte")
                end
                if GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 7 then
                    if not PathIsRunning() and not PathfindInProgress() then
                        PathfindAndMoveTo(71, 211, -19)
                    end
                else
                    yield("/vnav stop")
                    yield("/li Western Hinterlands")
                    yield("/wait 3")
                    while LifestreamIsBusy() do
                        yield("/wait 1")
                    end
                    yield("/wait 3")
                    while GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.betweenAreas51) do
                        LogInfo("[TreasureHuntHelper] Between areas...")
                        yield("/wait 1")
                    end
                    yield("/wait 1")
                end
            end
        else
            TeleportToFlag()
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        yield('/gaction "mount roulette"')
        yield("/wait 1")
        repeat
            yield("/wait 1")
        until not GetCharacterCondition(CharacterCondition.casting)
        yield("/wait 1")
        repeat
            yield("/wait 1")
        until not GetCharacterCondition(CharacterCondition.jumping48)
        yield("/wait 3")
        LogInfo("[TreasureHuntHelper] Finished mounting.")
        return
    end
    
    if not PathfindInProgress() and not PathIsRunning() then
        yield("/vnav flyflag")
        yield("/wait 10")
    else
        yield("/wait 3")
    end
end

--#endregion  Movement

DidMap = false
function Main()
    if IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "You do not possess a treasure map." and not GetCharacterCondition(CharacterCondition.boundByDuty34) then
        yield("/echo You do not possess a treasure map.")
        StopFlag = true
        return
    end

    if GetCharacterCondition(CharacterCondition.inCombat) and not HasTarget() then
        yield("/battletarget")
        return
    elseif DidMap and not GetCharacterCondition(CharacterCondition.boundByDuty34) and not GetCharacterCondition(CharacterCondition.inCombat) then -- if combat is over
        StopFlag = true
        return
    end

    yield("/wait 1")
    yield("/tmap")
    yield("/wait 1")
    repeat
        yield("/wait 1")
    until IsAddonVisible("AreaMap")

    if not IsInZone(GetFlagZone()) or GetDistanceToPoint(GetFlagXCoord(), GetPlayerRawYPos(), GetFlagYCoord()) > 15 then
        GoToMapLocation()
        return
    elseif PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        yield("/ac dismount")
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end
        yield("/wait 1")
        return
    end

    if not GetCharacterCondition(CharacterCondition.inCombat) and (not HasTarget() or GetTargetName() ~= "Treasure Coffer") then
        yield("/generalaction Dig")
        yield("/target Treasure Coffer")
        return
    end

    if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) > 3.5 then
        PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/echo see yesno")
        yield("/callback SelectYesno true 0") -- yes open the coffer
        HasOpenMap = false
    end

    if not GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/interact")
        return
    end

    if GetCharacterCondition(CharacterCondition.boundByDuty34) then
        LogInfo("[TreasureHuntHelper] DidMap = true")
        DidMap = true
    end
    
    yield("/rotation manual")
    yield("/battletarget")
end

HasOpenMap = true
StopFlag = false
repeat
    if not (IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.jumping48) or
        GetCharacterCondition(CharacterCondition.betweenAreas51) or
        GetCharacterCondition(CharacterCondition.jumping61) or
        GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        GetCharacterCondition(CharacterCondition.beingmoved70) or
        GetCharacterCondition(CharacterCondition.beingmoved75) or
        LifestreamIsBusy())
    then
        Main()
        yield("/wait 1")
    end
until StopFlag