--[[
********************************************************************************
*                             Wondrous Tails Doer                              *
*                                Version 0.2.1                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Description: Picks up a Wondrous Tails journal from Khloe, then attempts each duty

For dungeons:
- Attempts dungeon Unsynced if duty is at least 20 levels below you
- Attempts dungeon with Duty Support if duty is within 20 levels of you and Duty
Support is available

For EX Trials:
- Attempts any duty unsynced if it is 20 levels below you and skips any that are
within 20 levels
- Note: Not all EX trials have BossMod support, but this script will attempt
each one once anyways
- Some EX trials are blacklisted due to mechanics that cannot be done solo
(Byakko tank buster, Tsukuyomi meteors, etc.)

Alliance Raids/PVP/Treasure Maps/Palace of the Dead
- Skips them all


    -> 0.2.0    Fixes for ex trials
                Update for patch 7.1

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. Autoduty
2. Rotation Solver Reborn
3. BossModReborn (BMR) or Veyn's BossMod (VBM)
]]

-- Region: Data ---------------------------------------------------------------------------------

WonderousTailsDuties = {
    { -- type 0: extreme trials
        { instanceId=20010, dutyId=297, dutyName="The Howling Eye (Extreme)", minLevel=50 },
        { instanceId=20009, dutyId=296, dutyName="The Navel (Extreme)", minLevel=50 },
        { instanceId=20008, dutyId=295, dutyName="The Bowl of Embers (Extreme)", minLevel=50 },
        { instanceId=20012, dutyId=364, dutyName="Thornmarch (Extreme)", minLevel=50 },
        { instanceId=20018, dutyId=359, dutyName="The Whorleater (Extreme)", minLevel=50 },
        { instanceId=20023, dutyId=375, dutyName="The Striking Tree (Extreme)", minLevel=50 },
        { instanceId=20025, dutyId=378, dutyName="The Akh Afah Amphitheatre (Extreme)", minLevel=50 },
        { instanceId=20013, dutyId=348, dutyName="The Minstrel's Ballad: Ultima's Bane", minLevel=50 },
        { instanceId=20034, dutyId=447, dutyName="The Limitless Blue (Extreme)", minLevel=60 },
        { instanceId=20032, dutyId=446, dutyName="Thok ast Thok (Extreme)", minLevel=60 },
        { instanceId=20036, dutyId=448, dutyName="The Minstrel's Ballad: Thordan's Reign", minLevel=60 },
        { instanceId=20038, dutyId=524, dutyName="Containment Bay S1T7 (Extreme)", minLevel=60 },
        { instanceId=20040, dutyId=566, dutyName="The Minstrel's Ballad: Nidhogg's Rage", minLevel=60 },
        { instanceId=20042, dutyId=577, dutyName="Containment Bay P1T6 (Extreme)", minLevel=60 },
        { instanceId=20044, dutyId=638, dutyName="Containment Bay Z1T9 (Extreme)", minLevel=60 },
        { instanceId=20049, dutyId=720, dutyName="Emanation (Extreme)", minLevel=70 },
        { instanceId=20056, dutyId=779, dutyName="The Minstrel's Ballad: Tsukuyomi's Pain", minLevel=70 },
        { instanceId=20058, dutyId=811, dutyName="Hells' Kier (Extreme)", minLevel=70 },
        { instanceId=20054, dutyId=762, dutyName="The Great Hunt (Extreme)", minLevel=70 },
        { instanceId=20061, dutyId=825, dutyName="The Wreath of Snakes (Extreme)", minLevel=70 },
        { instanceId=20063, dutyId=858, dutyName="The Dancing Plague (Extreme)", minLevel=80 },
        { instanceId=20065, dutyId=848, dutyName="The Crown of the Immaculate (Extreme)", minLevel=80 },
        { instanceId=20067, dutyId=885, dutyName="The Minstrel's Ballad: Hades's Elegy", minLevel=80 },
        { instanceId=20069, dutyId=912, dutyName="Cinder Drift (Extreme)", minLevel=80 },
        { instanceId=20070, dutyId=913, dutyName="Memoria Misera (Extreme)", minLevel=80 },
        { instanceId=20072, dutyId=923, dutyName="The Seat of Sacrifice (Extreme)", minLevel=80 },
        { instanceId=20074, dutyId=935, dutyName="Castrum Marinum (Extreme)", minLevel=80 },
        { instanceId=20076, dutyId=951, dutyName="The Cloud Deck (Extreme)", minLevel=80 },
        { instanceId=20078, dutyId=996, dutyName="The Minstrel's Ballad: Hydaelyn's Call", minLevel=90 },
        { instanceId=20081, dutyId=993, dutyName="The Minstrel's Ballad: Zodiark's Fall", minLevel=90 },
        { instanceId=20083, dutyId=998, dutyName="The Minstrel's Ballad: Endsinger's Aria", minLevel=90 },
        { instanceId=20085, dutyId=1072, dutyName="Storm's Crown (Extreme)", minLevel=90 },
        { instanceId=20087, dutyId=1096, dutyName="Mount Ordeals (Extreme)", minLevel=90 },
        { instanceId=20090, dutyId=1141, dutyName="The Voidcast Dais (Extreme)", minLevel=90 },
        { instanceId=20092, dutyId=1169, dutyName="The Abyssal Fracture (Extreme)", minLevel=90 }
    },
    { -- type 1: expansion cap dungeons
        { dutyName="Dungeons (Lv. 100)", dutyId=1199, minLevel=100 } --Alexandria
    },
    2,
    3,
    { -- type 4: normal raids
        { dutyName="Binding Coil of Bahamut", dutyId=241, minLevel=50 },
        { dutyName="Second Coil of Bahamut", dutyId=355, minLevel=50 },
        { dutyName="Final Coil of Bahamut", dutyId=193, minLevel=50 },
        { dutyName="Alexander: Gordias", dutyId=442, minLevel=60 },
        { dutyName="Alexander: Midas", dutyId=520, minLevel=60 },
        { dutyName="Alexander: The Creator", dutyId=580, minLevel=60 },
        { dutyName="Omega: Deltascape", dutyId=693, minLevel=70 },
        { dutyName="Omega: Sigmascape", dutyId=748, minLevel=70 },
        { dutyName="Omega: Alphascape", dutyId=798, minLevel=70 },
        { dutyName="Eden's Gate", dutyId=849, minLevel=80 },
        { dutyName="Eden's Verse", dutyId=903, minLevel=80 },
        { dutyName="Eden's Promise", dutyId=942, minLevel=80 },
    },
    { -- type 5: leveling dungeons
        { dutyName="Leveling Dungeons (Lv. 1-49)", dutyId=172, minLevel=15 }, --The Aurum Vale
        { dutyName="Leveling Dungeons (Lv. 51-79)", dutyId=434, minLevel=51 }, --The Dusk Vigil
        { dutyName="Leveling Dungeons (Lv. 81-99)", dutyId=952, minLevel=81 }, --The Tower of Zot
    },
    { -- type 6: expansion cap dungeons
        { dutyName="High-level Dungeons (Lv. 50-60)", dutyId=362, minLevel=50 }, --Brayflox Longstop (Hard)
        { dutyName="High-level Dungeons (Lv. 70-80)", dutyId=1146, minLevel=70 }, --Ala Mhigo
        { dutyName="High-level Dungeons (Lv. 90)", dutyId=973, minLevel=90 }, --The Dead Ends
        
    },
    { -- type 7: ex trials
        {
            { instanceId=20008, dutyId=295, dutyName="Trials (Lv. 50-60)", minLevel=50 }, -- Bowl of Embers
            { instanceId=20049, dutyId=720, dutyName="Trials (Lv. 70-100)", minLevel=70 }
        }
    },
    { -- type 8: alliance raids

    },
    { -- type 9: normal raids
        { dutyName="Normal Raids (Lv. 50-60)", dutyId=241, minLevel=50 },
        { dutyName="Normal Raids (Lv. 70-80)", dutyId=693, minLevel=70 },
    },
    Blacklisted= {
        { -- 0
            { instanceId=20052, dutyId=758, dutyName="The Jade Stoa (Extreme)", minLevel=70 }, -- cannot solo double tankbuster vuln
            { instanceId=20047, dutyId=677, dutyName="The Pool of Tribute (Extreme)", minLevel=70 }, -- cannot solo active time maneuver
            { instanceId=20056, dutyId=779, dutyName="The Minstrel's Ballad: Tsukuyomi's Pain", minLevel=70 } -- cannot solo meteors
        },
        {}, -- 1
        {}, -- 2
        { -- 3
            { dutyName="Treasure Dungeons" }
        },
        { -- 4
            { dutyName="Alliance Raids (A Realm Reborn)", dutyId=174 },
            { dutyName="Alliance Raids (Heavensward)", dutyId=508 },
            { dutyName="Alliance Raids (Stormblood)", dutyId=734 },
            { dutyName="Alliance Raids (Shadowbringers)", dutyId=882 },
            { dutyName="Alliance Raids (Endwalker)", dutyId=1054 },
            { dutyName="Asphodelos= First to Fourth Circles", dutyId=1002 },
            { dutyName="Abyssos= Fifth to Eighth Circles", dutyId=1081 },
            { dutyName="Anabaseios= Ninth to Twelfth Circles", dutyId=1147 }
        }
    }
}

