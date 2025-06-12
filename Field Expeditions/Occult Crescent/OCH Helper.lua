ShouldExtractMateria =  true
SelfRepair =            true
RepairAmount =          5
    ShouldAutoBuyDarkMatter =   true

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

function TurnOnOCH()
    if not IllegalMode then
        IllegalMode = true
        yield("/ochillegal on")
    end
end

function TurnOffOCH()
    if IllegalMode then
        IllegalMode = false
        yield("/ochillegal off")
    end
    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end
    if LifestreamIsBusy() then
        yield("/li stop")
    end
end

function ExtractMateria()
    TurnOffOCH()

    if GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
        return
    end

    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        return
    end

    if CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        if not IsAddonVisible("Materialize") then
            yield("/generalaction \"Materia Extraction\"")
            return
        end

        LogInfo("[OCHHelper] Extracting materia...")
            
        if IsAddonVisible("MaterializeDialog") then
            yield("/callback MaterializeDialog true 0")
        else
            yield("/callback Materialize true 2 0")
        end
    else
        if IsAddonVisible("Materialize") then
            yield("/callback Materialize true -1")
        else
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

function ReturnToBase()
    yield("/gaction Return")
    repeat
        yield("/wait 1")
    until not GetCharacterCondition(CharacterCondition.casting)
    repeat
        yield("/wait 1")
    until not GetCharacterCondition(CharacterCondition.betweenAreas)
end

DarkMatterItemId = 33916
Mender = { name="Expedition Supplier", x=821.47, y=72.73, z=-669.12 }
BaseAetheryte = { x=830.75, y=72.98, z=-695.98 }
function Repair()
    TurnOffOCH()

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("Repair") then
        if not NeedsRepair(RepairAmount) then
            yield("/callback Repair true -1") -- if you don't need repair anymore, close the menu
        else
            yield("/callback Repair true 0") -- select repair
        end
        return
    end

    -- if occupied by repair, then just wait
    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        LogInfo("[OCHHelper] Repairing...")
        yield("/wait 1")
        return
    end

    if SelfRepair then
        if GetItemCount(DarkMatterItemId) > 0 then
            if IsAddonVisible("Shop") then
                yield("/callback Shop true -1")
                return
            end

            if GetCharacterCondition(CharacterCondition.mounted) then
                Dismount()
                LogInfo("[OCHHelper] State Change: Dismounting")
                return
            end

            if NeedsRepair(RepairAmount) then
                if not IsAddonVisible("Repair") then
                    LogInfo("[OCHHelper] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.ready
                LogInfo("[OCHHelper] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            local baseToMender = DistanceBetween(Mender.x, Mender.y, Mender.z, BaseAetheryte.x, BaseAetheryte.y, BaseAetheryte.z) + 50
            local distanceToMender = GetDistanceToPoint(Mender.x, Mender.y, Mender.z)
            if distanceToMender > baseToMender then
                ReturnToBase()
                return
            elseif distanceToMender > 7 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= Mender.name then
                    yield("/target "..Mender.name)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                elseif IsAddonVisible("SelectIconString") then
                    yield("/callback SelectIconString true 0")
                elseif IsAddonVisible("SelectYesno") then
                    yield("/callback SelectYesno true 0")
                elseif IsAddonVisible("Shop") then
                    yield("/callback Shop true 0 10 99")
                end
            end
        else
            yield("/echo Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to mender.")
            SelfRepair = false
        end
    else
        if NeedsRepair(RepairAmount) then
            local baseToMender = DistanceBetween(Mender.x, Mender.y, Mender.z, BaseAetheryte.x, BaseAetheryte.y, BaseAetheryte.z) + 50
            local distanceToMender = GetDistanceToPoint(Mender.x, Mender.y, Mender.z)
            if distanceToMender > baseToMender then
                ReturnToBase()
                return
            elseif distanceToMender > 7 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z)
                end
            elseif IsAddonVisible("SelectIconString") then
                yield("/callback SelectIconString true 1")
            else
                if not HasTarget() or GetTargetName() ~= Mender.npcName then
                    yield("/target "..Mender.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                end
            end
        else
            State = CharacterState.ready
            LogInfo("[OCHHelper] State Change: Ready")
        end
    end
end

PhantomVillageZoneId = 1278
OccultCrescentZoneId = 1252
Talked = false
function ZoneIn()
    if GetCharacterCondition(CharacterCondition.betweenAreas) then
        yield("/wait 3")
    elseif IsInZone(PhantomVillageZoneId) then
        LogInfo("[OCHHelper] Already in Phantom Village")
        local npc = { name="Jeffroy", x=-77.958374, y=5, z=-15.396423}
        if GetDistanceToPoint(npc.x, npc.y, npc.z) >= 7 then
            PathfindAndMoveTo(npc.x, npc.y, npc.z)
        elseif PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        elseif GetTargetName() ~= npc.name then
            yield("/target "..npc.name)
        elseif IsAddonVisible("ContentsFinderConfirm") then
            yield("/wait 1")
            yield("/callback ContentsFinderConfirm true 8")
            yield("/wait 3")
        elseif IsAddonVisible("SelectString") then
            yield("/callback SelectString true 0")
        elseif not Talked then
            Talked = true
            yield("/echo interact")
            yield("/interact")
        end
    elseif not IsInZone(OccultCrescentZoneId) then
        yield("/li occult")
        repeat
            yield("/wait 1")
        until not LifestreamIsBusy()
    elseif IsInZone(OccultCrescentZoneId) then
        if IsPlayerAvailable() then
            Talked = false
            yield("/rsr auto")
            State = CharacterState.ready
            LogInfo("[OCHHelper] State Change: Ready")
        end
    end
end

IllegalMode = false
function Ready()
    if not IsInZone(OccultCrescentZoneId) then
        State = CharacterState.zoneIn
        LogInfo("[OCHHelper State Change: ZoneIn]")
    elseif GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/wait 1")
    elseif RepairAmount > 0 and NeedsRepair(RepairAmount) then
        State = CharacterState.repair
        LogInfo("[OCHHelper] State Change: Repair")
    elseif ShouldExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
    elseif not IllegalMode then
        TurnOnOCH()
    end
end

CharacterState = {
    ready = Ready,
    zoneIn = ZoneIn,
    -- dead = HandleDeath,
    -- unexpectedCombat = HandleUnexpectedCombat,
    extractMateria = ExtractMateria,
    repair = Repair
}

State = CharacterState.ready
while true do
    State()
    yield("/wait 0.1")
end