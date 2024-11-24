--[[
********************************************************************************
*                            Fishing Gatherer Scrips                            *
*                                Version 1.0.0                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
Loosely based on Ahernika's NonStopFisher

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

FishToFarm = "Zorgor Condor"
SwitchLocationsAfter                = 10        --Number of minutes to fish at this spot before changing spots.

Retainers                           = true      --If true, will do AR (autoretainers)
GrandCompanyTurnIn                  = true      --If true, will do GC deliveries using deliveroo everytime retainers are processed
ReturnToGCTown                      = true      --if true will use fast return to GC town for retainers and scrip exchange (that assumes you set return location to your gc town else turn it false), else falase
--needs a yesalready set up like "/Return to New Gridania/"

Food                            = ""            --what food to eat (false if none)
Potion                          = "Superior Spiritbond Potion <hq>"     --what potion to use (false if none)

--things you want to enable
ExtractMateria                      = true      --If true, will extract materia if possible
ReduceEphemerals                    = true      --If true, will reduce ephemerals if possible
Repair                              = true      --If true, will do repair if possible set repair amount below
RepairAmount                        = 1         --repair threshold, adjust as needed

MinInventoryFreeSlots               = 1           --set !!!carefully how much inventory before script stops gathering and does additonal tasks!!!

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

--vnav x,y,z cordinates of bell and zoneid of location city (shown below are examples for 3 GC cities and solution 9
RetainerBellLocations                       = {  --paths to retainer bell, leave it as it is unless you edit functions below aswell
    { x=-124.703, y=18.00, z=19.887, zoneId=129, zoneName="Limsa Lominsa" }, -- Path to Retainer Bells
    { x=168.72, y=15.5, z=-100.06, zoneId=132, zoneName="Gridania" },
    { x=146.760, y=4, z=-42.992, zoneId=130, zoneName="Ul'dah" },
    { x=-152.465, y=0.660, z=-13.557, zoneId=1186, zoneName="Solution Nine" } --Path to bell in solution 9 in this example/4th location
}

OrangeGathererScripId = 41785
SolutionNineZoneId = 1186

--vnav x,y,z cordinates of collectable appraiser and zoneid of location city (shown below are examples for 3 GC cities and solution 9
ScripExchangeLocations                    = {     --paths to scrip exchnage, leave it as it is unless you edit functions below aswell
    { -258.09,  16.079, 42.089,  129 },   -- Path to Scrip Exchange/Collectable Appraiser
    { 142.15,   13.74,  -105.39, 132 },
    { 149.349,  4,      -18.722, 130 },
    { -158.019, 0.922,  -37.884, 1186, 1186 } -- vnav cordinates for the 4th additional location appraiser (here one in solution 9)/4th location

}

FishTable =
{
    {
        fishName = "Zorgor Condor",
        fishId = 43761,
        baitName = "Versatile Lure",
        zoneId = 1190,
        zoneName = "Shaaloani",
        autohookPreset = "AH4_H4sIAAAAAAAACu1Yy27jNhT9FVdrs5BI6pWdx03SFHlh7LZAB11QEmUTkUUPRc0kHeTfe6mHLdlSggy8aAfZSZeX5z50eEjqmzUrtZyzQhfzdGWdfbPOcxZlfJZl1plWJZ9aZvBa5Hw/mLRDV/CEg3Bq3SshldBP1pkD1uL8Mc7KhCd7s/F/rrFupIzXBqx6wOapwvGCqXW5Xa4VL9YyA4tj2z3kl6ErjNDvzbBfTWa+LjdtBtSx6SsptLNklvFYj3QEcJzuLPx6FlIlgmUjeA72vF6PaTPtQhTr8ydedApwDwpw3V4BXvsN2ANfrEWqPzBRlWEMRWtYaBY/ACqANV/mGLeLGjao90wLnse8k493OM/rNxS3U5X4h8+ZrpkxRDNI4hAMH3wd0oAt1ywT7KG4YF+kMng9Q1sdmfbtH3ksv3Dwd0zPRlKgvYBtOz+I1SXbVHXP8lXGVdEGwfVU4tv0KPseVPAMWOePWrFmHZoPsZSLr2x7letSaCHzSybytrcIKHZdKn7Di4KtILRlTa3bKgnrVsJqndYIT1uwmMYM4F3LQn833j0UwocztJA1Ml5HrMb3+Sy2sJYUy+alUjzXJ6ryAPVktQ5me1TxYPTK60KqmCcGv1EsBzSrZs1Cy61Z0yJfLTTfVmK6L6hh1kydpo4uXJXY77n4XHKDa3nYT2MapyhgHkYUpxRFzImQhwnzIkqdhAYW4F2LQt+lJgZQ/VPNWVPATtPr6sZy/APig2RkfGI8DOCtVBuW/Srlg4Fo9eRPzqp3Y4f8d0szZVkBa7N+bwZNae2ibUx1/dTxjU61mAutZN7Z8EamL8WGqwMtuBH5bgi+UfizfRTKJp1Q13zF84SppxPUUAH/IktwPuhK7YG9cOewL3HUZSi1rtdSie1YJN/FZOcyFqvn9EK0xs+sgFmquZqzcrWGY8fGbE9A86GlUR1MgDjV/mceOso+Z9D4bKY132x120vjs2RqxWvMuzx7qjCMqfUZ0H3iu+HxweCFTd2cRlrFa7n8kX8uheIJ5KhLs7ea484IwV8h7Fu59s6dt3HnRBTo6CkJnQQ000a+Z6eIJoShyPNjFNMEE9sLQtdNQf6OBZSSwCXjAjpnsS6ZmvwmVv9r9bxhjx0boe+K+q6o74r64+zGJ5BQl0ReEiQMMea6iLqxgwLic+S7HrGDNCIYu9bz3+2ZtPnJ8GlnqFUVzqh9eYWkxuX1L6lWUk0WsVRb2Mp7x2nnpf5cJXDmFzEc/6EpJljtMNvIMu+5QQpueHgxJP07e2AilSplILuZ0dfhnw5u6L5yPXYB6D/z82V/r/nu24yZbCxz09Wqod37TXOrMY+1ee82RN8O1TBs0NjlHuJ2QhANKUWM2Bylse8kkR07Dg+r3fqASt5RAbPJV4jBk0mxZon8OlGi4MUkVXIDAxriT/SaTzZA0J+OWDeXeQJ/L07NuWHqvJ2C75w7KeccO4p4GjLEU+7ACRGewoS6iPGI2JFtc9umg5yzX7hes5ViuZ4AIWKW9NfPu3z9sPIVBzhNOXERpyFQKQowYiGOUBhHoRuHQcqwV+2UNW5fddDkDjiz4rDpwSGh/1fIsTH2/MRHHoF/QZTwBDEvSBHzI+ambkpxHFnP/wJPKLbAUhgAAA==",
        fishingSpots = {
            { waypointX=200.699, waypointY=12.000, waypointZ=735.425, x=197.205, y=11.194, z=750.186 },
            { waypointX=114.894, waypointY=5.233,  waypointZ=711.255, x=120.631, y=5.295,  z=724.759 },
            { waypointX=69.043,  waypointY=-0.889, waypointZ=727.032, x=75.741,  y=-1.648, z=737.941 },
            { waypointX=10.366,  waypointY=-5.563, waypointZ=743.747, x=12.425,  y=-7.169, z=756.219 }
        },
        collectiblesTurnInListIndex = 6,
        collectiblesTurnInScripId = 39
    },
    {
        fishName = "Fleeting Brand",
        fishId = 36473,
        baitName = "Versatile Lure",
        zoneId = 959,
        zoneName = "Mare Lamentorum",
        autohookPreset = "AH4_H4sIAAAAAAAACu1YTW/bOBD9K4ZOu6hVSLQ+c3PcJGvASYM42R6KPdASZRORRZeisvEW+e87I4m2ZMtxUSRBDrnJQ/LN4/BxOOOfxrBQYkRzlY+SuXHy0zjL6CxlwzQ1TpQsWN/AwQnP2HYw1kNj+CJB2DeuJReSq7VxYoM1P3uM0iJm8daM858qrEshogWClR8Ev0ocL+gbF6vbhWT5QqRgsS2rhfw8dIkR+q0V1lEyo0Wx1Awc23KOUNCrRJqySB2ICODYzVXkOAshY07Tkkj2wKQ2tCf3u5zZxPPCHdZOm3V7U8OZeICzTGiaa/fnPF+crVneCIS7A+m6LUhPnyW9Z9MFT9Qp5WU40JBrw1TR6B5QAaw+4X3cJmpYo15TxVkWHVIc0PN2Ybz2ORGNJPl/bERVJThNYnc12TnlQb36dkFTTu/zc/ogJAK0DHp3g37bfsMiiDDMtzFmXTcGKOwKbdAioMN7yucXdFnGYZjNUyZz7RQ1hct8y9nbTQsqeAKss0claX2/8WBuxfRfuhpnquCKi+yC8kzHxwTpTgrJLlme0zm4Noy+cVWSMK4EZIF+hbBegQUD1YE3Ebn6bbxr2AjrZmiYxoHxymM5vuUzXcEdlTQdFVKyTL3QLndQX2yvnWz3dtzpvZxVCWSqxAqvM8/mU8VWZT7ecq9FNJQvQ7kJV3K4y/iPgiGuEbNZFHiebVqhZ5kOtTwzCOPYtL0k8mN/4FlObADehOfqa4I+QNXfK3niBjb3NfRt/zDHv8E/ZIuU9XAGAl4JuaTpX0LcI4ROJd8YLX+jHfhvbmWZBvUtrQdxa/q+oumWL5ncuceXPNsM4dP0GThe0semLfwM17+GrOLn2D6mOM1pqqTIGm/u67u3Bg33EzZnWUzl+h3EpST2RRQAdeSkXtQx8cKN3+1pvJqLX4n4Kzi/lXz1xnH1XTLYeH6tyLacvH1sa/eYcYeJYnJEi/kCKuUlVkKQVrtScVlLQ6IqSy38aBQR1Xvuhvs1aPtBf6aaxDJYP4k6A96wHwWXLAZPqsBiDOvsrrT4+mnuTbPZR3b6yE4f2emdZadGgRj4URJDiWiSwKWmMwgjM5gR13TCBEfiwGeu8fSPrhDrfw2+bwxVkQgVY7NaHHiOPzhcLZ6njCnYce9U0ixu1bb2wWBhFzeOodjmEdTdECJ09jVL13c5u8tiJrftqv7DBFcPl6LIGgHvamTdcLd5G6C3LyJTIwqIab3r+v3axjNAtoVMKKTXFKuyunF3Q/dIb+vCynfzD8y2M/ntfgQXo2WE0S4D3exQ6r4EPyvzdtr+BbBa+vQJvO9BMjMTZ0ZMh9mBGbhBaBKPJGzmkDDyEug39vXnHt7BDZsLJXjOflF6dofyutX1nJyelU23LDtVdFyWH+o6rK6WuAgJaEzcmclIAuIicWDSxEtMj0YW9ZlHgmBWJr9KtbV8vi24Yr1pBAVv3vtj2/p+6rUT2yedkXrj8Z87bblj+Y7jBqYboOMoCU3qObHpxzRMZqBp27aNp/8BcyShAhYWAAA=",
        fishingSpots = {
            {waypointX = 15.25, waypointY = 23.72, waypointZ = 459.84, x = 13.53, y = 22.93, z = 463.75},
            {waypointX = 26.27, waypointY = 22.11, waypointZ = 468.88, x = 23.14, y = 21.73, z = 472.73},
            {waypointX = 34.51, waypointY = 21.7, waypointZ = 481.15, x = 30.27, y = 21.69, z = 482.1},
            {waypointX = 44.03, waypointY = 21.75, waypointZ = 482.86, x = 45.16, y = 21.64, z = 487.06}
        },
        collectiblesTurnInListIndex = 10,
        collectiblesTurnInScripId = 38
    },
    {
        fishName = "Goldgrouper",
        fishId = 43775,
        collectiblesTurnInScripId = 39
    }
}

ScripExchangeItem =
{
    scripExchangeMenu1=4,
    scripExchangeMenu2=8,
    scripExchangeRow=6,
    scripExchangePrice=1000
}

MinInventoryFreeSlots = 1
TimeoutThreshold                 = 10  --certain functions timeout and close if they don't work as intended due to some reason, after this period
FishingTimeoutThreshold          = 15  --how long to wait for current fishing attemp to be completed before trying to disable AH
MinWaitTime                     = 400 --(in seconds) set a carefully min wait before to switch fishing spot, (its anti pool limit movement wait time, setting value as 60 is what what i tested (i.e 1min)) how frequently you want to swap fishing spots to avoid fish being aware of your presence
MaxWaitTime                     = 900 --(in seconds) set a carefully max wait before to switch fishing spot

CharacterCondition = {
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
    jumping61=61,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

--#region Fishing

function SelectNewFishingHole()
    local n = math.random(1, #SelectedFish.fishingSpots)
    SelectedFishingSpot = SelectedFish.fishingSpots[n]
    SelectedFishingSpot.startTime = os.clock()
end

function GoToFishingHole()
    if not IsInZone(SelectedFish.zoneId) then
        TeleportTo(SelectedFish.closestAetheryte.aetheryteName)
        return
    end

    if GetDistanceToPoint(SelectedFishingSpot.waypointX, SelectedFishingSpot.waypointY, SelectedFishingSpot.waypointZ) > 1 then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.mounting
            LogInfo("State Change: Mounting")
        elseif not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(SelectedFishingSpot.waypointX, SelectedFishingSpot.waypointY, SelectedFishingSpot.waypointZ, true)
        end
        yield("/wait 1")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("State Change: Dismount")
        return
    end

    State = CharacterState.fishing
    LogInfo("State Change: Fishing")
end

function Fishing()
    if GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        if GetCharacterCondition(CharacterCondition.fishing) then
            yield("/ac Quit")
            yield("/wait 1")
            SelectedFishingSpot = SelectNewFishingHole()
        else
            State = CharacterState.turnIn
            LogInfo("State Change: TurnIn")
        end
        return
    end

    if (SelectedFishingSpot.startTime + (SwitchLocationsAfter*60)) < os.clock() then
        if GetCharacterCondition(CharacterCondition.fishing) then
            yield("/ac Quit")
            yield("/wait 1")
        end
        SelectedFishingSpot = SelectNewFishingHole()
        State = CharacterState.goToFishingHole
        LogInfo("State Change: GoToFishingHole")
        return
    end

    if GetDistanceToPoint(SelectedFishingSpot.x, SelectedFishingSpot.y, SelectedFishingSpot.z) > 1 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(SelectedFishingSpot.x, SelectedFishingSpot.y, SelectedFishingSpot.z)
        end
        return
    end

    if GetCharacterCondition(CharacterCondition.fishing) then
        if (PathfindInProgress() or PathIsRunning()) then
            yield("/vnav stop")
        end
        yield("/wait 1")
        return
    end

    yield("/bait "..SelectedFish.baitName)
    yield("/wait 0.1")
    yield("/ac Cast")
end

function BuyFishingBait()
    if GetItemCount(30279) >= 30 and GetItemCount(30280) >= 30 and GetItemCount(30281) >= 30 then
        if IsAddonVisible("Shop") then
            yield("/callback Shop true -1")
        else
            State = CharacterState.goToFishingHole
            LogInfo("State Change: MoveToNextNode")
        end
        return
    end

    if not HasTarget() or GetTargetName() ~= Mender.npcName then
        yield("/target "..Mender.npcName)
        yield("/wait 1")
        if not HasTarget() or GetTargetName() ~= Mender.npcName then
            LeaveDuty()
        end
        return
    end

    if GetDistanceToPoint(Mender.x, Mender.y, Mender.z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Mender.x, Mender.y, Mender.z)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("Shop") then
        if GetItemCount(30279) < 30 then
            yield("/callback Shop true 0 4 99 0")
        elseif GetItemCount(30280) < 30 then
            yield("/callback Shop true 0 5 99 0")
        elseif GetItemCount(30281) < 30 then
            yield("/callback Shop true 0 6 99 0")
        end
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
        LogInfo("[OrangeGatherer] Distance via "..aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            LogInfo("[OrangeGatherer] Updating closest aetheryte to "..aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = {
                aetheryteId = aetheryteId,
                aetheryteName = aetheryteName
            }
        end
    end

    yield("/echo e")

    return closestAetheryte
end

function Mount()
    if GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.goToFishingHole
        LogInfo("[FATE] State Change: Moving")
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield("/gaction jump")
    else
        yield('/gaction "mount roulette"')
    end
    yield("/wait 1")
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

function Dismount()
    if PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.flying) then
        yield("/e is flying")
        yield('/ac dismount')
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
    else
        State = CharacterState.fishing
        LogInfo("State Change: Fishing")
    end
    yield("/wait 1")
end

function GoToSolutionNine()
    if not IsPlayerAvailable() then
        yield("/wait 1")
    elseif not IsInZone(SolutionNineZoneId) then
        TeleportTo("Solution Nine")
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > (DistanceBetween(Npcs.aethernetShortcut.x, Npcs.aethernetShortcut.y, Npcs.aethernetShortcut.z, Npcs.x, Npcs.y, Npcs.z) + 10) then
        yield("/li nexus arcade")
        yield("/wait 1") -- give it a moment to register
    elseif IsAddonVisible("TelepotTown") then
        LogInfo("TelepotTown open")
        yield("/callback TelepotTown false -1")
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("Path not running")
            PathfindAndMoveTo(Npcs.x, Npcs.y, Npcs.z)
        end
    else
        State = CharacterState.turnIn
        LogInfo("State Change: TurnIn")
    end
end

--#endregion Movement

--#region Collectables
Npcs =
{
    turnInNpc = "Collectable Appraiser",
    scripExchangeNpc = "Scrip Exchange",
    x=-157.96, y=0.92, z=-38.06,
    aethernetShortcut = { x=-157.74, y=0.29, z=17.43 }
}

function TurnIn()
    if (not IsInZone(SolutionNineZoneId)) or (GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1) then
        State = CharacterState.goToSolutionNine
        LogInfo("State Change: Go to Solution Nine")
    elseif GetItemCount(OrangeGathererScripId) >= 3800 then
        if IsAddonVisible("CollectablesShop") then
            yield("/callback CollectablesShop true -1")
        else
            State = CharacterState.scripExchange
            LogInfo("State Change: ScripExchange")
        end
    elseif GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Npcs.x, Npcs.y, Npcs.z)
        end
    else
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if not IsAddonVisible("CollectablesShop") then
            yield("/target "..Npcs.turnInNpc)
            yield("/wait 0.5")
            yield("/interact")
            yield("/wait 1")
            yield("/callback CollectablesShop true 12 "..SelectedFish.collectiblesTurnInListIndex)
        elseif GetItemCount(SelectedFish.fishId) == 0 then
            yield("/callback CollectablesShop true -1")
            State = CharacterState.goToFishingHole
            LogInfo("State Change: Move to Fishing")
        else
            yield("/callback CollectablesShop true 15 0")
            yield("/wait 1")
        end
    end
end

function ScripExchange()
    if GetItemCount(OrangeGathererScripId) < 3800 then
        if IsAddonVisible("InclusionShop") then
            yield("/callback InclusionShop true -1")
        else
            State = CharacterState.goToFishingHole
            LogInfo("State Change: GoToFishingHole")
        end
    elseif not IsInZone(SolutionNineZoneId) or GetDistanceToPoint(Npcs.x, Npcs.y, Npcs.z) > 1 then
        State = CharacterState.goToSolutionNine
        LogInfo("State Change: Go to Solution Nine")
    elseif IsAddonVisible("ShopExchangeItemDialog") then
        yield("/callback ShopExchangeItemDialog true 0")
        yield("/wait 1")
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("InclusionShop") then
        -- yield("/callback InclusionShop true 12 1")
        -- yield("/wait 1")
        -- yield("/callback InclusionShop true 13 10")
        -- yield("/wait 1")
        -- yield("/callback InclusionShop true 14 0 "..GetItemCount(OrangeCrafterScripId)//125)
        yield("/callback InclusionShop true 12 "..ScripExchangeItem.scripExchangeMenu1)
        yield("/wait 1")
        yield("/callback InclusionShop true 13 "..ScripExchangeItem.scripExchangeMenu2)
        yield("/wait 1")
        yield("/callback InclusionShop true 14 "..ScripExchangeItem.scripExchangeRow.." "..GetItemCount(OrangeGathererScripId)//ScripExchangeItem.scripExchangePrice)
    else
        yield("/wait 1")
        yield("/target "..Npcs.scripExchangeNpc)
        yield("/wait 0.5")
        yield("/interact")
    end
end

--#endregion Collectables

-- #region Other Tasks
function ExecuteGrandCompanyTurnIn()
    if GetInventoryFreeSlotCount() < MinInventoryFreeSlots then
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
        LogInfo("[FATE] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = { x=-213.95, y=15.99, z=49.35 }
    if SelfRepair then
        if GetItemCount(33916) > 0 then
            if IsAddonVisible("Shop") then
                yield("/callback Shop true -1")
                return
            end

            if not IsInZone(SelectedFish.zoneId) then
                TeleportTo(SelectedFish.aetheryteList[1].aetheryteName)
                return
            end

            if GetCharacterCondition(CharacterCondition.mounted) then
                Dismount()
                LogInfo("[FATE] State Change: Dismounting")
                return
            end

            if NeedsRepair(RepairAmount) then
                if not IsAddonVisible("Repair") then
                    LogInfo("[FATE] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.ready
                LogInfo("[FATE] State Change: Ready")
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
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

function ExecuteExtractMateria()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        LogInfo("[FATE] State Change: Dismounting")
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

        LogInfo("[FATE] Extracting materia...")
            
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
        if FishToFarm == fishTable.fishName then
            return fishTable
        end
    end
end

function Ready()
    FoodCheck()
    PotionCheck()

    if not LogInfo("[FATE] Ready -> IsPlayerAvailable()") and not IsPlayerAvailable() then
        -- do nothing
    elseif not LogInfo("[FATE] Ready -> Repair") and RepairAmount > 0 and NeedsRepair(RepairAmount) and
        (not shouldWaitForBonusBuff or (SelfRepair and GetItemCount(33916) > 0)) then
        State = CharacterState.repair
        LogInfo("[FATE] State Change: Repair")
    elseif not LogInfo("[FATE] Ready -> ExtractMateria") and ExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo("[FATE] State Change: ExtractMateria")
    elseif not LogInfo("[FATE] Ready -> ProcessRetainers") and WaitingForCollectionsFate == 0 and
        Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1  and not shouldWaitForBonusBuff
    then
        State = CharacterState.processRetainers
        LogInfo("[FATE] State Change: ProcessingRetainers")
    elseif GetInventoryFreeSlotCount() <= MinInventoryFreeSlots then
        State = CharacterState.turnIn
        LogInfo("State Change: TurnIn")
    elseif not LogInfo("[FATE] Ready -> GC TurnIn") and GrandCompanyTurnIn and
        GetInventoryFreeSlotCount() < MinInventoryFreeSlots
    then
        State = CharacterState.gcTurnIn
        LogInfo("[FATE] State Change: GCTurnIn")
    else
        State = CharacterState.goToFishingHole
        LogInfo("State Change: MoveToWaypoint")
    end
end

CharacterState = {
    ready = Ready,
    mounting = Mount,
    dismounting = Dismount,
    goToFishingHole = GoToFishingHole,
    extractMateria = ExecuteExtractMateria,
    repair = ExecuteRepair,
    exchangingVouchers = ExchangeVouchers,
    processRetainers = ProcessRetainers,
    gcTurnIn = ExecuteGrandCompanyTurnIn,
    fishing = Fishing,
    turnIn = TurnIn,
    scripExchange = ScripExchange,
    goToSolutionNine = GoToSolutionNine
}

StopMain = false
LastStuckCheckTime = os.clock()
LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}

SelectedFish = SelectFishTable()
if SelectedFish == nil then
    yield("/echo Cannot find data for "..FishToFarm)
    StopMain = true
end
SelectedFish.closestAetheryte = GetClosestAetheryte(
            SelectedFish.fishingSpots[1].x,
            SelectedFish.fishingSpots[1].y,
            SelectedFish.fishingSpots[1].z,
            SelectedFish.zoneId,
            0)
yield("/ahon")
UseAutoHookAnonymousPreset(SelectedFish.autohookPreset)

SelectNewFishingHole()
State = CharacterState.ready
while not StopMain do
    State()
    yield("/wait 0.1")
end
