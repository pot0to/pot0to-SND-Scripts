--[[

********************************************************************************
*                            Treasure Hunt Helper                              *
********************************************************************************

You must start with an open map in your inventory. This script will
automatically teleport you to the correct zone, fly over, dig, kill enemies,
and open the chest. It will NOT do portals for you.

********************************************************************************
*                               Version 1.0.0                                  *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
        
    ->  1.0.0   First release

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : Main Plugin for everything to work   (https://puni.sh/api/repository/croizat)
    -> Globetrotter :   For finding the treasure map spot
    -> VNavmesh :       For Pathing/Moving    (https://puni.sh/api/repository/veyn)
    -> RSR :            For fighting things

********************************************************************************
*                                Optional Plugins                              *
********************************************************************************

This Plugins are optional and not needed unless you have it enabled in the settings:

    -> Teleporter :  (for Teleporting to Ishgard/Firmament if you're not already in that zone)

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
    jumping61=61,
    mounting57=57,
    mounting64=64,
    beingmoved70=70,
    beingmoved75=75,
    flying=77
}

-- #region Movement

function TeleportToFlag()
    yield("/tp " .. GetAetheryteName(GetAetherytesInZone(GetFlagZone())[0]))
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

function GoToMapLocation()
    if PathfindInProgress() or PathIsRunning() then
        return
    end

    if not IsInZone(GetFlagZone()) then
        TeleportToFlag()
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        yield('/gaction "mount roulette"')
        return
    end
    
    yield("/vnav flyflag")
end

--#endregion  Movement

function Main()
    if GetCharacterCondition(CharacterCondition.inCombat) and not HasTarget() then
        yield("/battletarget")
        return
    end

    yield("/tmap")

    if not IsInZone(GetFlagZone()) or GetDistanceToPoint(GetFlagXCoord(), GetPlayerRawYPos(), GetFlagYCoord()) > 5 then
        GoToMapLocation()
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
        if GetCharacterCondition(CharacterCondition.boundByDuty34) then
            StopFlag = true
        end
        yield("/interact")
        return
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
        GetCharacterCondition(CharacterCondition.jumping61) or
        GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        GetCharacterCondition(CharacterCondition.beingmoved70) or
        GetCharacterCondition(CharacterCondition.beingmoved75) or
        LifestreamIsBusy())
    then
        Main()
        yield("/wait 0.1")
    end
until StopFlag