--[[

********************************************************************************
*                           Any Way the Wind Blows                             *
*                                Version 1.0.0                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Plays the Gold Saucer minigame "Any Way the Wind Blows". There's a special spot
on the stage that is statistically less likely to get hit based on the aoe
patterns (though never guaranteed to win). This script will AFK in front of
where the NPC will spawn, talk to him to enter the minigame, place you at the
special spot for 5min (long enough for to finish the minigame), then repeat.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

1. SND
2. Vnavmesh
3. Teleporter
4. TextAdvance

********************************************************************************
*            Code: Don't touch this unless you know what you're doing          *
********************************************************************************
]]

Npc =
{
    x=77, y=-6, z=-70,
    name="Supercilious Spellweaver"
}

OnStage = false
function Main()
    if OnStage then
        PathfindAndMoveTo(67.01, -4.48, -24.57)
        yield("/wait "..5*60)
        OnStage = false
        return
    end

    if GetDistanceToPoint(Npc.x, Npc.y, Npc.z) > 7 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Npc.x, Npc.y, Npc.z)
        end
        return
    elseif PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetTargetName() ~= Npc.name then
        yield("/target "..Npc.name)
        yield("/wait 0.5")
        if GetTargetName() ~= Npc.name then
            yield("/wait 30")
        else
            yield("/echo Found "..Npc.name.."! Starting GATE!")
        end
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/wait 1")
        yield("/callback SelectYesno true 0")
        yield("/wait 10")
        OnStage = true
        return
    end

    yield("/interact")
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

CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDuty34=34,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

yield("/at y")
if not IsInZone(144) then
    TeleportTo("Gold Saucer")
end
while true do
    Main()
    yield("/wait 0.1")
end