Khloe = {
    x = -19.346453,
    y = 210.99998,
    z = 0.086749226,
    name = "Khloe Aliapoh"
}

-- Region: Functions ---------------------------------------------------------------------------------

function SearchWonderousTailsTable(type, data, text)
    if type == 0 then -- ex trials are indexed by instance#
        for _, duty in ipairs(WonderousTailsDuties[type+1]) do
            if duty.instanceId == data then
                return duty
            end
        end
    elseif type == 1 or type == 5 or type == 6 or type == 7 then -- dungeons, level range ex trials
        for _, duty in ipairs(WonderousTailsDuties[type+1]) do
            if duty.dutyName == text then
                return duty
            end
        end
    elseif type == 4 or type == 8 then -- normal raids
        for _, duty in ipairs(WonderousTailsDuties[type+1]) do
            if duty.dutyName == text then
                return duty
            end
        end
    end
end

-- Region: Main ---------------------------------------------------------------------------------

CurrentLevel = GetLevel()

-- Pick up a journal if you need one
if not HasWeeklyBingoJournal() or IsWeeklyBingoExpired() or WeeklyBingoNumPlacedStickers() == 9 then
    if not IsInZone(478) then
        yield("/tp Idyllshire")
        yield("/wait 1")
    end
    while not (IsInZone(478) and IsPlayerAvailable()) do
        yield("/wait 1")
    end
    PathfindAndMoveTo(Khloe.x, Khloe.y, Khloe.z)
    while(GetDistanceToPoint(Khloe.x, Khloe.y, Khloe.z) > 5) do
        yield("/wait 1")
    end
    yield("/target "..Khloe.name)
    yield("/wait 1")
    yield("/interact")
    while not IsAddonVisible("SelectString") do
        yield("/click Talk Click")
        yield("/wait 1")
    end
    if IsAddonVisible("SelectString") then
        if not HasWeeklyBingoJournal() then
            yield("/callback SelectString true 0")
        elseif IsWeeklyBingoExpired() then
            yield("/callback SelectString true 1")
        elseif WeeklyBingoNumPlacedStickers() == 9 then
            yield("/callback SelectString true 0")
        end
        
    end
    while GetCharacterCondition(32) do
        yield("/click Talk Click")
        yield("/wait 1")
    end
    yield("/wait 1")
