UseFood = false
FoodKind = "Sideritis Cookie <HQ>"
RemainingFoodTimer = 5 -- This is in minutes
-- If you would like to use food while in diadem, and what kind of food you would like to use. 
-- With the suggested TeamCraft melds, Sideritis Cookies (HQ) are the best ones you can be using to get the most bang for your buck
-- Can also set it to where it will refood at a certain duration left
-- Options
    -- UseFood : true | false (default is true)
    -- FoodKind : "Sideritis Cookie" (make sure to have the name of the food IN the "")
    -- RemainingFoodTimer : Default is 5, time is in minutes

FoodTimeout = 5 
-- How many attempts would you like it to try and food before giving up?
-- The higher this is, the longer it's going to take. Don't set it below 5 for safety. 

RouteType = "PinkRoute"
-- Select which route you would like to do. 
    -- Options are:
        -- "RedRoute"     -> MIN perception route, 8 node loop
        -- "PinkRoute"    -> BTN perception route, 8 node loop
        -- "MinerIslands" -> MIN

GatheringSlot = 4
-- This will let you tell the script WHICH item you want to gather. (So if I was gathering the 4th item from the top, I would input 4)
-- This will NOT work with Pandora's Gathering, as a fair warning in itself. 
-- Options : 1 | 2 | 3 | 4 | 7 | 8 (1st slot... 2nd slot... ect)

TargetOption = 1
-- This will let you tell the script which target to use Aethercannon.
-- Options : 0 | 1 | 2 | 3 (Option: 0 is don't use cannon, Option: 1 is any target, Option: 2 only sprites, Option: 3 is don't include sprites)

PrioritizeUmbral = true

CapGP = true 
-- Bountiful Yield 2 (Min) | Bountiful Harvest 2 (Btn) [+x (based on gathering) to that hit on the node (only once)]
-- If you want this to let your gp cap between rounds, then true 
-- If you would like it to use a skill on a node before getting to the final one, so you don't waste GP, set to false

BuffYield2 = true -- Kings Yield 2 (Min) | Bountiful Yield 2 (Btn) [+2 to all hits]
BuffGift2 = true -- Mountaineer's Gift 2 (Min) | Pioneer's Gift 2 (Btn) [+30% to perception hit]
BuffGift1 = true -- Mountaineer's Gift 1 (Min) | Pioneer's Gift 1 (Btn) [+10% to perception hit]
BuffTidings2 = true -- Nald'thal's Tidings (Min) | Nophica's Tidings (Btn) [+1 extra if perception bonus is hit]
-- Here you can select which buffs get activated whenever you get to the mega node (aka the node w/ +5 Integrity) 
-- These are all togglable with true | false 
-- They will go off in the order they are currently typed out, so keep that in mind for GP Usage if that's something you want to consider

