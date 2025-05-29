--[[
********************************************************************************
*                              Daily Hunts Doer                                *
*                                   1.0.3                                      *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Description: Picks up daily hunts from each expac and attempts to do them. It
will NOT do the weekly Elite hunts.

THIS CANNOT BE AFK'D FOR THE FOLLOWING REASONS:
1. The mark area is very large. There is no guarantee you will land within
   targetable range of a mark.
2. If the mark is in a cave, this script will land you on top of the cave but
   will not be able to actually find the mark.
3. The center of the mark area may not be landable, ex. the script may send you
   to the bottom of the Sea of Clouds. If this happens, stop the script,
   complete the mark manually, then restart the script.
4. This script cannot do elites. If the script says the next mark to hunt is an
   elite, stop the script, complete the mark manually, then restart the script.
   
********************************************************************************
*                                 Version 1.0.2                                *
********************************************************************************
    1.0.2   Fixed 3-star hunt pickups
            Fixed n+1 hunt requirement

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

1. Hunt Buddy
2. Rotation Solver Reborn
3. BossModReborn (BMR)

********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

ShouldPickUpHunts = true    -- Set to false if you want it to start doing the
                            -- hunt bills you already have

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]


HuntBoards =
{
    {
        city = "Ishgard",
        zoneId = 418,
        aetheryte = "Foundation",
        miniAethernet = {
            name = "Forgotten Knight",
            x=45, y=24, z=0
        },
        boardName = "Clan Hunt Board",
        bills = { 2001700, 2001701, 2001702 },
        x=73, y=24, z=22,
    },
    {
        city = "Kugane",
        zoneId = 628,
        aetheryte = "Kugane",
        boardName = "Clan Hunt Board",
        bills = { 2002113, 2002114, 2002115 },
        x=-32, y=0, z=-44
    },
    {
        city = "Crystarium",
        zoneId = 819,
        aetheryte = "The Crystarium",
        miniAethernet = {
            name = "Temenos Rookery",
            x=-108, y=-1, z=-59
        },
        boardName = "Nuts Board",
        bills = { 2002628, 2002629, 2002630 },
        x=-84, y=-1, z=-91
    },
    {
        city = "Old Sharlayan",
        zoneId = 962,
        aetheryte = "Old Sharlayan",
        miniAethernet = {
            name = "Scholar's Harbor",
            x=16, y=-17, z=127
        },
        boardName = "Guildship Hunt Board",
        bills = { 2003090, 2003091, 2003092 },
        x=29, y=-16, z=98
    },
    {
        city = "Tuliyollal",
        zoneId = 1185,
        aetheryte = "Tuliyollal",
        miniAethernet = {
            name = "Bayside Bevy Marketplace",
            x=-15, y=-11, z=135
        },
        boardName = "Hunt Board",
        bills = { 2003510, 2003511, 2003512 },
        x=25, y=-15, z=135
    }
}

-- #region Movement

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[DailyHunts] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 3") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[DailyHunts] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    LastStuckCheckTime = os.clock()
    LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}
end

