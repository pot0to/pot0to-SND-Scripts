--[[
********************************************************************************
*                           Allied Society Quests                              *
*                               Version 0.2.0                                  *
********************************************************************************
Created by: pot0to (https://ko-fi.com/pot0to)

Goes around to the specified beast tribes, picks up 3 quests, does them, and
moves on to the next beast tribe.

********************************************************************************
*                                    Version                                   *
*                                     0.2.1                                    *
********************************************************************************

0.2.1   Fixed Mamool Ja name and removed main quests from presets
0.2.0   Added Mamool Jas for patch 7.25 (credit: Leonhart)
0.1.3   Fixed "Arkasodara" tribe name
        Added /qst stop after finishing one set of quests
        Updated Namazu aetheryte to Dhoro Iloh
        Added ability to change classes for different Allied Socieities
        First working version

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. Vnavmesh
2. Questionable
3. TextAdvance

--#region Settings
********************************************************************************
*                                   Settings                                   *
********************************************************************************
--]]

ToDoList = {
    { alliedSocietyName="Mamool Ja", class="Miner" },
    { alliedSocietyName="Amalj'aa", class="Summoner" }
}

--#endregion Settings

--[[
********************************************************************************
*            Code: Don't touch this unless you know what you're doing          *
********************************************************************************
]]

AlliedSocietiesTable =
{
    amaljaa = {
        alliedSocietyName = "Amalj'aa",
        mainQuests = { first=1217, last=1221 },
        dailyQuests = { first=1222, last=1251,
            blackList = {
                [1245] = true
            }
        },
        x = 103.12,
        y = 15.05,
        z = -359.51,
        zoneId = 146,
        aetheryteName = "Little Ala Mhigo",
        expac = "A Realm Reborn"
    },
    sylphs =
    {
        alliedSocietyName = "Sylphs",
        mainQuests = { first=1252, last=1256 },
        dailyQuests = { first=1257, last=1286 },
        x = 46.41,
        y = 6.07,
        z = 252.91,
        zoneId = 152,
        aetheryteName = "The Hawthorne Hut",
        expac = "A Realm Reborn"
    },
    kobolds =
    {
        alliedSocietyName = "Kobolds",
        mainQuests = { first=1320, last=1324 },
        dailyQuests = { first=1325, last=1373 },
        x = 12.857726,
        y = 16.164295,
        z = -178.77,
        zoneId = 180,
        aetheryteName = "Camp Overlook",
        expac = "A Realm Reborn"
    },
    sahagin =
    {
        alliedSocietyName = "Sahagin",
        mainQuests = { first=1374, last=1378 },
        dailyQuests = { first=1380, last=1409 },
        x = -244.53,
        y = -41.46,
        z = 52.75,
        zoneId = 138,
        aetheryteName = "Aleport",
        expac = "A Realm Reborn"
    },
    ixal =
    {
        alliedSocietyName = "Ixal",
        mainQuests = { first=1486, last=1493 },
        dailyQuests = { first=1494, last=1568 },
        x = 173.21,
        y = -5.37,
        z = 81.85,
        zoneId = 154,
        aetheryteName = "Fallgourd Float",
        expac = "A Realm Reborn"
    },
    vanuvanu = {
        alliedSocietyName = "Vanu Vanu",
        mainQuests = { first=2164, last=2225 },
        dailyQuests = { first=2171, last=2200 },
        x = -796.3722,
        y = -133.27,
        z = -404.35,
        zoneId = 401,
        aetheryteName = "Ok' Zundu",
        expac = "Heavensward"
    },
    vath = {
        alliedSocietyName = "Vath",
        mainQuests = { first=2164, last=2225 },
        dailyQuests = { first=2171, last=2200 },
        x = 58.80,
        y = -48.00,
        z = -171.64,
        zoneId = 398,
        aetheryteName = "Tailfeather",
        expac = "Heavensward"
    },
    moogles = {
        alliedSocietyName = "Moogles",
        mainQuests = { first=2320, last=2327 },
        dailyQuests = { first=2290, last=2319 },
        x = -335.28,
        y = 58.94,
        z = 316.30,
        zoneId = 400,
        aetheryteName = "Zenith",
        expac = "Heavensward"
    },
    kojin = {
        alliedSocietyName = "Kojin",
        mainQuests = { first=2973, last=2978 },
        dailyQuests = { first=2979, last=3002 },
        x = 391.22,
        y = -119.59,
        z = -234.92,
        zoneId = 613,
        aetheryteName = "Tamamizu",
        expac = "Stormblood"
    },
    ananta = {
        alliedSocietyName = "Ananta",
        mainQuests = { first=3036, last=3041 },
        dailyQuests = { first=3043, last=3069 },
        x = -26.91,
        y = 56.12,
        z = 233.53,
        zoneId = 612,
        aetheryteName = "The Peering Stones",
        expac = "Stormblood"
    },
    namazu = {
        alliedSocietyName = "Namazu",
        mainQuests = { first=3096, last=3102 },
        dailyQuests = { first=3103, last=3129 },
        x = -777.72,
        y = 127.81,
        z = 98.76,
        zoneId = 622,
        aetheryteName = "Dhoro Iloh",
        expac = "Stormblood"
    },
    pixies = {
        alliedSocietyName = "Pixies",
        mainQuests = { first=3683, last=3688 },
        dailyQuests = { first=3689, last=3716 },
        x = -453.69,
        y = 71.21,
        z = 573.54,
        zoneId = 816,
        aetheryteName = "Lydha Lran",
        expac = "Shadowbringers"
    },
    qitari = {
        alliedSocietyName = "Qitari",
        mainQuests = { first=3794, last=3805 },
        dailyQuests = { first=3806, last=3833 },
        x = 786.83,
        y = -45.82,
        z = -214.51,
        zoneId = 817,
        aetheryteName = "Fanow",
        expac = "Shadowbringers"
    },
    dwarves = {
        alliedSocietyName = "Dwarves",
        mainQuests = { first=3896, last=3901 },
        dailyQuests = { first=3902, last=3929 },
        x = -615.48,
        y = 65.60,
        z = -423.82,
        zoneId = 813,
        aetheryteName = "The Ostall Imperative",
        expac = "Shadowbringers"
    },
    arkosodara =
    {
        alliedSocietyName = "Arkasodara",
        mainQuests = { first=4545, last=4550 },
        dailyQuests = { first=4551, last=4578 },
        x = -68.21,
        y = 39.99,
        z = 323.31,
        zoneId = 957,
        aetheryteName = "Yedlihmad",
        expac = "Endwalker"
    },
    loporrits =
    {
        alliedSocietyName = "Loporrits",
        mainQuests = { first=4681, last=4686 },
        dailyQuests = { first=4687, last=4714 },
        x = -201.27,
        y = -49.15,
        z = -273.8,
        zoneId = 959,
        aetheryteName = "Bestways Burrow",
        expac = "Endwalker"
    },
    omicrons =
    {
        alliedSocietyName = "Omicrons",
        mainQuests = { first=4601, last=4606 },
        dailyQuests = { first=4607, last=4634 },
        x=315.84,
        y=481.99,
        z=152.08,
        zoneId = 960,
        aetheryteName = "Base Omicron",
        expac = "Endwalker"
    },
    pelupleu =
    {
        alliedSocietyName = "Pelupelu",
        mainQuests = { first=5193, last=5198 },
        dailyQuests = { first=5199, last=5226 },
        x=770.89954,
        y=12.846571,
        z=-261.0889,
        zoneId=1188,
        aetheryteName="Dock Poga",
        expac = "Dawntrail"
    },
    mamoolja =
    {
        alliedSocietyName = "Mamool Ja",
        mainQuests = { first=5255, last=5260 },
        dailyQuests = { first=5261, last=5288 },
        x=589.3,
        y=-142.9,
        z=730.5,
        zoneId = 1189,
        aetheryteName = "Mamook",
        expac = "Dawntrail"
    }
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

function GetAlliedSocietyTable(alliedSocietyName)
    for _, alliedSociety in pairs(AlliedSocietiesTable) do
        if alliedSociety.alliedSocietyName == alliedSocietyName then
            return alliedSociety
        end
    end
end

function GetAcceptedAlliedSocietyQuests(alliedSocietyName)
    local accepted = {}
    local allAcceptedQuests = GetAcceptedQuests()
    for i=0, allAcceptedQuests.Count-1 do
        if GetQuestAlliedSociety(allAcceptedQuests[i]):lower() == alliedSocietyName:lower() then
            table.insert(accepted, allAcceptedQuests[i])
        end
    end
    return accepted
end

function CheckAllowances()
    if not IsAddonVisible("ContentsInfo") then
        yield("/timers")
        yield ("/wait 1")
    end

    for i = 1, 15 do
        local timerName = GetNodeText("ContentsInfo", 8, i, 5)
        if timerName == "Next Allied Society Daily Quest Allowance" then
            return tonumber(GetNodeText("ContentsInfo", 8, i, 4):match("%d+$"))
        end
    end
    return 0
end

if HasPlugin("Lifestream") then
    TeleportCommand = "/li tp"
elseif HasPlugin("Teleporter") then
    TeleportCommand = "/tp"
else
    yield("/error Please install either Teleporter or Lifestream")
    yield("/snd stop")
end
function TeleportTo(aetheryteName)
    yield(TeleportCommand.." "..aetheryteName)
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

yield("/at y")
for _, alliedSociety in ipairs(ToDoList) do
    local alliedSocietyTable = GetAlliedSocietyTable(alliedSociety.alliedSocietyName)
    if alliedSocietyTable ~= nil then
        repeat
            yield("/wait 1")
        until not IsPlayerOccupied()

        if not IsInZone(alliedSocietyTable.zoneId) then
            TeleportTo(alliedSocietyTable.aetheryteName)
        end
    
        if not GetCharacterCondition(CharacterCondition.mounted) then
            yield('/gaction "mount roulette"')
        end
        repeat
            yield("/wait 1")
        until GetCharacterCondition(CharacterCondition.mounted)
        PathfindAndMoveTo(alliedSocietyTable.x, alliedSocietyTable.y, alliedSocietyTable.z, true)
        repeat
            yield("/wait 1")
        until not PathIsRunning() and not PathfindInProgress()

        yield("/gs change "..alliedSociety.class)
        yield("/wait 3")

        -- pick up quests and add them to Questionable's priority list
        local timeout = os.time()
        local quests = {}
        for questId=alliedSocietyTable.dailyQuests.first, alliedSocietyTable.dailyQuests.last+1 do
            if not QuestionableIsQuestLocked(tostring(questId)) and not alliedSocietyTable.dailyQuests.blackList[questId] then
                table.insert(quests, questId)
                QuestionableClearQuestPriority()
                QuestionableAddQuestPriority(tostring(questId))
                repeat
                    if not QuestionableIsRunning() then
                        yield("/qst start")
                    elseif os.time() - timeout > 5 then
                        yield("/echo Took more than 5 seconds to pick up the quest. Questionable may be stuck. Reloading...")
                        yield("/qst reload")
                        timeout = os.time()
                    end
                    yield("/wait 1.1")
                until IsQuestAccepted(questId)
                timeout = os.time()
                yield("/qst stop")
            end
        end

        for _, questId in ipairs(quests) do
            QuestionableAddQuestPriority(tostring(questId))
        end

        repeat
            if not QuestionableIsRunning() then
                yield("/qst start")
            end
            yield("/wait 1.2")
        until #GetAcceptedAlliedSocietyQuests(alliedSociety.alliedSocietyName) == 0
        yield("/qst stop")
    end
end