Repair_Amount = 99
Self_Repair = true --if its true script will try to self reapair
Npc_Repair = false --if its true script will try to go to mender npc and repair
--When do you want to repair your own gear? From 0-100 (it's in percentage, but enter a whole value

PlayerWaitTime = true 
-- this is if you want to make it... LESS sus on you just jumping from node to node instantly/firing a cannon off at an enemy and then instantly flying off
-- default is true, just for safety. If you want to turn this off, do so at your own risk. 

AntiStutterOpen = false
AntiStutter = 2
-- default is 2 gathering loops this will execute the script again if you are having stutter issues 
-- WARNING your macro name should be DiademV2

debug = false
-- This is for debugging 

--[[

***************************
* Setting up values here  *
***************************

]]

--script Started echo for debug
if debug then
    yield("/e ------------STARTED------------")
end

--#region Gathering Nodes

UmbralWeatherNodes = {
    flare = {
        weatherName = "Umbral Flare",
        weatherId = 133,
        gatheringNode =
            {
                itemName = "Grade 4 Skybuilders' Umbral Flarerock",
                x = -429.93103, y = 330.51987, z = -593.2373,
                nodeName = "Clouded Mineral Deposit",
                class = "Miner"
            },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Crimson Namitaro",
            baitName = "Diadem Crane Fly",
            baitId = 30280,
            x = 370.88373, y = 255.67848, z = 525.73334,
            fishingX = 372.4, fishingY = 254.99, fishingZ = 521.72
        }
    },
    duststorms = {
        weatherName = "Umbral Duststorms",
        weatherId = 134,
        gatheringNode =
            {
                itemName = "Grade 4 Skybuilders' Umbral Dirtleaf",
                x = 384.0722, y = 294.2122, z = 583.4051,
                nodeName = "Clouded Lush Vegetation Patch",
                class = "Botanist"
            },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Marrella",
            baitName = "Diadem Hoverworm",
            baitId = 30281,
            x = 589.74, y = 188.42, z = -591.81,
            fishingX=593.08, fishingY=187.17, fishingZ=-594.61
        }
    },
    levin = {
        weatherName = "Umbral Levin",
        weatherId = 135,
        gatheringNode =
            {
                itemName = "Grade 4 Skybuilders' Umbral Levinsand",
                x = 620.3156, y = 252.7179, z = -397.3386,
                nodeName = "Clouded Rocky Outcrop",
                class = "Miner"
            },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Meganeura",
            baitName = "Diadem Red Balloon", -- mooched from Grade 4 Skybuilders' Ghost Faerie
            baitId = 30279,
            x = 358.22882, y = -285.27814, z = 87.26572,
            fishingX = 351.93, fishingY = -286.31, fishingZ = 83.93
        }
    },
    tempest = {
        weatherName = "Umbral Tempest",
        weatherId = 136,
        gatheringNode =
            {
                itemName = "Grade 4 Skybuilders' Umbral Galewood",
                x = -604.29, y = 333.82, z=442.46,
                nodeName = "Clouded Mature Tree",
                class = "Botanist"
            },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Griffin",
            baitName = "Diadem Hoverworm", -- mooched from Grade 4 Skybuilders' Ghost Faerie
            baitId = 30281,
            x = -437.75, y = -207.36, z = 191.91,
            fishingX = -437.06, fishingY = -207.31, fishingZ = 196.36
        }
    }
}