end

-- skip 13: Shadowbringers raids (not doable solo unsynced)
-- skip 14: Endwalker raids (not doable solo unsynced)
-- skip 15: PVP
for i = 0, 12 do
    if GetWeeklyBingoTaskStatus(i) == 0 then
        local key = GetWeeklyBingoOrderDataKey(i)
        local type = GetWeeklyBingoOrderDataType(key)
        local data = GetWeeklyBingoOrderDataData(key)
        local text = GetWeeklyBingoOrderDataText(key)
        LogInfo("[WonderousTails] Wonderous Tails #"..(i+1).." Key: "..key)
        LogInfo("[WonderousTails] Wonderous Tails #"..(i+1).." Type: "..type)
        LogInfo("[WonderousTails] Wonderous Tails #"..(i+1).." Data: "..data)
        LogInfo("[WonderousTails] Wonderous Tails #"..(i+1).." Text: "..text)

        local duty = SearchWonderousTailsTable(type, data, text)
        if duty == nil then
            yield("/echo duty is nil")
        end
        local dutyMode = "Support"
        if duty ~= nil then
            if CurrentLevel < duty.minLevel then
                yield("/echo [WonderousTails] Cannot queue for "..duty.dutyName.." as level is too low.")
                duty.dutyId = nil
            elseif type == 0 then -- trials
                yield("/autoduty cfg Unsynced true")
                dutyMode = "Trial"
            elseif type == 4 then -- raids
                yield("/autoduty cfg Unsynced true")
                dutyMode = "Raid"
            elseif CurrentLevel - duty.minLevel <= 20 then
                -- yield("/autoduty cfg dutyModeEnum 1") -- TODO: test this when it gets released
                -- yield("/autoduty cfg Unsynced false")
                dutyMode = "Support"
            else
                -- yield("/autoduty cfg dutyModeEnum 8")
                yield("/autoduty cfg Unsynced true")
                dutyMode = "Regular"
            end

            if duty.dutyId ~= nil then
                yield("/echo Queuing duty TerritoryId#"..duty.dutyId.." for Wonderous Tails #"..(i+1))
                yield("/autoduty run "..dutyMode.." "..duty.dutyId.." 1 true")
                yield("/bmrai on")
                yield("/rotation auto")
                yield("/wait 10")
                while GetCharacterCondition(34) or GetCharacterCondition(51) or GetCharacterCondition(56) do -- wait for duty to be finished
                    if GetCharacterCondition(2) and i > 4 then -- dead, not a dungeon
                        yield("/echo Died to "..duty.dutyName..". Skipping.")
                        repeat
                            yield("/wait 1")
                        until not GetCharacterCondition(2)
                        LeaveDuty()
                        break
                    end
                    yield("/wait 1")
                end
                yield("/wait 10")
            else
                if duty.dutyName ~= nil then
                    yield("/echo Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1).." "..duty.dutyName)
                    LogInfo("[WonderousTails] Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1).." "..duty.dutyName)
                else
                    yield("/echo Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1))
                    LogInfo("[WonderousTails] Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1))
                end
            end
        end
    end

    -- if GetWeeklyBingoTaskStatus(i) == 1
    --    and (not StopPlacingStickersAt7 or WeeklyBingoNumPlacedStickers() < 7)
    -- then
    --     if not IsAddonVisible("WeeklyBingo") then
    --         yield("/callback WeeklyBingo true 2 "..i)
    --         yield("/wait 1")
    --     end
    -- end
end

yield("/echo Completed all Wonderous Tails entries it is capable of.<se.3>")