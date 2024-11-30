CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupied31=31,
    occupiedShopkeeper=32,
    occupied=33,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    occupiedSummoningBell=50,
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
        yield("/interact")
        if not HasOpenMap then
            yield("/echo stopflag true")
            StopFlag = true
        end
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
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        Main()
        yield("/wait 0.1")
    end
until StopFlag