if RouteType == "MinerIslands" then
    GatheringRoute =
        {
            {x = -570.90, y = 45.80, z = -242.08, nodeName = "Mineral Deposit"},
            {x = -512.28, y = 35.19, z = -256.92, nodeName = "Mineral Deposit"},
            {x = -448.87, y = 32.54, z = -256.16, nodeName = "Mineral Deposit"},
            {x = -403.11, y = 11.01, z = -300.24, nodeName = "Rocky Outcrop"}, -- Fly Issue #1
            {x = -363.65, y = -1.19, z = -353.93, nodeName = "Rocky Outcrop"}, -- Fly Issue #2
            {x = -337.34, y = -0.38, z = -418.02, nodeName = "Mineral Deposit"},
            {x = -290.76, y = 0.72, z = -430.48, nodeName = "Mineral Deposit"},
            {x = -240.05, y = -1.41, z = -483.75, nodeName = "Mineral Deposit"},
            {x = -166.13, y = -0.08, z = -548.23, nodeName = "Mineral Deposit"},
            {x = -128.41, y = -17.00, z = -624.14, nodeName = "Mineral Deposit"},
            {x = -66.68, y = -14.72, z = -638.76, nodeName = "Rocky Outcrop"},
            {x = 10.22, y = -17.85, z = -613.05, nodeName = "Rocky Outcrop"},
            {x = 25.99, y = -15.64, z = -613.42, nodeName = "Mineral Deposit"},
            {x = 68.06, y = -30.67, z = -582.67, nodeName = "Mineral Deposit"},
            {x = 130.55, y = -47.39, z = -523.51, nodeName = "Mineral Deposit"}, -- End of Island #1
            {x = 215.01, y = 303.25, z = -730.10, nodeName = "Rocky Outcrop"}, -- Waypoint #1 on 2nd Island (Issue)
            {x = 279.23, y = 295.35, z = -656.26, nodeName = "Mineral Deposit"},
            {x = 331.00, y = 293.96, z = -707.63, nodeName = "Rocky Outcrop"}, -- End of Island #2
            {x = 458.50, y = 203.43, z = -646.38, nodeName = "Rocky Outcrop"},
            {x = 488.12, y = 204.48, z = -633.06, nodeName = "Mineral Deposit"},
            {x = 558.27, y = 198.54, z = -562.51, nodeName = "Mineral Deposit"},
            {x = 540.63, y = 195.18, z = -526.46, nodeName = "Mineral Deposit"}, -- End of Island #3
            {x = 632.28, y = 253.53, z = -423.41, nodeName = "Rocky Outcrop"}, -- Sole Node on Island #4
            {x = 714.05, y = 225.84, z = -309.27, nodeName = "Rocky Outcrop"},
            {x = 678.74, y = 225.05, z = -268.64, nodeName = "Rocky Outcrop"},
            {x = 601.80, y = 226.65, z = -229.10, nodeName = "Rocky Outcrop"},
            {x = 651.10, y = 228.77, z = -164.80, nodeName = "Mineral Deposit"},
            {x = 655.21, y = 227.67, z = -115.23, nodeName = "Mineral Deposit"},
            {x = 648.83, y = 226.19, z = -74.00, nodeName = "Mineral Deposit"}, -- End of Island #5
            {x = 472.23, y = -20.99, z = 207.56, nodeName = "Rocky Outcrop"},
            {x = 541.18, y = -8.41, z = 278.78, nodeName = "Rocky Outcrop"},
            {x = 616.091, y = -31.53, z = 315.97, nodeName = "Mineral Deposit"},
            {x = 579.87, y = -26.10, z = 349.43, nodeName = "Rocky Outcrop"},
            {x = 563.04, y = -25.15, z = 360.33, nodeName = "Mineral Deposit"},
            {x = 560.68, y = -18.44, z = 411.57, nodeName = "Mineral Deposit"},
            {x = 508.90, y = -29.67, z = 458.51, nodeName = "Mineral Deposit"},
            {x = 405.96, y = 1.82, z = 454.30, nodeName = "Mineral Deposit"},
            {x = 260.22, y = 91.10, z = 530.69, nodeName = "Rocky Outcrop"},
            {x = 192.97, y = 95.66, z = 606.13, nodeName = "Rocky Outcrop"},
            {x = 90.06, y = 94.07, z = 605.29, nodeName = "Mineral Deposit"},
            {x = 39.54, y = 106.38, z = 627.32, nodeName = "Mineral Deposit"},
            {x = -46.11, y = 116.03, z = 673.04, nodeName = "Mineral Deposit"},
            {x = -101.43, y = 119.30, z = 631.55, nodeName = "Mineral Deposit"}, -- End of Island #6?
            {x = -328.20, y = 329.41, z = 562.93, nodeName = "Rocky Outcrop"},
            {x = -446.48, y = 327.07, z = 542.64, nodeName = "Rocky Outcrop"},
            {x = -526.76, y = 332.83, z = 506.12, nodeName = "Rocky Outcrop"},
            {x = -577.23, y = 331.88, z = 519.38, nodeName = "Mineral Deposit"},
            {x = -558.09, y = 334.52, z = 448.38, nodeName = "Mineral Deposit"}, -- End of Island #7
            {x = -729.13, y = 272.73, z = -62.52, nodeName = "Mineral Deposit"}
        }
elseif RouteType == "RedRoute" then 
    GatheringRoute = 
        {
            {x = -161.2715, y = -3.5233, z = -378.8041, nodeName = "Mineral Deposit", antistutter = 0}, -- Start of the route
            {x = -169.3415, y = -7.1092, z = -518.7053, nodeName = "Mineral Deposit", antistutter = 0}, -- Around the tree (Rock + Bones?)
            {x = -78.5548, y = -18.1347, z = -594.6666, nodeName = "Rocky Outcrop", antistutter = 0}, -- Log + Rock (Problematic)
            {x = -54.6772, y = -45.7177, z = -521.7173, nodeName = "Mineral Deposit", antistutter = 0}, -- Down the hill
            {x = -22.5868, y = -26.5050, z = -534.9953, nodeName = "Rocky Outcrop", antistutter = 0}, -- up the hill (rock + tree)
            {x = 59.4516, y = -41.6749, z = -520.2413, nodeName = "Rocky Outcrop", antistutter = 0}, -- Spaces out nodes on rock (hate this one)
            {x = 102.3, y = -47.3, z = -500.1, nodeName = "Mineral Deposit", antistutter = 0}, -- Over the gap
            {x = -209.1468, y = -3.9325, z = -357.9749, nodeName = "Rocky Outcrop", antistutter = 1}
        }
