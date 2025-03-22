--[[
********************************************************************************
*                   Dump Poetics - Buy Grade 3 Thanalan Topsoil                *
*                                Version 0.2.1                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Description: Checks if you have at least 1800 Allagan Tomestones of Poetics and 
dumps them on Grade 3 Thanalan Topsoil. You can later use this soil for
gardening or sell it for a decent price on the marketboard.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. vnavmesh
2. Teleporter
3. TextAdvance

********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]


PoeticsItemId = 28
OreItemId = 13586
IdyllshireTurnIn =
{
    x=-12.3, y=211.0, z=-40.85,
    price = 150,
    oreNpc = "Hismena",
    turnInNpc = "Bertana"
}

function Teleport(aetheryteName)
    yield("/tp "..aetheryteName)
    while not GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait 0.1")
    end
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait 0.1")
    end
    LogInfo("[Poetics Dump - Unidenfiable Ore] Finished Teleport")
end

function GoToIdyllshireTurnIn()
    if not IsInZone(478) then
        Teleport("Idyllshire")
    elseif GetDistanceToPoint(IdyllshireTurnIn.x, IdyllshireTurnIn.y, IdyllshireTurnIn.z) > 5 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            yield('/gaction "mount roulette"')
            yield("/wait 1")
        elseif not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(IdyllshireTurnIn.x, IdyllshireTurnIn.y, IdyllshireTurnIn.z)
        end
    else
        State = CharacterState.buyUnidentifiableOre
    end
end

function BuyUnidentifiableOre()
    local poetics = GetItemCount(PoeticsItemId)
    if poetics < IdyllshireTurnIn.price then
        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency true -1")
        else
            State = CharacterState.turnIn
        end
        return
    end

    GoToIdyllshireTurnIn()

    if GetTargetName() ~= IdyllshireTurnIn.oreNpc then
        yield("/target "..IdyllshireTurnIn.oreNpc)
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 6")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("ShopExchangeCurrency") then
        yield("/callback ShopExchangeCurrency true 0 7 "..(poetics//IdyllshireTurnIn.price).." 0")
    else
        yield("/interact")
    end
end

function TurnIn()
    local ore = GetItemCount(OreItemId)
    if ore == 0 then
        if IsAddonVisible("ShopExchangeItem") then
            yield("/callback ShopExchangeItem true -1")
        else
            StopFlag = true
        end
        return
    end

    GoToIdyllshireTurnIn()

    if GetTargetName() ~= IdyllshireTurnIn.turnInNpc then
        yield("/target "..IdyllshireTurnIn.turnInNpc)
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 5")
    elseif IsAddonVisible("ShopExchangeItemDialog") then
        yield("/callback ShopExchangeItemDialog true 0")
    elseif IsAddonVisible("ShopExchangeItem") then
        yield("/callback ShopExchangeItem true 0 1 "..ore.." 0")
    else
        yield("/interact")
    end
end

function Ready()
    if GetItemCount(PoeticsItemId) > 1800 or GetItemCount(OreItemId) > 0 then
        State = CharacterState.goToIdyllshireTurnIn
    else
        StopFlag = true
    end
end

CharacterCondition = {
    mounted=4,
    gathering=6,
    inCombat=26,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDuty=34,
    occupiedMateriaExtractionAndRepair=39,
    gathering42=42,
    fishing=43,
    betweenAreas=45,
    jumping48=48,
    jumpPlatform=61,
    betweenAreas51=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

CharacterState =
{
    ready = Ready,
    goToIdyllshireTurnIn = GoToIdyllshireTurnIn,
    buyUnidentifiableOre = BuyUnidentifiableOre,
    turnIn = TurnIn
}

yield("/at y")
State = CharacterState.ready
StopFlag = false
while not StopFlag do
    State()
    yield("/wait 0.1")
end