function GetClosestAetheryte(x, y, z, zoneId, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    local aetheryteIds = GetAetherytesInZone(zoneId)
    for i=0, aetheryteIds.Count-1 do
        local aetheryteCoords = GetAetheryteRawPos(aetheryteIds[i])
        local aetheryte =
        {
            aetheryteId = aetheryteIds[i],
            aetheryteName = GetAetheryteName(aetheryteIds[i]),
            x = aetheryteCoords.Item1,
            z = aetheryteCoords.Item2
        }

        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, y, aetheryte.z, x, y, z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        -- LogInfo("[DailyHunts] Distance via aetheryte #"..aetheryte.aetheryteId.." adjusted for tp penalty is "..tostring(comparisonDistance))
        -- LogInfo("[DailyHunts] AetheryteX: "..aetheryte.x..", AetheryteZ: "..aetheryte.z)

        if comparisonDistance < closestTravelDistance then
            -- LogInfo("[DailyHunts] Updating closest aetheryte to #"..aetheryte.aetheryteId)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestAetheryte
end

function RandomAdjustCoordinates(x, y, z, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = x + (x_adjust * math.cos(angle))
    local randomY = y + maxDistance
    local randomZ = z + (z_adjust * math.sin(angle))

    return randomX, randomY, randomZ
end

function Mount()
    if  GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        IsPlayerCasting()
    then
        -- wait
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.goToMarker
        LogInfo("[DailyHunts] State Change: GoToMarker")
    else
        yield('/gaction "mount roulette"')
    end
    yield("/wait 1")
end

function Dismount()
    if GetCharacterCondition(CharacterCondition.flying) then
        yield('/ac dismount')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetCharacterCondition(CharacterCondition.flying) and GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 2 then
                LogInfo("[FATE] Unable to dismount here. Moving to another spot.")
                local random_x, random_y, random_z = RandomAdjustCoordinates(x, y, z, 10)
                local nearestPointX = QueryMeshNearestPointX(random_x, random_y, random_z, 100, 100)
                local nearestPointY = QueryMeshNearestPointY(random_x, random_y, random_z, 100, 100)
                local nearestPointZ = QueryMeshNearestPointZ(random_x, random_y, random_z, 100, 100)
                if nearestPointX ~= nil and nearestPointY ~= nil and nearestPointZ ~= nil then
                    PathfindAndMoveTo(nearestPointX, nearestPointY, nearestPointZ, GetCharacterCondition(CharacterCondition.flying) and HasFlightUnlocked())
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
    end
end
-- #endregion Movement

-- #region Hunt

BoardNumber = 1
function GoToHuntBoard()
    if BoardNumber > #HuntBoards then
        SelectNextHunt()
        State = CharacterState.goToMarker
        LogInfo("[DailyHunts] State Change: GoToMarker")
        return
    end

    Board = HuntBoards[BoardNumber]
    local skipBoard = true
    for _, bill in ipairs(Board.bills) do
        if GetItemCount(bill) == 0 then
            skipBoard = false
        end
    end
    if not LogInfo("[DailyHunts] Check SkipBoard") and skipBoard then
        BoardNumber = BoardNumber + 1
    elseif not LogInfo("[DailyHunts] Check ZoneId") and not IsInZone(Board.zoneId) then
        TeleportTo(Board.aetheryte)
    elseif not LogInfo("[DailyHunts] Check Distance to Board") and Board.miniAethernet ~= nil and GetDistanceToPoint(Board.x, Board.y, Board.z) > (DistanceBetween(Board.miniAethernet.x, Board.miniAethernet.y, Board.miniAethernet.z, Board.x, Board.y, Board.z) + 20) then
        LogInfo("[DailyHunts] Distance to board is: "..GetDistanceToPoint(Board.x, Board.y, Board.z))
        LogInfo("[DailyHunts] Distance between board and mini aetheryte: "..DistanceBetween(Board.miniAethernet.x, Board.miniAethernet.y, Board.miniAethernet.z, Board.x, Board.y, Board.z))
        yield("/target aetheryte")
        yield("/wait 0.5")
        if GetDistanceToTarget() > 7 then
            PathMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        else
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
            yield("/li "..Board.miniAethernet.name)
            yield("/wait 5")
        end
    elseif IsAddonVisible("TelepotTown") then
        yield("/callback TelepotTown true -1")
    elseif GetDistanceToPoint(Board.x, Board.y, Board.z) > 3 then
        if not PathIsRunning() and not PathfindInProgress() then
            PathfindAndMoveTo(Board.x, Board.y, Board.z)
        end
    else
        if PathIsRunning() or PathfindInProgress() then
            yield("/vnav stop")
        else
            BoardNumber = BoardNumber + 1
            State = CharacterState.pickUpHunts
            LogInfo("[DailyHunts] State Change: PickUpHunts")
        end
    end
end

HuntNumber = 0
function PickUpHunts()
    if HuntNumber >= #Board.bills then
        if IsAddonVisible("Mobhunt"..BoardNumber) then
            yield("/callback Mobhunt"..BoardNumber.." true -1")
        else
            HuntNumber = 0
            State = CharacterState.goToHuntBoard
            LogInfo("[DailyHunts] State Change: GoToHuntBoard "..BoardNumber)
        end
    elseif GetItemCount(Board.bills[HuntNumber+1]) >= 1 then
        HuntNumber = HuntNumber + 1
    elseif IsAddonVisible("SelectYesno") and GetNodeText("SelectYesno", 15) == "Pursuing a new mark will result in the abandonment of your current one. Proceed?" then
        yield("/callback SelectYesno true 1")
        HuntNumber = HuntNumber + 1
    elseif IsAddonVisible("SelectString") then
        local callback = "/callback SelectString true "..HuntNumber
        LogInfo("[DailyHunts] Executing ".."/callback SelectString true "..HuntNumber)
        yield(callback)
    elseif IsAddonVisible("Mobhunt"..BoardNumber) then
        local callback = "/callback Mobhunt"..BoardNumber.." true 0"
        LogInfo("[DailyHunts] Executing "..callback)
        yield(callback)
        HuntNumber = HuntNumber + 1
    elseif not HasTarget() or GetTargetName() ~= Board.boardName then
        yield("/target "..Board.boardName)
    else
        yield("/interact")
    end
end

function ParseHuntChat() -- Pattern to match the quantity and item name
    local chat = GetNodeText("ChatLogPanel_3", 7, 2)
    LogInfo("[DailyHunts] "..chat)
    -- Pattern to match the quantity, item name, and location
    local huntingPattern = "Hunting (%d+)x ([%w%s%-'–]+) in ([%w%s%-'–]+)"
    local slainPattern = "Hunt mark ([%w%s%-'–]+) slain! %((%d+)/(%d+)%)"
    
    -- Find all matches and store them in a table
    local hunt = nil
    for line in chat:gmatch("[^\r\n]+") do
        LogInfo("[DailyHunts] Parsing Chat: "..line)
        for quantity, markName, location in line:gmatch(huntingPattern) do
            quantity = tonumber(quantity)
            markName = markName:lower()
            LogInfo("[DailyHunts] Found hunt: "..markName)

            hunt = {quantity = tonumber(quantity), name = markName, location = location}
        end
        if hunt ~= nil then
            for markName, slain, goal in line:gmatch(slainPattern) do
                markName = markName:lower()
                LogInfo("[DailyHunts] Found slain mark "..markName)
                if hunt.name == markName and slain == goal then
                    LogInfo("[DailyHunts] Hunt mark complete. Setting hunt to nil")
                    hunt = nil
                end
            end
        end
        if string.find(line, "elite") ~= nil then
            LogInfo("[DailyHunts] line is elite")
            hunt = nil
        end
    end

    return hunt
end

function SelectNextHunt()
    LogInfo("[DailyHunts] Selecting Next Hunt")
    yield("/wait 1")
    Hunt = nil
    while Hunt == nil or Hunt.name:sub(1, 5):lower() == "elite" do
        yield("/phb next")
        yield("/wait 1")
        Hunt = ParseHuntChat()
    end
end

function GoToDravanianHinterlands()
    if IsInZone(478) then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.mounting
            LogInfo("[DailyHunts] State Change: Mounting")
        else
            PathfindAndMoveTo(148.51, 207.0, 118.47)
            while PathfindInProgress() or PathIsRunning() do
                yield("/wait 3")
            end
            while GetCharacterCondition(CharacterCondition.betweenAreas) do
                yield("/wait 1")
            end
            yield("/wait 1")
        end
    else
        TeleportTo("Idyllshire")
    end
end

function GoToMarker()
    local teleportTimePenalty = 50

    local flagZone = GetFlagZone()
    local x = GetFlagXCoord()
    local z = GetFlagYCoord()
    local closestAetheryte = GetClosestAetheryte(x, 0, z, flagZone, teleportTimePenalty)
    -- LogInfo("[DailyHunts] Closest aetheryte is "..closestAetheryte.aetheryteName)

    if not IsInZone(flagZone) then
        if flagZone == 399 then
            GoToDravanianHinterlands()
        else
            TeleportTo(closestAetheryte.aetheryteName)
        end
        return
    end

    local y = GetPlayerRawYPos()
    local directFlightDistance = GetDistanceToPoint(x, y, z)
    -- LogInfo("[DailyHunts] Direct flight distance is "..directFlightDistance)

    if closestAetheryte ~= nil and DistanceBetween(closestAetheryte.x, y, closestAetheryte.z, x, y, z) + teleportTimePenalty < directFlightDistance then
        TeleportTo(closestAetheryte.aetheryteName)
    elseif GetDistanceToPoint(x, GetPlayerRawYPos(), z) > 15 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.mounting
            LogInfo("[DailyHunts] State Change: Mounting")
        elseif not PathIsRunning() and not PathfindInProgress() then
            -- PathfindAndMoveTo(x, y, z, true)
            yield("/wait 0.5")
            yield("/vnav flyflag")
        end
    else
        if GetCharacterCondition(CharacterCondition.mounted) then
            Dismount()
        elseif PathIsRunning() or PathfindInProgress() then
            yield("/vnav stop")
        else
            State = CharacterState.doHunt
            LogInfo("[DailyHunts] State Change: DoHunt")
        end
    end
end

DidHunt = false
CombatModsOn = false
LastTargetName = nil
function DoHunt()
    if IsPlayerCasting() then
        yield("/wait 1")
        return
    elseif not IsInZone(GetFlagZone()) or GetDistanceToPoint(GetFlagXCoord(), GetPlayerRawYPos(), GetFlagYCoord()) > 200 then
        if GetCharacterCondition(CharacterCondition.inCombat) then
            if not HasTarget() then
                yield("/battletarget")
            end
        else
            State = CharacterState.goToMarker
            LogInfo("[DailyHunts] State Change: GoToMarker")
        end
        return
    elseif not HasTarget() or GetTargetHP() <= 0 then
        SelectNextHunt()
        local targetingCommand = "/target "..Hunt.name
        LogInfo("[DailyHunts] Executing "..targetingCommand)
        yield(targetingCommand)
        yield("/wait 0.5")
        return
    end

    if not CombatModsOn then
        yield("/bmrai followtarget on")
        yield("/bmrai followcombat on")
        yield("/rotation manual")
        CombatModsOn = true
    end

    if GetCharacterCondition(CharacterCondition.inCombat) then
        DidHunt = true
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end
        return
    elseif GetDistanceToTarget() > 5 + GetTargetHitboxRadius() then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        end
        return
    end
end

-- #endregion Hunt

CharacterState =
{
    goToMarker = GoToMarker,
    mounting = Mount,
    doHunt = DoHunt,
    goToHuntBoard = GoToHuntBoard,
    pickUpHunts = PickUpHunts
}

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

LastStuckCheckTime = os.clock()
LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}

if ShouldPickUpHunts then
    State = CharacterState.goToHuntBoard
else
    SelectNextHunt()
    State = CharacterState.goToMarker
end
while true do
    if not (NavIsReady() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.beingMoved) or
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        State()
        yield("/wait 0.1")
    else
        yield("/wait 1")
    end
end