elseif RouteType == "PinkRoute" then
    GatheringRoute =
        {
            {x = -248.6381, y = -1.5664, z = -468.8910, nodeName = "Lush Vegetation Patch", antistutter = 0},
            {x = -338.3759, y = -0.4761, z = -415.3227, nodeName = "Lush Vegetation Patch", antistutter = 0},
            {x = -366.2651, y = -1.8514, z = -350.1429, nodeName = "Lush Vegetation Patch", antistutter = 0},
            {x = -431.2000, y = 27.5000, z = -256.7000, nodeName = "Mature Tree", antistutter = 0}, --tree node
            {x = -473.4957, y = 31.5405, z = -244.1215, nodeName = "Mature Tree", antistutter = 0},
            {x = -536.5187, y = 33.2307, z = -253.3514, nodeName = "Lush Vegetation Patch", antistutter = 0},
            {x = -571.2896, y = 35.2772, z = -236.6808, nodeName = "Lush Vegetation Patch", antistutter = 0},
            {x = -215.1211, y = -1.3262, z = -494.8219, nodeName = "Lush Vegetation Patch", antistutter = 1}
        }
end

if TargetOption == 1 then 
    MobTable = 
        {
            {"Proto-noctilucale"},
            {"Diadem Bloated Bulb"},
            {"Diadem Melia"},
            {"Diadem Icetrap"},
            {"Diadem Werewood"},
            {"Diadem Biast"},
            {"Diadem Ice Bomb"},
            {"Diadem Zoblyn"},
            {"Diadem Ice Golem"},
            {"Diadem Golem"},
            {"Corrupted Sprite"},
        }
elseif TargetOption == 2 then 
    MobTable = 
        {
            {"Corrupted Sprite"},
        }
elseif TargetOption == 3 then 
    MobTable = 
        {
            {"Proto-noctilucale"},
            {"Diadem Bloated Bulb"},
            {"Diadem Melia"},
            {"Diadem Icetrap"},
            {"Diadem Werewood"},
            {"Diadem Biast"},
            {"Diadem Ice Bomb"},
            {"Diadem Zoblyn"},
            {"Diadem Ice Golem"},
            {"Diadem Golem"}
        }
end 

spawnisland_table = 
{
    {x = -605.7039, y = 312.0701, z = -159.7864, antistutter = 0},
}

--#endregion Gathering Nodes

--#region States
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

function Ready()
    if GetItemCount(30279) == 0 or GetItemCount(30280) == 0 or GetItemCount(30281) == 0 then
        State = CharacterState.buyFishingBait
        LogInfo("State Change: BuyFishingBait")
    else
        State = CharacterState.moving
        LogInfo("State Change: MoveToNextNode")
    end
end

--#endregion States

--#region Movement
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

function EnterDiadem()
    if IsInZone(DiademZoneId) then
        State = CharacterState.ready
        return
    end

    local aurvael = {
        npcName = "Aurvael",
        x = -18.60,
        y = -16,
        z = 138.99
    }

    if GetDistanceToPoint(aurvael.x, aurvael.y, aurvael.z) > 5 then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(aurvael.x, aurvael.y, aurvael.z)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end

    if IsAddonVisible("ContentsFinderConfirm") then
        yield("/callback ContentsFinderConfirm true 8")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
    elseif IsAddonVisible("Talk") then
        yield("/click Talk Click")
    elseif HasTarget() and GetTargetName() == "Aurvael" then
        yield("/interact")
    else
        yield("/target "..aurvael.npcName)
    end
    yield("/wait 1")
end

function Mount()
    if GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.moving
        LogInfo("[FATE] State Change: MoveToNextNode")
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield("/gaction jump")
    else
        yield('/gaction "mount roulette"')
    end
    yield("/wait 1")
end

