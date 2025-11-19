Prefix = "QST Helper"

luanet.load_assembly("Dalamud")
ConditionFlag = luanet.import_type("Dalamud.Game.ClientState.Conditions.ConditionFlag")
import("System.Numerics")

Conditions =
{
    [4] = ConditionFlag.Mounted,
    [26] = ConditionFlag.InCombat,
    [32] = ConditionFlag.OccupiedInQuestEvent,
    [34] = ConditionFlag.BoundByDuty,
    [35] = ConditionFlag.OccupiedInCutSceneEvent,
    [39] = ConditionFlag.Occupied39, -- materia extraction & repair
    [77] = ConditionFlag.InFlight,
    [90] = ConditionFlag.RolePlaying
}

RetainerBells =
{
    { aetheryteName = "Limsa Lominsa", zoneId = 1, position = Vector3(1, 1, 1) }
}

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
            State = CharacterState.death
        end
    elseif TriggerData.flag == ConditionFlag.BoundByDuty then
        if not TriggerData.value then
            ExitedDuty = true
        end
    end
end

function HasCondition(cond)
    for i, condition in pairs(Conditions) do
        if cond == condition then
            return Svc.Condition[i]
        end
    end
    yield("/echo Could not find condition: "..tostring(cond))
    return false
end

function TeleportTo(aetheryteName)
    yield("/li tp "..aetheryteName)
    yield("/wait 1")
    while HasCondition(ConditionFlag.Casting) do
        Dalamud.Log("["..Prefix.."] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1")
    while HasCondition(ConditionFlag.BetweenAreas) do
        Dalamud.Log("["..Prefix.."] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
end

function DistanceBetween(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function GetDistanceToPoint(vec3)
    return DistanceBetween(Svc.ClientState.LocalPlayer.Position, vec3)
end

function RandomAdjustCoordinates(position, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = position.X + (x_adjust * math.cos(angle))
    local randomY = position.Y + maxDistance
    local randomZ = position.Z + (z_adjust * math.sin(angle))

    return Vector3(randomX, randomY, randomZ)
end

function Dismount()
    yield("/echo dismount")
    if HasCondition(ConditionFlag.InFlight) then
        yield('/ac dismount')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then

            if HasCondition(ConditionFlag.InFlight) and GetDistanceToPoint(LastStuckCheckPosition) < 2 then
                Dalamud.Log("["..Prefix.."] Unable to dismount here. Moving to another spot.")
                local random = RandomAdjustCoordinates(Svc.ClientState.LocalPlayer.Position, 10)
                local nearestFloor = IPC.vnavmesh.PointOnFloor(random, true, 100)
                if nearestFloor ~= nil then
                    IPC.vnavmesh.PathfindAndMoveTo(nearestFloor, HasCondition(ConditionFlag.InFlight) and Player.CanFly)
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
        end
    elseif HasCondition(ConditionFlag.Mounted) then
        yield('/ac dismount')
    end
end

function Questing()
    if Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
    elseif HasCondition(ConditionFlag.OccupiedInCutSceneEvent) then
        LastRecordedPosition = Player.Entity.Position
        LastRecordedTimestamp = os.time()
    elseif IPC.AutoRetainer.IsBusy() or not IPC.vnavmesh.IsReady() or IPC.vnavmesh.PathfindInProgress() then
        -- wait for autoretainer to finish
    elseif Addons.GetAddon("DifficultySelectYesNo").Ready then
        yield("/callback DifficultySelectYesNo true 0 2")
    elseif TurnOnCombatTriggered then
        if HasCondition(ConditionFlag.RolePlaying) or HasCondition(ConditionFlag.BoundByDuty) then
            yield("/rsr auto on")
        else
            yield("/rsr manual")
        end
        yield("/bmrai on")
        TurnOnCombatTriggered = false
    elseif TurnOffCombatTriggered then
        yield("/rsr off")
        yield("/bmrai off")
        TurnOffCombatTriggered = false
    elseif ExitedDuty then
        yield("/qst start")
        ExitedDuty = false
    elseif HasCondition(ConditionFlag.InCombat) or HasCondition(ConditionFlag.RolePlaying) or HasCondition(ConditionFlag.BoundByDuty) then
        if Player.Entity.Target == nil or not Player.Entity.Target.IsInCombat then
            yield("/battletarget")
        end
    elseif Inventory.GetFreeInventorySlots() <= 2 then
        State = CharacterState.dumpInventory
        Dalamud.Log("["..Prefix.."] State Change: Dump Inventory")
    elseif Inventory.GetItemsInNeedOfRepairs(5).Count > 0 then
        State = CharacterState.repair
        Dalamud.Log("["..Prefix.."] State Change: Need Repairs")
    elseif not IPC.Questionable.IsRunning() then
        local qstStepData = IPC.Questionable.GetCurrentStepData()
        if StartAttempts >= 3 then
            yield("/qst reload")
            yield("/wait 5")
        elseif qstStepData ~= nil then
            local targetTerritory = qstStepData.TerritoryId
            if Svc.ClientState.TerritoryType ~= targetTerritory then
                local targetPos = qstStepData.Position
                Dalamud.Log(targetPos)
                if targetPos == nil then
                    targetPos = Vector3(0, 0, 0)
                end
                local closestAetheryte = GetClosestAetheryte(targetTerritory, targetPos, 0)
                if closestAetheryte ~= nil then
                    if TeleportAttempts < 3 then
                        TeleportAttempts = TeleportAttempts + 1
                        yield("/li tp "..closestAetheryte.aetheryteName)
                    else
                        TeleportAttempts = 0
                        yield("/gaction return")
                    end
                    yield("/wait 10")
                else
                    local msg = "["..Prefix.."] Cannot find aetheryte to get to next area: #"..tostring(targetTerritory)
                    Dalamud.Log(msg)
                    yield("/echo "..msg)
                    yield("/snd stop all")
                end
            else
                yield("/echo 3")
                local msg = "["..Prefix.."] QST is stopped. Attempting to start..."
                Dalamud.Log(msg)
                yield("/echo "..msg)
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
        if os.time() - LastRecordedTimestamp > StuckCheckTimer then
            if Player.Entity.Position == LastRecordedPosition and not HasCondition(ConditionFlag.BoundByDuty) then
                local msg = "["..Prefix.."] Stuck for over "..tostring(StuckCheckTimer).."s"
                Dalamud.Log(msg)
                yield("/echo "..msg)
                yield("/qst stop")
            end
            LastRecordedTimestamp = os.time()
            LastRecordedPosition = Player.Entity.Position
        end
        StartAttempts = 0
    end
end

function DumpInventory()
    if Inventory.GetFreeInventorySlots() > 2 then
        State = CharacterState.questing
    elseif IPC.Questionable.IsRunning() then
        yield("/qst stop")
    elseif Svc.ClientState.TerritoryType ~= RetainerBell.zone then
        TeleportTo(RetainerBell.aetheryteName)
    elseif GetDistanceToPoint(RetainerBell.position) > 7 then
        if IPC.vnavmesh.IsReady() and not IPC.vnavmesh.IsRunning() then
            IPC.vnavmesh.PathfindAndMoveTo(RetainerBell.position)
        end
    elseif Player.Entity.Target == nil or Player.Entity.Target.Name ~= "Summoning Bell" then
        yield("/target Summoning Bell")
    elseif not HasCondition(ConditionFlag.OccupiedSummoningBell) then
        yield("/interact")
    end
end

RemainingDurabilityToRepair = 5
ShouldAutoBuyDarkMatter = false
function Repair()
    local needsRepair = Inventory.GetItemsInNeedOfRepairs(RemainingDurabilityToRepair)

    if Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
        return
    end

    if Addons.GetAddon("Repair").Ready then
        if needsRepair.Count == nil or needsRepair.Count == 0 then
            yield("/callback Repair true -1") -- if you dont need repair anymore, close the menu
        else
            yield("/callback Repair true 0") -- select repair
        end
        return
    end

    -- if occupied by repair, then just wait
    if HasCondition(ConditionFlag.Occupied39) then
        Dalamud.Log("["..Prefix.."] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = {position = Vector3(-213.95, 15.99, 49.35)}
    if SelfRepair then
        if Inventory.GetItemCount(33916) > 0 then
            if Addons.GetAddon("Shop").Ready then
                yield("/callback Shop true -1")
                return
            end

            if HasCondition(ConditionFlag.Mounted) then
                Dismount()
                Dalamud.Log("["..Prefix.."] State Change: Dismounting")
                return
            end

            if needsRepair.Count > 0 then
                if not Addons.GetAddon("Repair").Ready then
                    Dalamud.Log("["..Prefix.."] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.questing
                Dalamud.Log("["..Prefix.."] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if Svc.ClientState.TerritoryType ~=  129 then
                yield("/echo Out of Dark Matter! Purchasing more from Limsa Lominsa.")
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local darkMatterVendor = {npcName="Unsynrael", position = Vector3(-257.71, 16.19, 50.11) }
            if GetDistanceToPoint(darkMatterVendor.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, darkMatterVendor.position) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif Addons.GetAddon("TelepotTown").Ready then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(darkMatterVendor.position) > 5 then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    IPC.vnavmesh.PathfindAndMoveTo(darkMatterVendor.position, false)
                end
            else
                if Svc.Targets.Target == nil or Svc.Targets.Target.Name ~= darkMatterVendor.npcName then
                    yield("/target "..darkMatterVendor.npcName)
                elseif not HasCondition(ConditionFlag.OccupiedInQuestEvent) then
                    yield("/interact")
                elseif Addons.GetAddon("SelectYesno").Ready then
                    yield("/callback SelectYesno true 0")
                elseif Addons.GetAddon("Shop") then
                    yield("/callback Shop true 0 40 99")
                end
            end
        else
            yield("/echo ["..Prefix.."] Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to Limsa mender.")
            SelfRepair = false
        end
    else
        if needsRepair.Count > 0 then
            if Svc.ClientState.TerritoryType ~= 129 then
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local mender = { npcName="Alistair", position = Vector3(-246.87, 16.19, 49.83)}
            if GetDistanceToPoint(mender.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, mender.position) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif Addons.GetAddon("TelepotTown").Ready then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(mender.position) > 5 then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    IPC.vnavmesh.PathfindAndMoveTo(mender.position, false)
                end
            else
                if Player.Entity.Target == nil or Player.Entity.Target.Name ~= mender.npcName then
                    yield("/target "..mender.npcName)
                elseif (not HasCondition(ConditionFlag.OccupiedInQuestEvent)) then
                    yield("/interact")
                end
            end
        else
            State = CharacterState.questing
            Dalamud.Log("["..Prefix.."] State Change: Ready")
        end
    end
end

MeleeDist = 2.5
RangedDist = 20
RotationAoePreset = ""
function SetMaxDistance()
    -- Check if the current job is a melee DPS or tank.
    if Player.Job and (Player.Job.IsMeleeDPS or Player.Job.IsTank) then
        MaxDistance = MeleeDist
        MoveToMob = true
        Dalamud.Log("[FATE] Setting max distance to " .. tostring(MeleeDist) .. " (melee/tank)")
    else
        MoveToMob = false
        MaxDistance = RangedDist
        Dalamud.Log("[FATE] Setting max distance to " .. tostring(RangedDist) .. " (ranged/caster)")
    end
end

RotationPlugin = "RSR"
function TurnOnCombatMods(rotationMode)
    if not CombatModsOn then
        CombatModsOn = true
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        if RotationPlugin == "RSR" then
            if rotationMode == "manual" then
                yield("/rotation manual")
                Dalamud.Log("["..Prefix.."] TurnOnCombatMods /rotation manual")
            else
                yield("/rotation off")
                yield("/rotation auto on")
                Dalamud.Log("["..Prefix.."] TurnOnCombatMods /rotation auto on")
            end
        elseif RotationPlugin == "BMR" then
            IPC.BossMod.SetActive(RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.SetActive(RotationAoePreset)
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto on")
        end

        if not AiDodgingOn then
            SetMaxDistance()

            if DodgingPlugin == "BMR" then
                yield("/bmrai on")
                yield("/bmrai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/bmrai followcombat on")
                yield("/bmrai maxdistancetarget " .. MaxDistance)
                if MoveToMob == true then
                    yield("/bmrai followoutofcombat on")
                end
            elseif DodgingPlugin == "VBM" then
                yield("/vbm ai on")
                --[[vbm ai doesn't support these options
                yield("/vbmai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/vbmai followcombat on")
                yield("/vbmai maxdistancetarget " .. MaxDistance)
                if MoveToMob == true then
                    yield("/vbmai followoutofcombat on")
                end
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions on") --This Disables VBM AI Auto-Target
                end]]
            end
            AiDodgingOn = true
        end
    end
end

DodgingPlugin = "BMR"
function TurnOffCombatMods()
    if CombatModsOn then
        Dalamud.Log("["..Prefix.."] Turning off combat mods")
        CombatModsOn = false

        if RotationPlugin == "RSR" then
            yield("/rotation off")
            Dalamud.Log("["..Prefix.."] TurnOffCombatMods /rotation off")
        elseif RotationPlugin == "BMR" then
            IPC.BossMod.ClearActive()
        elseif RotationPlugin == "VBM" then
            IPC.BossMod.ClearActive()
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto off")
        end

        -- turn off BMR so you dont start following other mobs
        if AiDodgingOn then
            if DodgingPlugin == "BMR" then
                yield("/bmrai off")
                yield("/bmrai followtarget off")
                yield("/bmrai followcombat off")
                yield("/bmrai followoutofcombat off")
            elseif DodgingPlugin == "VBM" then
                yield("/vbm ai off")
                --[[vbm ai doesn't support these options.
                yield("/vbmai followtarget off")
                yield("/vbmai followcombat off")
                yield("/vbmai followoutofcombat off")
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions off") --This Enables VBM AI Auto-Target
                end]]
            end
            AiDodgingOn = false
        end
    end
end

CombatModsOn = false
ReturnOnDeath = true
function HandleDeath()
    CurrentFate = nil

    if CombatModsOn then
        TurnOffCombatMods()
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
    end

    if HasCondition(ConditionFlag.Unconscious) then --Condition Dead
        if ReturnOnDeath then
            if not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                yield("/echo ["..Prefix.."] You have died. Returning to home aetheryte.")
            end

            if Addons.GetAddon("SelectYesno").Ready then --rez addon yes
                yield("/callback SelectYesno true 0")
                yield("/wait 0.1")
            end
        else
            if not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                yield("/echo ["..Prefix.."] You have died. Waiting until script detects you're alive again...")
            end
            yield("/wait 1")
        end
    else
        State = CharacterState.questing
        Dalamud.Log("["..Prefix.."] State Change: Ready")
        DeathAnnouncementLock = false
        HasFlownUpYet = false
    end
end

CharacterState =
{
    questing = Questing,
    repair = Repair,
    death = HandleDeath
}

TurnOnCombatTriggered = false
TurnOffCombatTriggered = false
ExitedDuty = false
StartAttempts = 0
LastRecordedPosition = Player.Entity.Position
LastRecordedTimestamp = os.time()
StuckCheckTimer = 20
TeleportAttempts = 0
yield("/at y")

RetainerBell = RetainerBells[1]

State = CharacterState.questing
while true do
    State()
    yield("/wait 1")
end