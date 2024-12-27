--[[
********************************************************************************
*                            Fishing Gatherer Scrips                           *
*                                Version 1.4.2                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
Loosely based on Ahernika's NonStopFisher

    -> 1.4.2    Added more logging statements
                Added soft and hard amiss checks
                Added stuck checks
                Added a second dismount check just to make sure
                Reverted dismount -> fishing
                Fixed dismounting
                Adjusted tree coords to give an even wider berth, shortened
                    fishing range to avoid unfishable area, changed state
                    transition dismount -> goToFishingHole to avoid flying out
                    to pointToFace
                Added IsAddonReady("RetainerList") check
                Fixed purple scrip exchange, changed purple fishing point to
                    face to be further south, fixed coordinates for ul'dah and
                    gridania
                Added purple scrip exchange code bc i forgot lol
                Tree
                Fixed materia extraction bug p2
                Fixed repair
                Fixed teleport errors
                Fixed purple scrips
                Fixed MinInventoryFreeSlots
                Updated algorithm to randomly choose any fishing spot in a line
                    along the coast, fixed self repair

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

1. AutoHook
2. VnavMesh
3. Lifestream
4. Teleporter
5. YesAlready: YesNo > ... (the 3 dots) > Auto Collectables https://github.com/PunishXIV/AutoHook/blob/main/AcceptCollectable.md

********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

ScripColorToFarm                    = "Purple"  --Options: Orange/Purple
ItemToExchange                      = "Hi-Cordial"
SwitchLocationsAfter                = 10        --Number of minutes to fish at this spot before changing spots.

Retainers                           = true      --If true, will do AR (autoretainers)
GrandCompanyTurnIn                  = true      --If true, will do GC deliveries using deliveroo everytime retainers are processed
ReturnToGCTown                      = true      --if true will use fast return to GC town for retainers and scrip exchange (that assumes you set return location to your gc town else turn it false), else falase
--needs a yesalready set up like "/Return to New Gridania/"

Food                                = ""        --what food to eat (false if none)
Potion                              = "Superior Spiritbond Potion <hq>"     --what potion to use (false if none)

--things you want to enable
ExtractMateria                      = true      --If true, will extract materia if possible
ReduceEphemerals                    = true      --If true, will reduce ephemerals if possible
SelfRepair                          = true      --If true, will do repair if possible set repair amount below
RepairAmount                        = 1         --repair threshold, adjust as needed

MinInventoryFreeSlots               = 1         --set !!!carefully how much inventory before script stops gathering and does additonal tasks!!!

HubCity                             = "Solution Nine"   --Options: Limsa/Gridania/Ul'dah/Solution Nine

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

OrangeGathererScripId = 41785
PurpleGathererScripId = 33914

ScripExchangeItems = {
    {
        itemName = "Mount Token",
        categoryMenu = 4,
        subcategoryMenu = 8,
        listIndex = 6,
        price = 1000
    },
    {
        itemName = "Hi-Cordial",
        categoryMenu = 4,
        subcategoryMenu = 1,
        listIndex = 0,
        price = 20
    },
}

FishTable =
{
    {
        fishName = "Zorgor Condor",
        fishId = 43761,
        baitName = "Versatile Lure",
        zoneId = 1190,
        zoneName = "Shaaloani",
        autohookPreset = "AH4_H4sIAAAAAAAACu1Yy27jNhT9FVfrsNCD1CM7j5ukKfLCOG2BDrqgyCtbiCx6KGqSdDD/3kvJSiRbTpCBF+0gO+ny8tyHDg9JfXWmtVEzXplqli2c46/OScnTAqZF4RwbXcORYwcv8hKeB2U3dI5PfpwcOTc6Vzo3j86xh9bq5EEUtQT5bLb+31qsS6XE0oI1D759anDC+Mg5W98uNVRLVaDFc90B8svQDUYSDWa4ryYzW9arLgPqufSVFLpZqihAmD0dQRyvP8t/PQulZc6LPXihRwd4dDPrNK+WJ49Q9fJnW/kzNsg/7D4Bv4P5Ms/MB543VVhD1Rnmhos7REWwzYfZxe2jJhvUG25yKAX08gm354XDfvrdVJ3/AzNuWmKMsQyT2Abztz5OsAG7XfIi53fVKf+itMUbGLrqgqOh/SMI9QXQ37M925MCHQTs2vkhX5zxVVP3tFwUoKsuiN9ODSKX7mQ/gIq/IdbJg9F8swzth7hV83u+Pi9NnZtclWc8L7veEmTERa3hEqqKLzC04xw5V00SzpXCxXrUIjyu0WIbM4J3oSrz3Xg3WAiMZ+gQZ894G7EZf85nvsalpHkxq7WG0hyoyi3Ug9U6mu1OxaPRG69TpQU0qwzdOno1RmmtGxXzUMdaKs2NWtuFnpeLuQGc4fWr3NBtqg9TXB+uyfb3Mv9cg8V1PD+mSZBIkgZhRCi4PkkBXEIz4FkQJ9wD30G8i7wy15mNgfz/1BLZFvCk8211+3L8A+OjjhQwsR4W8ErpFS9+VerOQnQi8yfw5t3aMf+n9ZrxosKOtu+bwX6rN6a2fupFVrw6zLnRquxtgnum3+Yr0FsCcZmXT0P4jZKf3Z1QbtALdQELKCXXjweooQH+RdXovNWV1sMPkyeH5xL3uoyl1ve61fl6X6SI+cGTy75YA6cXom387AqYZgb0jNeLJR5FVnbPQpqPLY3msILEaTZF+9CT+xnHxhdTY2C1Nl0vrc8t1wtoMa/L4rHBsKbOZ2QzCCKW7B4WXtjo7Qmlk8GOyx/hc51rkJijqe2Ga49Aewj+CmHfyrV37ryNOweiQE9PwQWRMghJwiMgNBAe4TRKiZ/4WZrEwuehi/K3K6A0iFmwX0BnXJia68lv+eJ/rZ6X/KFnC+i7or4r6rui/ji78QEkNGR+knLwiQSXEyokJzwVLuEMhTRG6ChACf27O5Nufjx8ejK0qopn1KG8YlL75fUvpRdKT+ZC6TVu5YPjtPdSf84lXgRygXcCbIoN1jpMV6ouB26YAku2b4vB8CIf20i1zjjKbmH1dfxHBEvYK3dmhkD/mR8yz/ea777N2MnWMrNdbRrav99sbjX2sTU/u43Rt0c1EaWSutIjLk9iQmkMhMs0JOBJxqQrMoCo2a23qBTuFDCd3GMMkJNqyaW6n+i8gmqSabXCAYPxJ2YJkxUS9Kcd1s1UKfGXxqE5N06dt1PwnXMH5VzMQgEgGGFuEhDqUUYSwVwSBowlQZoETMpRzrkvXK/5QvPSTJAQgsvh+nmXrx9WvgIuaCQTICkubEKlZISHCSdZTLPIozJMXNHslC3umOpMyOQaqbMA3PvwrFAN/w7FMfViDpTEIqaERjQiCUsF/iIKYg/vK6EfIVf/BUp1IuxuGAAA",
        fishingSpots = {
            maxHeight = 1024,
            waypoints = {
                { x=-4.47, y=-6.85, z=747.47 },
                { x=59.27, y=-2.0, z=735.09 }, -- tree
                { x=135.71, y=6.12, z=715.0 },
                { x=212.5, y=12.2, z=739.26 },
            },
            pointToFace = { x=134.07, y=6.07, z=10000 },
            reset = {
                waypoint = { x=458.1, y=17.06, z=666.35 },
                pointToFace = { x=458.1, y=17.06, z=10000 }
            }
        },
        scripColor = "Orange",
        scripId = 39,
        collectiblesTurnInListIndex = 6
    },
    {
        fishName = "Fleeting Brand",
        fishId = 36473,
        baitName = "Versatile Lure",
        zoneId = 959,
        zoneName = "Mare Lamentorum",
        autohookPreset = "AH4_H4sIAAAAAAAACu1YS1PjOBD+K5TP8VRsS35wCxlgqQoMRcLuYWoPst1OVDhWRpZZ2Cn++7T8SOzEIVNThOLAhTIt6euHvm5156cxKpQYs1zl42RunP40zjMWpjBKU+NUyQIGhl6c8Aw2i3GzdIVfth8MjFvJheTq2Ti1UJqfP0VpEUO8Eev9LxXWtRDRQoOVH7b+KnFcf2BcrmYLCflCpCixhsMO8uvQJUbgdU4MDxozXhTLxgJiDckBE5pTIk0hUnsigjhW+5R92AohY87S0pDsEWQj6G4e9CmzbNcNtqwmXau7To1C8Yh3mbA0b9Rf8Hxx/gx5KxB0C5LSDqTb3CV7gOmCJ+qM8TIcWpA3gqli0QOiIlh9w7u4bdSgRr1likMW7WMcmuduw7jde7IbJMn/hzFTFeEaI7ZP21u37NSnZwuWcvaQX7BHITVAR9B45wy68juIMMK439Ix68sYNGGbaE7HgCa8Z3x+yZZlHEbZPAWZN0o1p/Qxb0h2vOlA+S+Idf6kJKvzW1/MTEz/Y6urTBVccZFdMp418TGRupNCwjXkOZujasMYGDelEcaNwCowqBCeVyjRgerBm4hc/THeLToC/RYaprFnvdJYrm/sma4wRyVLx4WUkKk38nIL9c187bV2x+Ne7eWuCyEjKLMOtzV0K4Wxltbl0cICWVFpqsRKJz7P5lMFeMJqe1nTbSTfxrk2XGntfcZ/FKBxDcvGfHatoZlAbJuEhK4ZONQyLUaH1CaebTNiIN6E5+pbonUg/79XRNYOrDO78m6fjX+jfqwrKZzoHRrwRsglS/8S4kFDNEXnH2Dl/1qO9q/ztyyYTT7Xi+1Qa9GML0FuZfw1z9ZL+hH7gjZes6e2LPiChaKGrOJHLE8Xw8amqZIia73Ox1c/dFrqJzCHLGby+QPEpTTsqygQ6sBNvali2w3Weje3cTQVvxPxIyifSb5657h61HbWmo8V2Y6S949trV5X3FGiQI5ZMV9gT73UPROW1b5SXHbdWKjKpkx/tNqN6uWnwW632n36X+k7dcPcPJ5NBbyDHwWXEKMmVei2TXfkfWXx+GXuXavZZ3X6rE6f1emDVadWgxiROGAhdc0kTGKTAFhmCBaYQ9tlxI6SmMTUePm36RDr3xe+rwVVk4gdY7tbdFziOfu7xYsUQKHHJ2eSZXGnt7X2BkvPe1cxtuU8wg4dQ6SVfcvS5/sc7rMY5GawbX5a0adHS1FkrYD3jbw02B7zHK3tq8jUmCFiWntdv1+bePra2kImDMtrqruyesSnAT0wBVM8+WF+q9lMJn88j+jDWjLW0S4D3Z5Q6rlEf1bizbbdBBh2+OkmNrhOAGbo+Z5JfMs3fY8kJrWtwA89iDxPDzC7/KP7PbiDuVCC5/Cb1LN6mNfPrtfo9Cpt+mnZy6LDtPxk1352dcgFDiUe82Mz8JLAJF5IzdCNfZyOQz+0me97iVUWv4q1veXrxDy5LSS2vifTCFvgvDt/+0no+K6fmCyxQpMwykzmMYp/qE9iIISyyHj5BQWv79UpFgAA",
        fishingSpots = {
            maxHeight = 35,
            waypoints = {
                { x=10.05, y=26.89, z=448.99 },
                { x=37.71, y=22.36, z=481.05 },
                { x=58.87, y=22.22, z=487.95 }, --orange balls
                { x=71.79, y=22.39, z=477.65 },
            },
            pointToFace = { x=37.71, y=22.36, z=1000 },
            reset = {
                waypoint = { x=477.26, y=66.67, z=520.09 },
                pointToFace = { x=10000, y=66.67, z=520.09 },
            }
        },
        scripColor = "Purple",
        scripId = 38,
        collectiblesTurnInListIndex = 28
    }
}

HubCities =
{
    {
        zoneName="Limsa",
        zoneId = 129,
        aethernet = {
            aethernetZoneId = 129,
            aethernetName = "Hawkers' Alley",
            x=-213.61108, y=16.739136, z=51.80432
        },
        retainerBell = { x=-123.88806, y=17.990356, z=21.469421, requiresAethernet=false },
        scripExchange = { x=-258.52585, y=16.2, z=40.65883, requiresAethernet=true }
    },
    {
        zoneName="Gridania",
        zoneId = 132,
        aethernet = {
            aethernetZoneId = 133,
            aethernetName = "Leatherworkers' Guild & Shaded Bower",
            x=101, y=9, z=-112
        },
        retainerBell = { x=168.72, y=15.5, z=-100.06, requiresAethernet=true },
        scripExchange = { x=142.15, y=13.74, z=-105.39, requiresAethernet=true },
    },
    {
        zoneName="Ul'dah",
        zoneId = 130,
        aethernet = {
            aethernetZoneId = 131,
            aethernetName = "Sapphire Avenue Exchange",
            x=131.9447, y=4.714966, z=-29.800903
        },
        retainerBell = { x=148, y=3, z=-45, requiresAethernet=true },
        scripExchange = { x=148.39, y=3.99, z=-18.4, requiresAethernet=true },
    },
    {
        zoneName="Solution Nine",
        zoneId = 1186,
        aethernet = {
            aethernetZoneId = 1186,
            aethernetName = "Nexus Arcade",
            x=-161, y=-1, z=21
        },
        retainerBell = { x=-152.465, y=0.660, z=-13.557, requiresAethernet=true },
        scripExchange = { x=-158.019, y=0.922, z=-37.884, requiresAethernet=true }
    }
}

CharacterCondition = {
    normal=1,
    mounted=4,
    gathering=6,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDutyDiadem=34,
    occupiedMateriaExtractionAndRepair=39,
    gathering42=42,
    fishing=43,
    betweenAreas=45,
    jumping48=48,
    occupiedSummoningBell=50,
    jumping61=61,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

--#region Fishing
function InterpolateCoordinates(startCoords, endCoords, n)
    local x = startCoords.x + n * (endCoords.x - startCoords.x)
    local y = startCoords.y + n * (endCoords.y - startCoords.y)
    local z = startCoords.z + n * (endCoords.z - startCoords.z)
    return {waypointX=x, waypointY=y, waypointZ=z}
end

function GetWaypoint(coords, n)
    local total_distance = 0
    local distances = {}

    -- Calculate distances between each pair of coordinates
    for i = 1, #coords - 1 do
        local dx = coords[i + 1].x - coords[i].x
        local dy = coords[i + 1].y - coords[i].y
        local dz = coords[i + 1].z - coords[i].z
        local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
        table.insert(distances, distance)
        total_distance = total_distance + distance
    end

    -- Find the target distance
    local target_distance = n * total_distance

    -- Walk through the coordinates to find the target coordinates
    local accumulated_distance = 0
    for i = 1, #coords - 1 do
        if accumulated_distance + distances[i] >= target_distance then
            local remaining_distance = target_distance - accumulated_distance
            local t = remaining_distance / distances[i]
            return InterpolateCoordinates(coords[i], coords[i + 1], t)
        end
        accumulated_distance = accumulated_distance + distances[i]
    end

    -- If n is 1 (100%), return the last coordinate
    return { waypointX=coords[#coords].x, waypointY=coords[#coords].y, waypointZ=coords[#coords].z }
end

function SelectNewFishingHole()
    LogInfo("[FishingGatherer] Selecting new fishing hole")

    -- if SelectedFish.fishingSpots.waypoints ~= nil then
    SelectedFishingSpot = GetWaypoint(SelectedFish.fishingSpots.waypoints, math.random())
    SelectedFishingSpot.waypointY = QueryMeshPointOnFloorY(
        SelectedFishingSpot.waypointX, SelectedFish.fishingSpots.maxHeight, SelectedFishingSpot.waypointZ, false, 50)

    SelectedFishingSpot.x = SelectedFish.fishingSpots.pointToFace.x
    SelectedFishingSpot.y = SelectedFish.fishingSpots.pointToFace.y
    SelectedFishingSpot.z = SelectedFish.fishingSpots.pointToFace.z
    -- else
    --     local n = math.random(1, #SelectedFish.fishingSpots)
    --     SelectedFishingSpot = SelectedFish.fishingSpots[n]
    -- end
    SelectedFishingSpot.startTime = os.clock()
    SelectedFishingSpot.lastStuckCheckPosition = {
        x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()
    }
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

function TeleportToFishingZone()
    if not IsInZone(SelectedFish.zoneId) then
        TeleportTo(SelectedFish.closestAetheryte.aetheryteName)
    elseif not GetCharacterCondition(CharacterCondition.betweenAreas) then
        yield("/wait 3")
        SelectNewFishingHole()
        State = CharacterState.goToFishingHole
        LogInfo("[FishingGatherer] GoToFishingHole")
    end
end

function GoToFishingHole()
    if not IsInZone(SelectedFish.zoneId) then
        State = CharacterState.teleportToFishingZone
        LogInfo("[FishingGatherer] TeleportToFishingZone")
        return
    end

    -- if stuck for over 10s, adjust
    local now = os.clock()
    if now - SelectedFishingSpot.startTime > 10 then
        SelectedFishingSpot.startTime = now
        local x = GetPlayerRawXPos()
        local y = GetPlayerRawYPos()
        local z = GetPlayerRawZPos()
        local lastStuckCheckPosition = SelectedFishingSpot.lastStuckCheckPosition
        if GetDistanceToPoint(lastStuckCheckPosition.x, lastStuckCheckPosition.y, lastStuckCheckPosition.z) < 2 then
            LogInfo("[FishingGatherer] Stuck in same spot for over 10 seconds.")
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
            local randomX, randomY, randomZ = RandomAdjustCoordinates(x, y, z, 20)
            if randomX ~= nil and randomY ~= nil and randomZ ~= nil then
                PathfindAndMoveTo(randomX, randomY, randomZ, GetCharacterCondition(CharacterCondition.mounted))
            end
            return
        else
            SelectedFishingSpot.lastStuckCheckPosition = { x = x, y = y, z = z }
        end
    end

    if GetDistanceToPoint(SelectedFishingSpot.waypointX, GetPlayerRawYPos(), SelectedFishingSpot.waypointZ) > 10 then
        LogInfo("FishingGatherer] Too far from waypoint! Currently "..GetDistanceToPoint(SelectedFishingSpot.waypointX, GetPlayerRawYPos(), SelectedFishingSpot.waypointZ).." distance.")
        if not GetCharacterCondition(CharacterCondition.mounted) then
            Mount(CharacterState.goToFishingHole)
            LogInfo("State Change: Mounting")
        elseif not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("[FishingGatherer] Moving to waypoint: ("..SelectedFishingSpot.waypointX..", "..SelectedFishingSpot.waypointY..", "..SelectedFishingSpot.waypointZ..")")
            PathfindAndMoveTo(SelectedFishingSpot.waypointX, SelectedFishingSpot.waypointY, SelectedFishingSpot.waypointZ, true)
        end
        yield("/wait 1")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        LogInfo("[FishingGatherer] State Change: Dismount")
        return
    end

    State = CharacterState.fishing
    LogInfo("[FishingGatherer] State Change: Fishing")
end

function GoToResetFishingHole()
    AmissCount = 0
    local reset = SelectedFish.fishingSpots.reset
    if GetDistanceToPoint(reset.waypoint.x, reset.waypoint.y, reset.waypoint.z) > 30 and
        not GetCharacterCondition(CharacterCondition.mounted)
    then
        Mount()
        return
    elseif GetDistanceToPoint(reset.waypoint.x, reset.waypoint.y, reset.waypoint.z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(reset.waypoint.x, reset.waypoint.y, reset.waypoint.z, GetCharacterCondition(CharacterCondition.mounted))
        end
    elseif PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
    else
        State = CharacterState.resetFishingHole
        LogInfo("[FishingGatherer] State Change: ResetFishingHole")
    end
end

CastSuccess = false
function ResetFishingHole()
    if GetItemCount(29717) == 0 then
        State = CharacterState.buyFishingBait
        LogInfo("State Change: Buy Fishing Bait")
        return
    end

    if GetCharacterCondition(CharacterCondition.gathering) then
        CastSuccess = true
    elseif CastSuccess then
        CastSuccess = false
        SelectNewFishingHole()
        State = CharacterState.ready
    elseif not PathfindInProgress() and not PathIsRunning() then
        local pointToFace = SelectedFish.fishingSpots.reset.pointToFace
        PathMoveTo(pointToFace.x, pointToFace.y, pointToFace.z)
        return
    end
    yield("/ac Cast")
    yield("/wait 0.5")
end

AmissCount = 0
function Fishing()
    if GetItemCount(29717) == 0 then
        State = CharacterState.buyFishingBait
        LogInfo("State Change: Buy Fishing Bait")
        return
    elseif IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "The fish sense something amiss." then
        AmissCount = AmissCount + 1
        if AmissCount < 2 then
            State = CharacterState.goToFishingHole
            LogInfo("[FishingGatherer] State Change: Soft amiss")
        else
            State = CharacterState.amissReset
            LogInfo("[FishingGatherer] State Change: Hard amiss")
        end
        return
    end

    if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        LogInfo("[FishingGatherer] Not enough inventory space")
        if GetCharacterCondition(CharacterCondition.gathering) then
            yield("/ac Quit")
            yield("/wait 1")
        else
            State = CharacterState.turnIn
            LogInfo("State Change: TurnIn")
        end
        return
    end

    if os.clock() - SelectedFishingSpot.startTime > (SwitchLocationsAfter*60) then
        LogInfo("[FishingGatherer] Switching fishing spots")
        if GetCharacterCondition(CharacterCondition.gathering) then
            if not GetCharacterCondition(CharacterCondition.fishing) then
                yield("/ac Quit")
                yield("/wait 1")
            end
        else
            SelectNewFishingHole()
            State = CharacterState.ready
            LogInfo("[FishingGatherer] State Change: Timeout Ready")
        end
        return
    elseif GetCharacterCondition(CharacterCondition.gathering) then
        AmissCount = 0
        if (PathfindInProgress() or PathIsRunning()) then
            yield("/vnav stop")
        end
        yield("/wait 1")
        return
    end
    
    if os.clock() - SelectedFishingSpot.startTime > 10 then
        local x = GetPlayerRawXPos()
        local y = GetPlayerRawYPos()
        local z = GetPlayerRawZPos()
        local lastStuckCheckPosition = SelectedFishingSpot.lastStuckCheckPosition
        if GetDistanceToPoint(lastStuckCheckPosition.x, lastStuckCheckPosition.y, lastStuckCheckPosition.z) < 2 then
            LogInfo("[FishingGatherer] Stuck in same spot for over 10 seconds.")
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
            SelectNewFishingHole()
            State = CharacterState.ready
            LogInfo("[FishingGatherer] State Change: Stuck Ready")
            return
        else
            SelectedFishingSpot.lastStuckCheckPosition = { x = x, y = y, z = z }
        end
    end

    -- run towards fishing hole and cast until the fishing line hits the water
    if not PathfindInProgress() and not PathIsRunning() then
        PathMoveTo(SelectedFishingSpot.x, SelectedFishingSpot.y, SelectedFishingSpot.z)
        return
    end
    yield("/ac Cast")
    yield("/wait 0.5")
end

FishingBaitMerchant =
{
    npcName = "Merchant & Mender",
    x=-398, y=3, z=80,
    zoneId = 129,
    aetheryte = "Limsa Lominsa",
    aethernet = {
        name = "Arcanists' Guild",
        x=-336, y=12, z=56
    }
}
function BuyFishingBait()
    if GetItemCount(29717) >= 1 then
        if IsAddonVisible("Shop") then
            yield("/callback Shop true -1")
        else
            State = CharacterState.goToFishingHole
            LogInfo("State Change: GoToFishingHole")
        end
        return
    end

    if not IsInZone(FishingBaitMerchant.zoneId) then
        TeleportTo(FishingBaitMerchant.aetheryte)
        return
    end

    local distanceToMerchant = GetDistanceToPoint(FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z)
    local distanceViaAethernet = DistanceBetween(FishingBaitMerchant.aethernet.x, FishingBaitMerchant.aethernet.y, FishingBaitMerchant.aethernet.z, FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z)

    if distanceToMerchant > distanceViaAethernet + 20 then
        if not LifestreamIsBusy() then
            yield("/li "..FishingBaitMerchant.aethernet.name)
        end
        return
    end

    if IsAddonVisible("TelepotTown") then
        yield("/callback TelepotTown true -1")
        return
    end
    
    if distanceToMerchant > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(FishingBaitMerchant.x, FishingBaitMerchant.y, FishingBaitMerchant.z)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if not HasTarget() or GetTargetName() ~= FishingBaitMerchant.npcName then
        yield("/target "..FishingBaitMerchant.npcName)
        return
    end

    if IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("Shop") then
        yield("/callback Shop true 0 3 99 0")
    else
        yield("/interact")
    end
end

--#endregion Fishing

--#region Movement
function GetClosestAetheryte(x, y, z, zoneId, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    local zoneAetherytes = GetAetherytesInZone(zoneId)
    for i=0, zoneAetherytes.Count-1 do
        local aetheryteId = zoneAetherytes[i]
        local aetheryteRawPos = GetAetheryteRawPos(aetheryteId)
        LogInfo(aetheryteRawPos)
        local distanceAetheryteToPoint = DistanceBetween(aetheryteRawPos.Item1, y, aetheryteRawPos.Item2, x, y, z)
        local comparisonDistance = distanceAetheryteToPoint + teleportTimePenalty
        local aetheryteName = GetAetheryteName(aetheryteId)
        LogInfo("[FishingGatherer] Distance via "..aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            LogInfo("[FishingGatherer] Updating closest aetheryte to "..aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = {
                aetheryteId = aetheryteId,
                aetheryteName = aetheryteName
            }
        end
    end

    return closestAetheryte
end

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FishingGatherer] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[FishingGatherer] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
end

function Mount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        yield("/gaction jump")
    else
        yield('/gaction "mount roulette"')
    end
    yield("/wait 1")
end

function Dismount(callbackState)
    if PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.flying) or GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
    elseif GetCharacterCondition(CharacterCondition.normal) and callbackState ~= nil then
        State = callbackState
        LogInfo("[FishingGatherer] State Change: CallbackState")
    end
    yield("/wait 1")
end

function GoToHubCity()
    if not IsPlayerAvailable() then
        yield("/wait 1")
    elseif not IsInZone(SelectedHubCity.zoneId) then
        TeleportTo(SelectedHubCity.aetheryte)
    else
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    end
end

--#endregion Movement

--#region Collectables

function TurnIn()
    if GetItemCount(SelectedFish.fishId) == 0 then
        if IsAddonVisible("CollectablesShop") then
            yield("/callback CollectablesShop true -1")
        elseif GetItemCount(GathererScripId) >= ScripExchangeItem.price then
            State = CharacterState.scripExchange
            LogInfo("FishingGatherer] State Change: ScripExchange")
        else
            State = CharacterState.ready
            LogInfo("[FishingGatherer] State Change: Ready")
        end
    elseif not IsInZone(SelectedHubCity.zoneId) then
        State = CharacterState.goToHubCity
        LogInfo("State Change: GoToHubCity")
    elseif SelectedHubCity.scripExchange.requiresAethernet and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or
        GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) + 10) then
        if not LifestreamIsBusy() then
            yield("/li "..SelectedHubCity.aethernet.aethernetName)
        end
        yield("/wait 1")
    elseif IsAddonVisible("TelepotTown") then
        LogInfo("TelepotTown open")
        yield("/callback TelepotTown false -1")
    elseif GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("Path not running")
            PathfindAndMoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
        end
    elseif GetItemCount(GathererScripId) >= 3800 then
        if IsAddonVisible("CollectablesShop") then
            yield("/callback CollectablesShop true -1")
        else
            State = CharacterState.scripExchange
            LogInfo("State Change: ScripExchange")
        end
    else
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if not IsAddonVisible("CollectablesShop") or not IsAddonReady("CollectablesShop") then
            yield("/target Collectable Appraiser")
            yield("/wait 0.5")
            yield("/interact")
        else
            yield("/callback CollectablesShop true 12 "..SelectedFish.collectiblesTurnInListIndex)
            yield("/wait 0.1")
            yield("/callback CollectablesShop true 15 0")
            yield("/wait 1")
        end
    end
end

function ScripExchange()
    if GetItemCount(GathererScripId) < ScripExchangeItem.price then
        if IsAddonVisible("InclusionShop") then
            yield("/callback InclusionShop true -1")
        elseif GetItemCount(SelectedFish.fishId) > 0 then
            State = CharacterState.turnIn
            LogInfo("State Change: TurnIn")
        else
            State = CharacterState.ready
            LogInfo("State Change: Ready")
        end
    elseif not IsInZone(SelectedHubCity.zoneId) then
        State = CharacterState.goToHubCity
        LogInfo("State Change: GoToHubCity")
    elseif not LogInfo("[FishingGatherer] /li aethernet") and SelectedHubCity.scripExchange.requiresAethernet and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or
        GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) + 10) then
        if not LifestreamIsBusy() then
            yield("/li "..SelectedHubCity.aethernet.aethernetName)
        end
        yield("/wait 1")
    elseif not LogInfo("[FishingGatherer] close telepottown") and IsAddonVisible("TelepotTown") then
        LogInfo("TelepotTown open")
        yield("/callback TelepotTown false -1")
    elseif not LogInfo("[FishingGatherer] move to scrip exchange") and GetDistanceToPoint(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("Path not running")
            PathfindAndMoveTo(SelectedHubCity.scripExchange.x, SelectedHubCity.scripExchange.y, SelectedHubCity.scripExchange.z)
        end
    elseif not LogInfo("[FishingGatherer] check ShopExchangeItemDialog") and IsAddonVisible("ShopExchangeItemDialog") and IsAddonReady("ShopExchangeItemDialog") then
        yield("/callback ShopExchangeItemDialog true 0")
        yield("/wait 1")
    elseif not LogInfo("[FishingGatherer] check SelectIconString") and IsAddonVisible("SelectIconString") and IsAddonReady("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif not LogInfo("[FishingGatherer] check InclusionShop") and IsAddonVisible("InclusionShop") and IsAddonReady("InclusionShop") then
        yield("/callback InclusionShop true 12 "..ScripExchangeItem.categoryMenu)
        yield("/wait 1")
        yield("/callback InclusionShop true 13 "..ScripExchangeItem.subcategoryMenu)
        yield("/wait 1")
        yield("/callback InclusionShop true 14 "..ScripExchangeItem.listIndex.." "..math.min(99, GetItemCount(GathererScripId)//ScripExchangeItem.price))
    else
        not LogInfo("[FishingGatherer] target and interact with Scrip Exchange")
        yield("/wait 1")
        yield("/target Scrip Exchange")
        yield("/wait 0.5")
        yield("/interact")
    end
end

--#endregion Collectables

-- #region Other Tasks
function ProcessRetainers()
    LogInfo("[FishingGatherer] Handling retainers...")
    if not LogInfo("[FishingGatherer] check retainers ready") and not ARRetainersWaitingToBeProcessed() or GetInventoryFreeSlotCount() <= 1 then
        if IsAddonVisible("RetainerList") then
            if IsAddonReady("RetainerList") then
                yield("/callback RetainerList true -1")
            end
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            State = CharacterState.ready
            LogInfo("[FishingGatherer] State Change: Ready")
        end
    elseif not LogInfo("[FishingGatherer] is in hub city zone?") and
        not (IsInZone(SelectedHubCity.zoneId) or IsInZone(SelectedHubCity.aethernet.aethernetZoneId))
    then
        TeleportTo(SelectedHubCity.aetheryte)
    elseif not LogInfo("[FishingGatherer] use aethernet?") and
        SelectedHubCity.retainerBell.requiresAethernet and not LogInfo("abc") and (not IsInZone(SelectedHubCity.aethernet.aethernetZoneId) or
        (GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) > (DistanceBetween(SelectedHubCity.aethernet.x, SelectedHubCity.aethernet.y, SelectedHubCity.aethernet.z, SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) + 10)))
    then
        if not LifestreamIsBusy() then
            yield("/li "..SelectedHubCity.aethernet.aethernetName)
        end
        yield("/wait 1")
    elseif not LogInfo("[FishingGatherer] close telepot town") and IsAddonVisible("TelepotTown") then
        LogInfo("TelepotTown open")
        yield("/callback TelepotTown false -1")
    elseif not LogInfo("[FishingGatherer] move to summoning bell") and GetDistanceToPoint(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("Path not running")
            PathfindAndMoveTo(SelectedHubCity.retainerBell.x, SelectedHubCity.retainerBell.y, SelectedHubCity.retainerBell.z)
        end
    elseif PathfindInProgress() or PathIsRunning() then
        return
    elseif not HasTarget() or GetTargetName() ~= "Summoning Bell" then
        yield("/target Summoning Bell")
        return
    elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
        yield("/interact")
    elseif IsAddonReady("RetainerList") and IsAddonVisible("RetainerList") then
        yield("/ays e")
        if Echo == "All" then
            yield("/echo [FishingGatherer] Processing retainers")
        end
        yield("/wait 1")
    end
end

function ExecuteGrandCompanyTurnIn()
    if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        local playerGC = GetPlayerGC()
        local gcZoneIds = {
            129, --Limsa Lominsa
            132, --New Gridania
            130 --"Ul'dah - Steps of Nald"
        }
        if not IsInZone(gcZoneIds[playerGC]) then
            yield("/li gc")
            yield("/wait 1")
        elseif DeliverooIsTurnInRunning() then
            return
        else
            yield("/deliveroo enable")
        end
    else
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    end
end

function ExecuteRepair()
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
        LogInfo("[FishingGatherer] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = { x=-213.95, y=15.99, z=49.35 }
    if SelfRepair then
        if GetItemCount(33916) > 0 then
            if NeedsRepair(RepairAmount) then
                if not IsAddonVisible("Repair") then
                    LogInfo("[FishingGatherer] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.ready
                LogInfo("[FishingGatherer] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if not IsInZone(129) then
                if Echo == "All" then
                    yield("/echo Out of Dark Matter! Purchasing more from Limsa Lominsa.")
                end
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local darkMatterVendor = { npcName="Unsynrael", x=-257.71, y=16.19, z=50.11, wait=0.08 }
            if GetDistanceToPoint(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) > (DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z,darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif IsAddonVisible("TelepotTown") then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= darkMatterVendor.npcName then
                    yield("/target "..darkMatterVendor.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                elseif IsAddonVisible("SelectYesno") then
                    yield("/callback SelectYesno true 0")
                elseif IsAddonVisible("Shop") then
                    yield("/callback Shop true 0 40 99")
                end
            end
        else
            if Echo == "All" then
                yield("/echo Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to Limsa mender.")
            end
            SelfRepair = false
        end
    else
        if NeedsRepair(RepairAmount) then
            if not IsInZone(129) then
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end
            
            local mender = { npcName="Alistair", x=-246.87, y=16.19, z=49.83 }
            if GetDistanceToPoint(mender.x, mender.y, mender.z) > (DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z, mender.x, mender.y, mender.z) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif IsAddonVisible("TelepotTown") then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(mender.x, mender.y, mender.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(mender.x, mender.y, mender.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= mender.npcName then
                    yield("/target "..mender.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                end
            end
        else
            State = CharacterState.ready
            LogInfo("[FishingGatherer] State Change: Ready")
        end
    end
end

function ExecuteExtractMateria()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        LogInfo("[FishingGatherer] State Change: Dismounting")
        return
    end

    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        return
    end

    if CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        if not IsAddonVisible("Materialize") then -- open material window
            yield("/generalaction \"Materia Extraction\"")
            yield("/wait 1") -- give it a second to stick
            return
        end

        LogInfo("[FishingGatherer] Extracting materia...")
            
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
            LogInfo("[FishingGatherer] State Change: Ready")
        end
    end
end

function FoodCheck()
    --food usage
    if not HasStatusId(48) and Food ~= "" then
        yield("/item " .. Food)
    end
end

function PotionCheck()
    --pot usage
    if not HasStatusId(49) and Potion ~= "" then
        yield("/item " .. Potion)
    end
end

-- #endregion

function SelectFishTable()
    for _, fishTable in ipairs(FishTable) do
        if ScripColorToFarm == fishTable.scripColor then
            return fishTable
        end
    end
end

function Ready()
    FoodCheck()
    PotionCheck()

    if not LogInfo("[FishingGatherer] Ready -> IsPlayerAvailable()") and not IsPlayerAvailable() then
        -- do nothing
    elseif not LogInfo("[FishingGatherer] Ready -> Repair") and RepairAmount > 0 and NeedsRepair(RepairAmount) and
        (not shouldWaitForBonusBuff or (SelfRepair and GetItemCount(33916) > 0)) then
        State = CharacterState.repair
        LogInfo("[FishingGatherer] State Change: Repair")
    elseif not LogInfo("[FishingGatherer] Ready -> ExtractMateria") and ExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo("[FishingGatherer] State Change: ExtractMateria")
    elseif not LogInfo("[FishingGatherer] Ready -> ProcessRetainers") and
        Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1
    then
        State = CharacterState.processRetainers
        LogInfo("[FishingGatherer] State Change: ProcessingRetainers")
    elseif not LogInfo("GetInventoryFreeSlotCount() <= MinInventoryFreeSlots"..tostring(GetInventoryFreeSlotCount() <= MinInventoryFreeSlots)) and GetInventoryFreeSlotCount() <= MinInventoryFreeSlots and GetItemCount(SelectedFish.fishId) > 0 then
        State = CharacterState.turnIn
        LogInfo("State Change: TurnIn")
    elseif not LogInfo("[FishingGatherer] Ready -> GC TurnIn") and GrandCompanyTurnIn and
        GetInventoryFreeSlotCount() <= MinInventoryFreeSlots
    then
        State = CharacterState.gcTurnIn
        LogInfo("[FishingGatherer] State Change: GCTurnIn")
    elseif GetInventoryFreeSlotCount() <= MinInventoryFreeSlots and GetItemCount(SelectedFish.fishId) > 0 then
        State = CharacterState.goToHubCity
        LogInfo("[FishingGatherer] State Change: GoToSolutionNine")
    elseif GetItemCount(29717) == 0 then
        State = CharacterState.buyFishingBait
        LogInfo("State Change: Buy Fishing Bait")
    else
        State = CharacterState.goToFishingHole
        LogInfo("State Change: GoToFishingHole")
    end
end

CharacterState = {
    ready = Ready,
    teleportToFishingZone = TeleportToFishingZone,
    goToFishingHole = GoToFishingHole,
    extractMateria = ExecuteExtractMateria,
    repair = ExecuteRepair,
    exchangingVouchers = ExecuteBicolorExchange,
    processRetainers = ProcessRetainers,
    gcTurnIn = ExecuteGrandCompanyTurnIn,
    fishing = Fishing,
    turnIn = TurnIn,
    scripExchange = ScripExchange,
    goToHubCity = GoToHubCity,
    buyFishingBait = BuyFishingBait,
    amissReset = GoToResetFishingHole
}

StopMain = false
LastStuckCheckTime = os.clock()
LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}

if ScripColorToFarm == "Orange" then
    GathererScripId = OrangeGathererScripId
else
    GathererScripId = PurpleGathererScripId
end

for _, item in ipairs(ScripExchangeItems) do
    if item.itemName == ItemToExchange then
        ScripExchangeItem = item
    end
end
if ScripExchangeItem == nil then
    yield("/echo Cannot recognize item "..ItemToExchange..". Stopping script.")
    yield("/snd stop")
end

SelectedFish = SelectFishTable()

if SelectedFish.fishingSpots.waypoints == nil then
    SelectedFish.closestAetheryte = GetClosestAetheryte(
            SelectedFishingSpot.waypointX,
            SelectedFishingSpot.waypointY,
            SelectedFishingSpot.waypointZ,
            SelectedFish.zoneId,
            0)
else
    SelectedFish.closestAetheryte = GetClosestAetheryte(
            SelectedFish.fishingSpots.waypoints[1].x,
            SelectedFish.fishingSpots.waypoints[1].y,
            SelectedFish.fishingSpots.waypoints[1].z,
            SelectedFish.zoneId,
            0)
end

if IsInZone(SelectedFish.zoneId) then
    SelectNewFishingHole()
end

yield("/ahon")
DeleteAllAutoHookAnonymousPresets()
UseAutoHookAnonymousPreset(SelectedFish.autohookPreset)

for _, city in ipairs(HubCities) do
    if city.zoneName == HubCity then
        SelectedHubCity = city
        SelectedHubCity.aetheryte = GetAetheryteName(GetAetherytesInZone(city.zoneId)[0])
    end
end
if SelectedHubCity == nil then
    yield("/echo Could not find hub city: "..HubCity)
    yield("/vnav stop")
end

if GetClassJobId() ~= 18 then
    yield("/gs change Fisher")
    yield("/wait 1")
end

State = CharacterState.ready
while not StopMain do
    State()
    yield("/wait 0.1")
end