function Dismount()
    if PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.flying) then
        yield('/ac dismount')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetCharacterCondition(CharacterCondition.flying) and GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 2 then
                LogInfo("Unable to dismount here. Moving to another spot.")
                local random_x, random_y, random_z = RandomAdjustCoordinates(x, y, z, 10)
                local nearestPointX = QueryMeshNearestPointX(random_x, random_y, random_z, 100, 100)
                local nearestPointY = QueryMeshNearestPointY(random_x, random_y, random_z, 100, 100)
                local nearestPointZ = QueryMeshNearestPointZ(random_x, random_y, random_z, 100, 100)
                if nearestPointX ~= nil and nearestPointY ~= nil and nearestPointZ ~= nil then
                    PathfindAndMoveTo(nearestPointX, nearestPointY, nearestPointZ, GetCharacterCondition(CharacterCondition.flying))
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield("/e actual dismount")
        yield('/ac dismount')
    else
        yield("/e state transition")
        if NextNode.isFishingNode then
            State = CharacterState.fishing
            LogInfo("State Change: Fishing")
        else
            State = CharacterState.gathering
            LogInfo("State Change: Gathering")
        end
    end
    yield("/wait 1")
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

function SelectNextNode()
    local weather = GetActiveWeatherID()
    if PrioritizeUmbral and not UmbralGathered and (weather >= 133 and weather <= 136) then
        for _, umbralWeather in pairs(UmbralWeatherNodes) do
            if umbralWeather.weatherId == weather then
                umbralWeather.gatheringNode.isUmbralNode = true
                umbralWeather.gatheringNode.isFishingNode = false
                umbralWeather.gatheringNode.umbralWeatherName = umbralWeather.weatherName
                LogInfo("Selected umbral gathering node for "..umbralWeather.weatherName..": "..umbralWeather.gatheringNode.nodeName)
                return umbralWeather.gatheringNode
            end
        end
    elseif PrioritizeUmbral and UmbralGathered then
        for _, umbralWeather in pairs(UmbralWeatherNodes) do
            if umbralWeather.weatherId == weather then
                umbralWeather.fishingNode.isUmbralNode = true
                umbralWeather.fishingNode.isFishingNode = true
                umbralWeather.fishingNode.umbralWeatherName = umbralWeather.weatherName
                LogInfo("Selected umbral fishing node for "..umbralWeather.weatherName)
                return umbralWeather.fishingNode
            end
        end
    else
        GatheringRoute[NextNodeId].isUmbralNode = false
        GatheringRoute[NextNodeId].isFishingNode = false
        LogInfo("Selected regular gathering node :"..GatheringRoute[NextNodeId].nodeName)
        return GatheringRoute[NextNodeId]
    end
end

function MoveToNextNode()
    NextNodeCandidate = SelectNextNode()
    if (NextNodeCandidate ~= nil and NextNodeCandidate.x ~= NextNode.x or NextNodeCandidate.y ~= NextNode.y or NextNodeCandidate.z ~= NextNode.z) then
        yield("/vnav stop")
        NextNode = NextNodeCandidate
        if NextNode.isUmbralNode then
            yield("/echo Umbral weather "..NextNode.umbralWeatherName.." detected")
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.mounting
        LogInfo("State Change: Mounting")
    elseif NextNode.isFishingNode and GetClassJobId() ~= 18 then
        yield("/gs change Fisher")
        yield("/wait 3")
    elseif NextNode.isUmbralNode and not NextNode.isFishingNode and
        ((NextNode.class == "Miner" and GetClassJobId() ~= 16) or
        (NextNode.class == "Botanist" and GetClassJobId() ~= 17))
    then
        yield("/gs change "..NextNode.class)
        yield("/wait 3")
    elseif not NextNode.isUmbralNode and (RouteType == "RedRoute" or RouteType == "MinerIslands") and GetClassJobId() ~= 16 then
        yield("/gs change Miner")
        yield("/wait 3")
    elseif not NextNode.isUmbralNode and RouteType == "PinkRoute" and GetClassJobId() ~= 17 then
        yield("/gs change Botanist")
        yield("/wait 3")
    elseif GetDistanceToPoint(NextNode.x, NextNode.y, NextNode.z) <= 5 then
        yield("/vnav stop")

        if NextNode.isFishingNode then
            State = CharacterState.fishing
            LogInfo("State Change: Fishing")
            return
        elseif NextNode.isUmbralNode and not NextNode.isFishingNode then
            State = CharacterState.gathering
            LogInfo("State Change: Gathering")
            return
        else
            State = CharacterState.gathering
            LogInfo("State Change: Gathering")
            return
        end
    elseif GetDistanceToPoint(NextNode.x, NextNode.y, NextNode.z) > 5 and
        not (PathfindInProgress() or PathIsRunning())
    then
        PathfindAndMoveTo(NextNode.x, NextNode.y, NextNode.z, true)
    end
