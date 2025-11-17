Prefix = "QST Helper"

luanet.load_assembly("Dalamud")
ConditionFlag = luanet.import_type("Dalamud.Game.ClientState.Conditions.ConditionFlag")

function DistanceBetween(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function GetAetherytesInZone(zoneId)
    local aetherytesInZone = {}
    for _, aetheryte in ipairs(Svc.AetheryteList) do
        if aetheryte.TerritoryId == zoneId then
            table.insert(aetherytesInZone, aetheryte)
        end
    end
    return aetherytesInZone
end

function GetClosestAetheryte(zoneId, position, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    local aetherytes = GetAetherytesInZone(zoneId)
    for _, aetheryteRow in ipairs(aetherytes) do
        local aetheryte = {
            aetheryteName = GetAetheryteName(aetheryteRow),
            aetheryteId = aetheryteRow.AetheryteId,
            position = Instances.Telepo:GetAetherytePosition(aetheryteRow.AetheryteId)
        }
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, position)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        Dalamud.Log("["..Prefix.."] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            Dalamud.Log("["..Prefix.."] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end
    if closestAetheryte ~= nil then
        Dalamud.Log("["..Prefix.."] Final selected aetheryte is: "..closestAetheryte.aetheryteName)
    else
        Dalamud.Log("["..Prefix.."] Closest aetheryte is nil")
    end

    return closestAetheryte
end

function GetAetheryteName(aetheryte)
    local name = aetheryte.AetheryteData.Value.PlaceName.Value.Name:GetText()
    if name == nil then
        return ""
    else
        return name
    end
end

function OnConditionChange()
    if TriggerData.flag == ConditionFlag.InCombat or ConditionFlag.RolePlaying then -- and (Player.Entity.Target == nil or not Player.Entity.Target.IsInCombat) then
        if TriggerData.value then
            TurnOnCombatTriggered = true
        else
            TurnOffCombatTriggered = false
        end
    elseif TriggerData.flag == ConditionFlag.Unconscious then
        if TriggerData.value then
            UnconsciousTriggered = true
        end
    end
end

Conditions =
{
    [26] = ConditionFlag.InCombat,
    [34] = ConditionFlag.BoundByDuty,
    [90] = ConditionFlag.RolePlaying
}

function HasCondition(cond)
    for i, condition in pairs(Conditions) do
        if cond == condition then
            return Svc.Condition[i]
        end
    end
    yield("/echo Could not find condition: "..tostring(cond))
end

TurnOnCombatTriggered = false
TurnOffCombatTriggered = false
StartAttempts = 0
LastRecordedPosition = Player.Entity.Position
StuckCheckTimer = 20
yield("/at y")
while true do
    if Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
    elseif Addons.GetAddon("DifficultySelectYesNo").Ready then
        yield("/callback DifficultySelectYesNo true 0 2")
    elseif TurnOnCombatTriggered then
        yield("/rsr manual")
        yield("/bmrai on")
        TurnOnCombatTriggered = false
    elseif TurnOffCombatTriggered then
        yield("/rsr off")
        yield("/bmrai off")
        TurnOffCombatTriggered = false
    elseif HasCondition(ConditionFlag.InCombat) or HasCondition(ConditionFlag.RolePlaying) or HasCondition(ConditionFlag.BoundByDuty) then
        if Player.Entity.Target == nil or not Player.Entity.Target.IsInCombat then
            yield("/battletarget")
        end
    elseif not IPC.Questionable.IsRunning() then
        local qstStepData = IPC.Questionable.GetCurrentStepData()
        if StartAttempts >= 3 then
            yield("/qst reload")
            yield("/wait 5")
        elseif qstStepData ~= nil then
            local targetTerritory = qstStepData.TerritoryId
            if Svc.ClientState.TerritoryType ~= targetTerritory then
                local targetPos = qstStepData.Position
                local closestAetheryte = GetClosestAetheryte(targetTerritory, targetPos, 0)
                if closestAetheryte ~= nil then
                    yield("/li tp "..closestAetheryte.aetheryteName)
                    yield("/wait 10")
                else
                    yield("/echo ["..Prefix.."] Cannot find aetheryte to get to next area: #"..tostring(targetTerritory))
                    yield("/snd stop")
                end
            else
                yield("/qst start")
                yield("/wait 5")
                StartAttempts = StartAttempts + 1
            end
        else
            yield("/qst reload")
            StartAttempts = 0
            yield("/wait 5")
        end
    else
        yield("/wait "..tostring(StuckCheckTimer))
        if Player.Entity.Position == LastRecordedPosition and not HasCondition(ConditionFlag.BoundByDuty) then
            Dalamud.Log("["..Prefix.."] Stuck for over "..tostring(StuckCheckTimer).."s")
            yield("/qst stop")
        else
            LastRecordedPosition = Player.Entity.Position
        end
        StartAttempts = 0
    end
    yield("/wait 1")
end