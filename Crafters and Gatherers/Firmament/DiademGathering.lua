--[[

    *******************
    * Diadem Farming  *
    *******************

    *************************
    *  Version -> 0.0.1.21  *
    *************************
   
    Version Notes:
    0.0.1.21 ->    Update for snd version click changes.
    0.0.1.20 ->    Update for DT changed the /click talk to /click  Talk_Click.
    0.0.1.19.2 ->  More Pandora settings added to count for user error if you have Auto-interact with Gathering Nodes and Auto-Mount after Gathering they are disabled now.
    0.0.1.19.1 ->  Now you don't need to configure plugin options i got you ;D
    0.0.1.19 ->    Anti stutter now configurable for gathering loops.
    0.0.1.18.4 ->  Added a option to not use aether cannon , New option anti stutter added Tweaked some of the killing logic.
    0.0.1.18.3 ->  Fixed the 4.node of PinkRoute Hopefully fixed the rare accurance of not getting in diadem again
    0.0.1.18.2 ->  Litle fix for jumping before nodes and fixed the automation
    0.0.1.18 ->    Some automation Bug fixes, safeties added in places (missing a node in a loop will reset the instance)
    0.0.1.17 ->    Now it will go to other nodes and continue if the target you were trying to kill got stolen(yea i know we already fixed it once)
    0.0.1.16 ->    Fixed the rare getting stuck after killing mobs issue. (this time it is a real fix)
    0.0.1.15 ->    . . . This hasn't been miner edition for awhile. NAME CHANGED
    0.0.1.14 ->    (Man I thought I would of been done with this) Made a "CapGP" setting. If you want it to spend GP before you get to cap, change this to false. (this will use YieldII)
    0.0.1.13 ->    Targeting system has been overhauled on the mob kill side, now it SHOULD only target the mobs you want to target. (this also means you can edit the table and remove which mobs you ONLY want to target.)
    0.0.1.12 ->    Switched over the debug to output to XlLog under "Info" this cleans up chat a lot, but also has it in a neat place for us to track where things might of broke
    0.0.1.11 ->    Partially fixed the getting stuck after killing mobs fixed the dismount problem that made you fall down infinitely
    0.0.1.10 ->    New node targeting fixes spawn island aether current fix 
    0.0.1.8  ->    Tweaked the Node targeting should work better and look more human now.
    0.0.1.7  ->    Fixed the nvamesh getting stuck at ground while running path. Added target selection options Twekaed with eather use if you unselect the target or somehow it dies script will contuniue to gather.
    0.0.1.6  ->    Pink Route for btn is live! After some minor code tweaking and standardizing tables. 
    0.0.1.5  ->    Fixed Job checking not working properly
    0.0.1.4  ->    Fixed Gift1 not popping up when it should 
    0.0.1.2  ->    Fixed the waiting if there is no enemy in target distance now script will contuniue path till there is one and Aether use looks more human now
    0.0.1.0  ->    Man... didn't tink I'd hit this with how big this was getting and the bugs I/We created in turn xD 
                  This is the complete version of this script for now. I'm afraid if i change up the codebase anymore, then it's going to break. XD So going to push this as a released version, then focus on re-factoring the code in a different script (with blackjack and hookers)
                  Main things is:
                    -> Red Route is up and running 
                    -> Aethercannon is online and functional (and doesn't crash)
                    -> Ability to select which node your going to hit in the settings (don't be a dumb dumb and set it to where it'll try and gather something outside your gathering range, it won't')
                    -> Ability to ACTUALLY use the proper GP skills on the +10 integ node as well so you can maxamize on getting your items
                    -> Vnavmesh also fixed the pathing issue in v31, so that's also to a point where I feel comfortable releasing this with the "AllIslands" route. 
                  Thank you @UcanPatates with the help on this. I look foward to us making this the best diadem script we can in lua, then maybe translate that into a plugin in itself. 

    ***************
    * Description *
    ***************

    (What was suppose to be a leveling script xD) 
    A SND Lua script that allows you to loop through and maximize the amount of points that you can get in a timespan. 
    This includes (but limited to)
        -> Aethercannon Usage 
        -> Fully Automated Gathering 
        -> Using skills on the proper node 
        -> More dynamic pathing (to hopefully prevent everyone looking as botty)

    PLEASE. CHANGE. SETTINGS. As necessary

    *********************
    *  Required Plugins *
    *********************

    -> visland -> https://puni.sh/api/repository/veyn
    -> SomethingNeedDoing (Expanded Edition) [Make sure to press the lua button when you import this] -> https://puni.sh/api/repository/croizat
    -> Pandora's Box -> https://love.puni.sh/ment.json
    -> vnavmesh : https://puni.sh/api/repository/veyn


    ***********
    * Credits *
    ***********

    Author(s): Leontopodium Nivale | UcanPatates 
    Class: Miner | BTN

    **************
    *  SETTINGS  *
    **************
]]

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
        -- "RedRoute"     -> min perception route, 8 node loop
        -- "PinkRoute"    -> Btn perception route, 8 node loop

GatheringSlot = 4
-- This will let you tell the script WHICH item you want to gather. (So if I was gathering the 4th item from the top, I would input 4)
-- This will NOT work with Pandora's Gathering, as a fair warning in itself. 
-- Options : 1 | 2 | 3 | 4 | 7 | 8 (1st slot... 2nd slot... ect)

TargetOption = 1
-- This will let you tell the script which target to use Aethercannon.
-- Options : 0 | 1 | 2 | 3 (Option: 0 is don't use cannon, Option: 1 is any target, Option: 2 only sprites, Option: 3 is don't include sprites)

PrioritizeUmbral = true
-- Whenever umbral weather comes up, detours to handle umbral nodes, then returns to normal farming route when normal weather resumes.

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

SelfRepair = false  --if false, will go to Limsa mender
    RepairAmount = 20   --the amount it needs to drop before Repairing (set it to 0 if you don't want it to repair)
    ShouldAutoBuyDarkMatter = true  --Automatically buys a 99 stack of Grade 8 Dark Matter from the Limsa gil vendor if you're out
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
:: Waypoints ::
-- Waypoint (V2) Tables 
local X = 0
local Y = 0
local Z = 0
-- for 4th var 
    -- Stay on mount after fly = 0 
    -- Dismount when point is reached = 1
-- for 5th Var 
    -- mineral target [red] = 0
    -- rocky target [blue]  = 1
    -- mature tree          = 2 
    -- lush vegetation      = 3
-- for 6th var
    -- FlyTarget  = 0
    -- MoveTarget = 1
    
--for 7th var
    -- FirstNode = 1
    -- otherNodes = 0

UmbralWeatherNodes = {
    flare = {
        weatherName = "Umbral Flare",
        weatherId = 133,
        items = {
            {
                itemName = "Grade 4 Skybuilders' Umbral Flarerock",
                x = -433.9591, y = 320.6597, z = -582.4659,
                nodeName = "Clouded Mineral Deposit",
                class = "Miner"
            },
            { itemName = "Grade 4 Artisanal Skybuilders' Crimson Namitaro", class = "Fisher" }
        }
    },
    duststorms = {
        weatherName = "Umbral Duststorms",
        weatherId = 134,
        items = {
            {
                itemName = "Grade 4 Skybuilders' Umbral Dirtleaf",
                x = 384.0722, y = 294.2122, z = 583.4051,
                nodeName = "Clouded Lush Vegetation Patch",
                class = "Botanist"
            },
            { itemName = "Grade 4 Artisanal Skybuilders' Marrella", class = "Fisher" }
        }
    },
    levin = {
        weatherName = "Umbral Levin",
        weatherId = 135,
        items = {
            {
                itemName = "Grade 4 Skybuilders' Umbral Levinsand",
                x = 620.3156, y = 252.7179, z = -397.3386,
                nodeName = "Clouded Rocky Outcrop",
                class = "Miner"
            },
            { itemName = "Grade 4 Artisanal Skybuilders' Meganeura", class = "Fisher" }
        }
    },
    tempest = {
        weatherName = "Umbral Tempest",
        weatherId = 136,
        items = {
            {
                itemName = "Grade 4 Skybuilders' Umbral Galewood",
                x = -604.29, y = 333.82, z=442.46,
                nodeName = "Clouded Mature Tree",
                class = "Botanist" },
            { itemName = "Grade 4 Artisanal Skybuilders' Griffin", x = -437.06, y = -207.31, z = 196.36, class = "Fisher" }
        }
    }
}

if RouteType == "MinerIslands" then 
    gather_table =
        {
            {-570.90,45.80,-242.08,1,0},
            {-512.28,35.19,-256.92,1,0},
            {-448.87,32.54,-256.16,1,0},
            {-403.11,11.01,-300.24,1,1}, -- Fly Issue #1
            {-363.65,-1.19,-353.93,1,1}, -- Fly Issue #2 
            {-337.34,-0.38,-418.02,1,0},
            {-290.76,0.72,-430.48,1,0},
            {-240.05,-1.41,-483.75,1,0},
            {-166.13,-0.08,-548.23,1,0},
            {-128.41,-17.00,-624.14,1,0},
            {-66.68,-14.72,-638.76,1,1},
            {10.22,-17.85,-613.05,1,1},
            {25.99,-15.64,-613.42,1,0},
            {68.06,-30.67,-582.67,1,0},
            {130.55,-47.39,-523.51,1,0}, -- End of Island #1
            {215.01,303.25,-730.10,1,1}, -- Waypoint #1 on 2nd Island (Issue)
            {279.23,295.35,-656.26,1,0},
            {331.00,293.96,-707.63,1,1}, -- End of Island #2 
            {458.50,203.43,-646.38,1,1},
            {488.12,204.48,-633.06,1,0},
            {558.27,198.54,-562.51,1,0},
            {540.63,195.18,-526.46,1,0}, -- End of Island #3 
            {632.28,253.53,-423.41,1,1}, -- Sole Node on Island #4
            {714.05,225.84,-309.27,1,1},
            {678.74,225.05,-268.64,1,1},
            {601.80,226.65,-229.10,1,1},
            {651.10,228.77,-164.80,1,0},
            {655.21,227.67,-115.23,1,0},
            {648.83,226.19,-74.00,1,0}, -- End of Island #5
            {472.23,-20.99,207.56,1,1},
            {541.18,-8.41,278.78,1,1},
            {616.091,-31.53,315.97,1,0},
            {579.87,-26.10,349.43,1,1},
            {563.04,-25.15,360.33,1},
            {560.68,-18.44,411.57,1,0}, --
            {508.90,-29.67,458.51,1,0},
            {405.96,1.82,454.30,1,0},
            {260.22,91.10,530.69,1,1},
            {192.97,95.66,606.13,1,1},
            {90.06,94.07,605.29,1,0},
            {39.54,106.38,627.32,1,0},
            {-46.11,116.03,673.04,1,0},
            {-101.43,119.30,631.55,1,0}, -- End of Island #6?
            {-328.20,329.41,562.93,1,1},
            {-446.48,327.07,542.64,1,1},
            {-526.76,332.83,506.12,1,1},
            {-577.23,331.88,519.38,1,0},
            {-558.09,334.52,448.38,1,0}, -- End of Island #7 
            {-729.13,272.73,-62.52,1,0}, -- Final Node in the Loop
        }
elseif RouteType == "RedRoute" then 
    gather_table = 
        {
            {-161.2715,-3.5233,-378.8041,0,1,1,0}, -- Start of the route
            {-169.3415,-7.1092,-518.7053,0,0,1,0}, -- Around the tree (Rock + Bones?)
            {-78.5548,-18.1347,-594.6666,1,0,1,0}, -- Log + Rock (Problematic)
            {-54.6772,-45.7177,-521.7173,0,0,1,0}, -- Down the hill 
            {-22.5868,-26.5050,-534.9953,0,1,1,0}, -- up the hill (rock + tree)
            {59.4516,-41.6749,-520.2413,0,1,1,0}, -- Spaces out nodes on rock (hate this one)
            {102.3,-47.3,-500.1,0,0,0,0}, -- Over the gap
            {-209.1468,-3.9325,-357.9749,1,0,1,1}, -- Bonus node
        }
elseif RouteType == "PinkRoute" then 
    gather_table = 
        {
            {-248.6381,-1.5664,-468.8910,0,3,1,0},
            {-338.3759,-0.4761,-415.3227,0,3,1,0},
            {-366.2651,-1.8514,-350.1429,0,3,1,0},
            {-431.2,27.5,-256.7,0,2,1,0}, --tree node
            {-473.4957,31.5405,-244.1215,0,2,1,0},
            {-536.5187,33.2307,-253.3514,0,3,1,0},
            {-571.2896,35.2772,-236.6808,0,3,1,0},
            {-215.1211,-1.3262,-494.8219,0,3,1,1},
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
       {-605.7039,312.0701,-159.7864,0,99,0},
   }


--Functions

function setSNDPropertyIfNotSet(propertyName)
    if GetSNDProperty(propertyName) == false then
        SetSNDProperty(propertyName, "true")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to True")
    end
end


function unsetSNDPropertyIfSet(propertyName )
    if GetSNDProperty(propertyName) then
        SetSNDProperty(propertyName, "false")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to False")
    end
end

-- Set properties if they are not already set
setSNDPropertyIfNotSet("UseItemStructsVersion")
setSNDPropertyIfNotSet("UseSNDTargeting")

--for Pandora
PandoraSetFeatureState("Auto-interact with Gathering Nodes",false)
PandoraSetFeatureState("Auto-Mount after Gathering",false)
PandoraSetFeatureState("Pandora Quick Gather",false)

-- Unset properties if they are set
unsetSNDPropertyIfSet("StopMacroIfTargetNotFound")
unsetSNDPropertyIfSet("StopMacroIfCantUseItem")
unsetSNDPropertyIfSet("StopMacroIfItemNotFound")

function SkillCheck()
    yield("/echo Skillcheck")
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

function GatheringTarget(targetName, isFlying)
    yield("/e gathering target "..targetName)
    if isFlying == nil then
        yield("/e flying is nil")
    else
        yield("/e flying is "..tostring(isFlying))
    end
    LoopClear()
    GatherNodeTargetLoop=0
    while GetCharacterCondition(45,false) and GetCharacterCondition(6, false) do
        while GetTargetName() == "" and GatherNodeTargetLoop < 20 and IsInZone(886) == false do
            yield("/target "..targetName)
            yield("/wait 0.1")
            GatherNodeTargetLoop = GatherNodeTargetLoop + 1
        end
        if GatherNodeTargetLoop >= 20 then
            yield("/e Node not found restarting the gathering loop.")
            LeaveDuty()
            -- while IsInZone(886) == false do
            --     yield("/wait 2")
            -- end
        end
        yield("/echo target found")
        yield("/wait 0.1")
        if GetDistanceToTarget() > 6 then
            yield("/echo far from target")
            if isFlying then
                yield("/vnavmesh flytarget")
            else
                yield("/vnavmesh movetarget")
            end
            while GetDistanceToTarget() > 3.5 and IsInZone(886) == false do
                yield("/e still far from target")
                if isFlying and GetCharacterCondition(4) == false and GetCharacterCondition(77) == false then 
                    MountFly()
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) and GetCharacterCondition(77) then
                        yield("/vnavmesh flytarget")
                    end
                end  
                yield("/wait 0.1")
            end
            PathStop()
            if GetDistanceToTarget() < 3.5 and GetCharacterCondition(4) then
                Dismount()
            end
        end
        yield("/echo close to target")
        while GetCharacterCondition(6, false) and IsInZone(886) == false do
            yield("/wait 0.1")
            yield("/interact")
            while GetTargetName() == "" and GatherNodeTargetLoop < 20 and IsInZone(886) == false do
                yield("/target "..targetName)
                yield("/wait 0.1")
                GatherNodeTargetLoop = GatherNodeTargetLoop + 1
            end
            if GatherNodeTargetLoop >= 20 then
                yield("/e Node not found restarting the gathering loop.")
                LeaveDuty()
                while IsInZone(886) == false do
                    yield("/wait 2")
                end
            end
            if GetNodeText("_TextError",1) == "Too far away." then 
                yield("/vnavmesh movetarget")
                while GetDistanceToTarget() > 3.5 and IsInZone(886) == false do 
                    yield("/wait 0.1")
                end
                PathStop()
            end
        end            
    end
    PathStop()
    DGathering()
    yield("/wait 0.1")
    LogInfo("GatheringTarget -> Completed")
end

function CanadianMounty()
    while GetCharacterCondition(4, false) and IsInZone(939) do 
        while GetCharacterCondition(27, false) and IsInZone(939) do
            yield("/wait 0.1")
            yield('/gaction "mount roulette"')
            
        end
        while GetCharacterCondition(27) and IsInZone(939) do 
            yield("/wait 0.1")
        end 
        yield("/wait 1")
        PlayerWait()
        LogInfo("CanadianMounty -> Completed")
    end
end

function Target()
    if GetTargetName() ~= "" then
        return true 
    else
        return false
    end
end

function KillTarget()
    if IsInZone(939) then
        if GetDistanceToTarget() == 0.0 and GetCharacterCondition(6, false) and GetCharacterCondition(45, false) and GetDiademAetherGaugeBarCount() >= 1 and TargetOption ~= 0 then 
            if KillLoop >= 1 then
                if (PathIsRunning() or PathfindInProgress()) then
                    yield("/wait 2")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end
                LoopClear()
            end
            for i=1, #MobTable do
                yield("/target "..MobTable[i][1])
                yield("/wait 0.03")
                if Target() == false then
                    yield("/wait 0.05")
                end
                if Target() == true then 
                    break 
                end
            end   
            
            yield("/wait 0.1")
            if Target() then 
                KillLoop = KillLoop + 1
                if GetDistanceToTarget() > 10 then
                    PathStop()
                    MountFly()
                    yield("/wait 0.1")
                    yield("/vnavmesh flytarget")
                    while GetDistanceToTarget() > 10 and GetTargetName() ~= "" and IsInZone(886) == false do
                        yield("/wait 0.1")
                        if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                            MountFly()
                        end                            
                    end
                end
                PathStop() 
                yield("/wait 0.1")
                while GetTargetHP() > 1.0 and GetTargetName() ~= "" and IsInZone(886) == false do
                    if PathIsRunning() then
                        PathStop()
                    end 
                    Dismount()
                    if GetNodeText("_TextError",1) == "Target not in line of sight." and IsAddonVisible("_TextError") then
                        ClearTarget()
                        yield("/wait 1")
                    end
                    if GetDistanceToTarget() > 15 then
                        ClearTarget()
                        yield("/wait 0.1")
                    end
                    if GetCharacterCondition(27) then -- casting
                        yield("/wait 0.5")
                        LoopClear()
                    else
                        yield("/gaction \"Duty Action I\"")
                        yield("/wait 0.5")
                    end
                end
                LogInfo("KillTarget -> Completed")
            end
        end
    end
end

function MountFly()
    if GetCharacterCondition(4, false) and IsInZone(939) then 
        while GetCharacterCondition(4, false) and IsInZone(939) do 
            CanadianMounty()
        end
    end
    while GetCharacterCondition(77) == false and IsInZone(939) do 
        PathStop()
        CanadianMounty()
        yield("/gaction jump")
        yield("/wait 0.1")
        yield("/gaction jump")
    end
    LogInfo("MountFly -> Completed")
end

function WalkTo(x, y, z)
    PathfindAndMoveTo(x, y, z, false)
    while (PathIsRunning() or PathfindInProgress()) do
        yield("/wait 0.5")
    end
    LogInfo("WalkTo -> Completed")
end

function VNavMoveTime(stoppingDistance)
    yield("/echo vnavmovetime")
    -- Setting the camera setting for Navmesh (morso for the standard players that way they don't get nauseas)
    if PathGetAlignCamera() == false then 
        PathSetAlignCamera(true) 
    end 
    yield("/echo 1")
    while GetDistanceToPoint(X, Y, Z) >= stoppingDistance and IsInZone(939) do
        if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
            MountFly()
        end
        if PathIsRunning() == false or IsMoving() == false then 
            PathfindAndMoveTo(X, Y, Z, true)
            yield("/wait 0.1")
            while PathfindInProgress() and IsInZone(886) == false do
                yield("/wait 0.1")
                if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                    MountFly()
                end
            end 
        end
        yield("/wait 0.1")
        KillTarget()
    end
    LogInfo("VNavMoveTime(i) -> Completed")
end

function VislandMoveTime() 
    yield("/visland moveto "..X.." "..Y.." "..Z)
    while GetDistanceToPoint(X, Y, Z) > 1 do 
        yield("/wait 0.1")
    end 
    yield("/visland stop")
    LogInfo("VislandMoveTime -> Completed")
end

function PlayerWait()
    if PlayerWaitTime then 
        math.randomseed( os.time() )
        RandomTimeWait = math.random(10, 20) / 10
        yield("/wait "..RandomTimeWait)
        LogInfo("PlayerWait -> Completed")
    end
end  

function StatusCheck()
    yield("/wait 0.3")
    if GetCharacterCondition(42) then
        repeat 
            yield("/wait 0.1")
        until GetCharacterCondition(42, false)
    end
    LogInfo("StatusCheck -> Completed")
end

function DGathering()
    LoopClear()
    UiElementSelector()
    while GetCharacterCondition(6) and IsInZone(886) == false do 
        if visibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false then 
            while visibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false do 
                LogInfo("[Diadem Gathering] [Node Type] This is a Max Integrity Node, time to start buffing/smacking")
                PlayerWait()
                yield("/wait 0.1")
                while BuffYield2 and GetGp() >= 500 and HasStatusId(219) == false and GetLevel() >= 40 and IsInZone(886) == false do -- 
                    if debug then yield("/e [Debug] Should be applying Kings Yield 2") end
                    UseSkill(Yield2)
                    StatusCheck()
                end
                while BuffGift2 and GetGp() >= 300 and HasStatusId(759) == false and GetLevel() >= 50 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Mountaineer's Gift 2'") end
                    UseSkill(Gift2) -- Mountaineer's Gift 2 (Min)
                    StatusCheck()
                end
                while BuffTidings2 and GetGp() >= 200 and HasStatusId(2667) == false and GetLevel() >= 81 and IsInZone(886) == false do 
                    if debug then yield("/e [Debug] Should be applying Tidings") end
                    UseSkill(Tidings2) -- Nald'thal's Tidings (Min)
                    StatusCheck()
                end 
                while BuffGift1 and GetGp() >= 50 and HasStatusId(2666) == false and GetLevel() >= 15 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Mountaineer's Gift 1'") end
                    UseSkill(Gift1) -- Mountaineer's Gift 1 (Min)
                    StatusCheck()
                end
                while BuffBYieldHarvest2 and GetGp() >= 100 and HasStatusId(1286) == false and GetLevel() >= 68 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Bountiful Yield 2") end
                    UseSkill(Bountiful2)
                    StatusCheck()
                end 
                DGatheringLoop = true
            end
        elseif visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false then 
            LogInfo("[Diadem Gathering] [Node Type] Normal Node")
            DGatheringLoop = true
        end
        if GetTargetName():sub(1, 7) == "Clouded" then
            yield("/pcall Gathering true 0")
        else
            yield("/pcall Gathering true "..NodeSelection)
        end
        yield("/wait 0.1")
        while GetCharacterCondition(42) and IsInZone(886) == false do
            yield("/wait 0.2")
        end
        if PathIsRunning() == true then 
            PathStop()
        end
        BountifulYieldII()
    end 
    LogInfo("DGathering -> Completed")
end

function FoodCheck() 
    LoopClear()
    while (GetStatusTimeRemaining(48) <= FoodTimeRemaining or HasStatusId(48) == false) and Food_Tick < FoodTimeout do 
        yield("/item "..FoodKind)
        yield("/wait 2")
        Food_Tick = Food_Tick + 1 
        if Food_Tick == FoodTimeout then 
            yield("/e [Diadem Gathering] Hmm... either you put in a food that doesn't exist. Or you don't have anymore of that food. Either way, disabling it for now")
            UseFood = false 
        end
    end
    LogInfo("FoodCheck -> Completed")
end

function TargetedInteract(target)
    yield("/target "..target.."")
    repeat
        yield("/wait 0.1")
    until GetDistanceToTarget() < 6
    yield("/interact")
    repeat
        yield("/wait 0.1")
    until IsAddonReady("SelectIconString")
    LogInfo("TargetedInteract -> Completed")
end

function LoopClear()
    KillLoop = 0
    Food_Tick = 0 
    DGatheringLoop = false 
    LogInfo("LoopClear -> Completed")
end

function UiElementSelector()
    if IsAddonVisible("_TargetInfoMainTarget") then 
        visibleNode = GetNodeText("_TargetInfoMainTarget", 3)
    elseif IsAddonVisible("_TargetInfo") then 
        visibleNode = GetNodeText("_TargetInfo", 34)
    end
end

function BountifulYieldII()
    YieldGP = GetMaxGp() - 30
    if GetGp() >= YieldGP and GetLevel() >= 68 and visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then 
        LogInfo("Popping Yield 2 Buff")
        yield("/ac "..Bountiful2)
        StatusCheck()
    end
end 

function Dismount()
    a=0
    if GetCharacterCondition(4) or GetCharacterCondition(77) and IsInZone(886) == false then
        yield("/ac dismount")
        yield("/wait 0.3")
    while GetCharacterCondition(77) and a < 4 and IsInZone(886) == false do
        yield("/wait 0.5")
        a=a+1
    end
        if a == 4 then
            yield("/wait 0.1")
            yield("/gaction jump")
            yield("/send SPACE")
            ClearTarget() 
            PathStop()
            LogInfo("Dismount -> BailoutCommanced")
        end
    end
    LogInfo("Dismount -> Completed")
end

function UseSkill(SkillName)
    yield("/ac "..SkillName)
    yield("/wait 0.1")
end 

::SettingNodeValue:: 
NodeSelection = GatheringSlot - 1
Counter = 0
FoodTimeRemaining = RemainingFoodTimer * 60
DGatheringLoop = false 
KillLoop = 0

::JobTester::
Current_job = GetClassJobId()
if (Current_job == 17) or (Current_job == 16) then
    if GetClassJobId() == 17 then -- Botanist
        if RouteType == "RedRoute" then
            yield("/echo Hmm... You're in Botanis, yet you chose Red Route. Going to assume you meant to choose the route for the class. If not, then stop the script now to change it")
            RouteType = "PinkRoute"
            goto Waypoints
        end 
    elseif GetClassJobId() == 16 then
        if RouteType == "PinkRoute" then
            yield("/echo Hmm... You're in Miner, yet you chose Pink Route. Going to assume you meant to choose the route for the class. If not, then stop the script now to change it")
            RouteType = "RedRoute"
            goto Waypoints
        end 
    end
    goto Enter
else
    yield("/echo Hmm... You're not on a gathering job, switch to one and start the script again.")
    yield("/snd stop")
end

if Self_Repair and Npc_Repair then
    Npc_Repair=false
    yield("/echo You can only select one repair setting. Setting Npc Repair false")
end

::Enter::

if IsInZone(939) and GetCharacterCondition(45, false) then 
    goto DiademFarming
end

while not IsInZone(886) and GetCharacterCondition(45, false) do
    yield("/wait 0.2")
end
while IsPlayerAvailable() == false do
    yield("/wait 0.1")
end
PathStop()

::RepairMode::

-- If you have the ability to repair your gear, this will allow you to do so. 
-- Currently will repair when your gear gets to 50% or below, but you can change the value to be whatever you would like
if NeedsRepair(Repair_Amount) and Self_Repair then
    yield("/generalaction repair")
    yield("/waitaddon Repair")
    yield("/pcall Repair true 0")
    yield("/wait 0.1")
    if IsAddonVisible("SelectYesno") then
        yield("/pcall SelectYesno true 0")
        yield("/wait 0.1")
    end
    while GetCharacterCondition(39) do yield("/wait 1") end
    yield("/wait 1")
    yield("/pcall Repair true -1")
end
if NeedsRepair(Repair_Amount) and Npc_Repair then
    if IsInZone(886) then -- Check if in Firmament
        WalkTo(47, -16, 151)
        TargetedInteract("Eilonwy") -- Interact with target named "Eilonwy"
        yield("/pcall SelectIconString false 1") 
        while not IsAddonReady("Repair") do 
        yield("/wait 0.1")
    end
    yield("/pcall Repair true 0") 
    yield("/wait 0.1")
    if IsAddonReady("SelectYesno") then
        yield("/pcall SelectYesno true 0")
        yield("/wait 0.1")
    end
    yield("/pcall Repair true -1") 
    yield("/wait 0.1")
    WalkTo(-18.5, -16, 142) --Walks to target named "Eilonwy"
    else
        yield("/echo You are not in Firmament") -- Notify if not in Firmament
    end
end 

::DiademEntry::
if IsInZone(886) then
    while GetCharacterCondition(34, false) and GetCharacterCondition(45, false) do
        if IsAddonVisible("ContentsFinderConfirm") then
            yield("/pcall ContentsFinderConfirm true 8")
        elseif GetTargetName()=="" then
            yield("/target Aurvael")
        elseif GetCharacterCondition(32, false) then
            yield("/interact")
        end
        if IsAddonVisible("Talk") then yield("/click  Talk Click") end
        if IsAddonVisible("SelectString") then yield("/pcall SelectString true 0") end
        if IsAddonVisible("SelectYesno") then yield("/pcall SelectYesno true 0") end
        yield("/wait 0.5")
    end
    while GetCharacterCondition(35, false) do yield("/wait 1") end
    while GetCharacterCondition(35) do yield("/wait 1") end
    yield("/wait 3")
end

::DiademFarming::

UmbralGathered = false
SkillCheck()
while IsInZone(939) and GetCharacterCondition(45, false) do
    --for i=1, #gather_table do
    local i = 1
    while true do
        if GetCharacterCondition(45, false) then 
            if UseFood and (GetStatusTimeRemaining(48) <= FoodTimeRemaining or HasStatusId(48) == false) then 
                yield("/e [Diadem Gathering] Food seems to have ran out, going to re-food")
                FoodCheck()
            end
            MountFly()
            local weather = GetActiveWeatherID()
            local stoppingDistance = 6
            local targetName = ""
            local isFlying = true
            if PrioritizeUmbral and not UmbralGathered and (weather >= 133 and weather <= 136) then
                UmbralGathered = true
                for _, umbralWeather in pairs(UmbralWeatherNodes) do
                    if umbralWeather.weatherId == weather then
                        yield("/echo "..umbralWeather.weatherName.." detected")
                        X = umbralWeather.items[1].x
                        Y = umbralWeather.items[1].y
                        Z = umbralWeather.items[1].z
                        targetName = umbralWeather.items[1].nodeName
                        yield("/gs change "..umbralWeather.items[1].class)
                        SkillCheck()
                        break
                    end
                end
            else
                if UmbralGathered and  not (weather >= 133 and weather <= 136) then
                    UmbralGathered = false -- umbral weather has reset
                    if RouteType == "RedRoute" and GetClassJobId() ~= 16 then
                        yield("/gs change Miner")
                        yield("/wait 3")
                        SkillCheck()
                    elseif RouteType == "PinkRoute" and GetClassJobId() ~= 17 then
                        yield("/gs change Botanist")
                        yield("/wait 3")
                        SkillCheck()
                    end
                end

                X = gather_table[i][1]
                Y = gather_table[i][2]
                Z = gather_table[i][3]

                if gather_table[i][4] then
                    stoppingDistance = 6
                else
                    stoppingDistance = 3
                end
                
                -- 99 is the code imma use if I don't want it gathering anything, and make sure it's not the coords I want to use as a midpoint
                if gather_table[i][5] == 0 then 
                    targetName = "Mineral Deposit"
                elseif gather_table[i][5] == 1 then 
                    targetName = "Rocky Outcrop"
                elseif gather_table[i][5] == 2 then 
                    targetName = "Mature Tree"
                elseif gather_table[i][5] == 3 then 
                    targetName = "Lush Vegetation Patch"
                end

                isFlying = gather_table[i][6] == 0

                i = (i % #gather_table) + 1
            end
            
            ClearTarget()
            yield("/echo a")
            VNavMoveTime(stoppingDistance)
            if targetName ~= "" then
                GatheringTarget(targetName, isFlying)
            end 
            if gather_table[i][7] == 1 then
                Counter = Counter + 1
                if AntiStutterOpen and Counter >= AntiStutter then
                    LogInfo("AntiStutter -> Completed")
                    yield("/runmacro DiademV2")
                end
            end 

            if GetInventoryFreeSlotCount() == 0 then 
                LogInfo("It seems like your inventory has reached Max Capacity slot wise. For the safety of you (and to help you not just stand there for hours on end), we're going to stop the script here and leave the instance")
                yield("/e It seems like your inventory has reached Max Capacity slot wise. For the safety of you (and to help you not just stand there for hours on end), we're going to stop the script here and leave the instance")
                DutyLeave()
                yield("/snd stop")
            end
        end
    end
end

goto Enter