end
--#endregion Movement

--#region Gathering

function SkillCheck()
    if GetClassJobId() == 16 then -- Miner Skills 
        Yield2 = "\"King's Yield II\""
        Gift2 = "\"Mountaineer's Gift II\""
        Gift1 = "\"Mountaineer's Gift I\""
        Tidings2 = "\"Nald'thal's Tidings\""
        Bountiful2 = "\"Bountiful Yield II\""
    elseif GetClassJobId() == 17 then -- Botanist Skills 
        Yield2 = "\"Blessed Harvest II\""
        Gift2 = "\"Pioneer's Gift II\""
        Gift1 = "\"Pioneer's Gift I\""
        Tidings2 = "\"Nophica's Tidings\""
        Bountiful2 = "\"Bountiful Harvest II\""
    end
end

function UseSkill(SkillName)
    yield("/ac "..SkillName)
    yield("/wait 1")
end

function Gather()
    local visibleNode = ""
    if IsAddonVisible("_TargetInfoMainTarget") then
        visibleNode = GetNodeText("_TargetInfoMainTarget", 3)
    elseif IsAddonVisible("_TargetInfo") then 
        visibleNode = GetNodeText("_TargetInfo", 34)
    end
    
    if not HasTarget() or GetTargetName() ~= NextNode.nodeName then
        yield("/target "..NextNode.nodeName)

        yield("/wait 1")
        if not HasTarget() then
            -- target not found
            if NextNode.nodeName:sub(1, 7) == "Clouded" then
                UmbralGathered = true
            else
                NextNodeId = (NextNodeId % #GatheringRoute) + 1
            end
            State = CharacterState.ready
            LogInfo("State Change: Ready")
        end
        return
    end

    if GetDistanceToTarget() >= 3.5 and not (PathfindInProgress() or PathIsRunning()) then
        PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying))
        return
    end

    if GetDistanceToTarget() < 5 and GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("State Change: Dismount")
        return
    end

    if (GetDistanceToTarget() < 3.5 or GetCharacterCondition(CharacterCondition.gathering42)) and
        (PathfindInProgress() or PathIsRunning())
    then
        yield("/vnav stop")
        return
    end
        

    if not GetCharacterCondition(CharacterCondition.gathering) then
        SkillCheck()
        yield("/interact")
        return
    end

    -- proc the buffs you need
    if (NextNode.isUmbralNode and not NextNode.isFishingNode) or visibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        LogInfo("[Diadem Gathering] [Node Type] This is a Max Integrity Node, time to start buffing/smacking")
        if BuffYield2 and GetGp() >= 500 and not HasStatusId(219) and GetLevel() >= 40 then
            UseSkill(Yield2)
            return
        elseif BuffGift2 and GetGp() >= 300 and not HasStatusId(759) and GetLevel() >= 50 then
            UseSkill(Gift2) -- Mountaineer's Gift 2 (Min)
            return
        elseif BuffTidings2 and GetGp() >= 200 and not HasStatusId(2667) and GetLevel() >= 81 then
            UseSkill(Tidings2) -- Nald'thal's Tidings (Min)
            return
        elseif BuffGift1 and GetGp() >= 50 and not HasStatusId(2666) and GetLevel() >= 15 then
            UseSkill(Gift1) -- Mountaineer's Gift 1 (Min)
            return
        elseif BuffBYieldHarvest2 and GetGp() >= 100 and not HasStatusId(1286) and GetLevel() >= 68 then
            UseSkill(Bountiful2)
            return
        end
    -- elseif visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
    --     LogInfo("[Diadem Gathering] [Node Type] Normal Node")
    --     DGatheringLoop = true
    end

    if (GetGp() >= (GetMaxGp() - 30)) and (GetLevel() >= 68) and visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        LogInfo("Popping Yield 2 Buff")
        UseSkill(Bountiful2)
        return
    end

    if GetTargetName():sub(1, 7) == "Clouded" then
        yield("/callback Gathering true 0")
    else
        yield("/callback Gathering true 3")
    end
end

function Fish()
    local weather = GetActiveWeatherID()
    if not (weather >= 133 and weather <= 136) then
        if GetCharacterCondition(CharacterCondition.fishing) then
            yield("/ac Quit")
        else
            State = CharacterState.ready
            LogInfo("State Change: ready")
        end
        return
    end
    
    if GetCharacterCondition(CharacterCondition.fishing) then
        yield("/echo has fishing status")
        if (PathfindInProgress() or PathIsRunning()) then
            yield("/vanv stop")
        end
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("State Change: Dismounting")
        return
    end

    if not PathfindInProgress() and not PathIsRunning() then
        PathfindAndMoveTo(NextNode.fishingX, NextNode.fishingY, NextNode.fishingZ)
        return
    end

    yield("/bait "..NextNode.baitName)
    yield("/wait 0.1")
    yield("/ac Cast")
end

function BuyFishingBait()
    if GetItemCount(30279) > 0 and GetItemCount(30280) > 0 and GetItemCount(30281) > 0 then
        if IsAddonVisible("Shop") then
            yield("/callback Shop true -1")
        else
            State = CharacterState.moving
            LogInfo("State Change: MoveToNextNode")
        end
        return
    end

    local npc = {
        npcName = "Mender",
        x = -639.8871, y = 285.3894, z = -136.52252
    }

    if GetDistanceToPoint(npc.x, npc.y, npc.z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(npc.x, npc.y, npc.z)
        end
        yield("/wait 1")
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if not HasTarget() or GetTargetName() ~= npc.npcName then
        yield("/target "..npc.npcName)
        yield("/wait 1")
        yield("/interact")
        return
    end

    if IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("Shop") then
        if GetItemCount(30279) == 0 then
            yield("/callback Shop true 0 4 99 0")
        elseif GetItemCount(30280) == 0 then
            yield("/callback Shop true 0 5 99 0")
        elseif GetItemCount(30281) == 0 then
            yield("/callback Shop true 0 6 99 0")
        end
        return
    end
end
--#endregion Gathering

CharacterState = {
    ready = Ready,
    diademEntry = EnterDiadem,
    mounting = Mount,
    dismounting = Dismount,
    moving = MoveToNextNode,
    gathering = Gather,
    fishing = Fish,
    buyFishingBait = BuyFishingBait
}

FoundationZoneId = 418
FirmamentZoneId = 886
DiademZoneId = 939

if not (IsInZone(FoundationZoneId) or IsInZone(FirmamentZoneId) or IsInZone(DiademZoneId)) then
    TeleportTo("Foundation")
end
if IsInZone(FoundationZoneId) then
    yield("/target aetheryte")
    yield("/wait 1")
    if GetTargetName() == "aetheryte" then
        yield("/interact")
    end
    repeat
        yield("/wait 1")
    until IsAddonVisible("SelectString")
    yield("/callback SelectString true 2")
    repeat
        yield("/wait 1")
    until IsInZone(FirmamentZoneId)
end

LastStuckCheckTime = os.clock()
LastStuckCheckPosition = { x = GetPlayerRawXPos(), y = GetPlayerRawYPos(), z = GetPlayerRawZPos() }

State = CharacterState.ready
NextNodeId = 1
NextNode = GatheringRoute[NextNodeId]
while true do
    if not IsInZone(DiademZoneId) and State ~= CharacterState.diademEntry then
        State = CharacterState.diademEntry
    end
    if not (IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.jumping48) or
        GetCharacterCondition(CharacterCondition.jumping61) or
        GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        GetCharacterCondition(CharacterCondition.beingMoved) or
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        State()
    end
    yield("/wait 0.1")
end