--[[
********************************************************************************
*                           Allied Society Quests                              *
*                               Version 0.1.1                                  *
********************************************************************************
Created by: pot0to (https://ko-fi.com/pot0to)

Goes around to the specified beast tribes, picks up 3 quests, does them, and
moves on to the next beast tribe.

********************************************************************************
*                                    Version                                   *
*                                     0.1.2                                    *
********************************************************************************

0.1.2   Added /qst stop after finishing one set of quests
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
    { alliedSocietyName="Pelupelu", class="Summoner" },
    { alliedSocietyName="Loporrits", class="Carpenter" },
    { alliedSocietyName="Omicrons", class="Miner" }
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
        questGiver = "Fibubb Gah",
        x = 103.12,
        y = 15.05,
        z = -359.51,
        zoneId = 146,
        aetheryteName = "Little Ala Mhigo"
    },
    sylphs =
    {
        alliedSocietyName = "Sylphs",
        questGiver = "Tonaxia",
        x = 46.41,
        y = 6.07,
        z = 252.91,
        zoneId = 152,
        aetheryteName = "The Hawthorne Hut"
    },
    kobolds =
    {
        alliedSocietyName = "Kobolds",
        questGiver = "789th Order Dustman Bo Bu",
        x = 12.857726,
        y = 16.164295,
        z = -178.77,
        zoneId = 180,
        aetheryteName = "Camp Overlook"
    },
    sahagin =
    {
        alliedSocietyName = "Sahagin",
        questGiver = "Houu",
        x = -244.53,
        y = -41.46,
        z = 52.75,
        zoneId = 138,
        aetheryteName = "Aleport"
    },
    ixal =
    {
        alliedSocietyName = "Ixal",
        questGiver = "Ehcatl Nine Manciple",
        x = 173.21,
        y = -5.37,
        z = 81.85,
        zoneId = 154,
        aetheryteName = "Fallgourd Float"
    },
    vanuvanu = {
        alliedSocietyName = "Vanu Vanu",
        questGiver = "Muna Vanu",
        x = -796.3722,
        y = -133.27,
        z = -404.35,
        zoneId = 401,
        aetheryteName = "Ok' Zundu"
    },
    vath = {
        alliedSocietyName = "Vath",
        questGiver = "Vath Keeneye",
        x = 58.80,
        y = -48.00,
        z = -171.64,
        zoneId = 398,
        aetheryteName = "Tailfeather"
    },
    moogles = {
        alliedSocietyName = "Moogles",
        questGiver = "Mogek the Marvelous",
        x = -335.28,
        y = 58.94,
        z = 316.30,
        zoneId = 400,
        aetheryteName = "Zenith"
    },
    kojin = {
        alliedSocietyName = "Kojin",
        questGiver = "Zukin",
        x = 391.22,
        y = -119.59,
        z = -234.92,
        zoneId = 613,
        aetheryteName = "Tamamizu"
    },
    ananta = {
        alliedSocietyName = "Ananta",
        questGiver = "Eshana",
        x = -26.91,
        y = 56.12,
        z = 233.53,
        zoneId = 612,
        aetheryteName = "The Peering Stones"
    },
    namazu = {
        alliedSocietyName = "Namazu",
        questGiver = "Seigetsu the Enlightened",
        x = -777.72,
        y = 127.81,
        z = 98.76,
        zoneId = 622,
        aetheryteName = "Dhoro Iloh"
    },
    pixies = {
        alliedSocietyName = "Pixies",
        questGiver = "Uin Nee",
        x = -453.69,
        y = 71.21,
        z = 573.54,
        zoneId = 816,
        aetheryteName = "Lydha Lran"
    },
    qitari = {
        alliedSocietyName = "Qitari",
        questGiver = "Qhoterl Pasol",
        x = 786.83,
        y = -45.82,
        z = -214.51,
        zoneId = 817,
        aetheryteName = "Fanow"
    },
    dwarves = {
        alliedSocietyName = "Dwarves",
        questGiver = "Regitt",
        x = -615.48,
        y = 65.60,
        z = -423.82,
        zoneId = 813,
        aetheryteName = "The Ostall Imperative"
    },
    arkosodara =
    {
        alliedSocietyName = "Arkosodara",
        questGiver = "Maru",
        x = -68.21,
        y = 39.99,
        z = 323.31,
        zoneId = 957,
        aetheryteName = "Yedlihmad"
    },
    loporrits =
    {
        alliedSocietyName = "Loporrits",
        questGiver = "Managingway",
        x = -201.27,
        y = -49.15,
        z = -273.8,
        zoneId = 959,
        aetheryteName = "Bestways Burrow"
    },
    omicrons =
    {
        alliedSocietyName = "Omicrons",
        questGiver = "Stigma-4",
        x=315.84,
        y=481.99,
        z=152.08,
        zoneId = 960,
        aetheryteName = "Base Omicron"
    },
    pelupleu =
    {
        alliedSocietyName = "Pelupelu",
        questGiver="Yubli",
        x=770.89954,
        y=12.846571,
        z=-261.0889,
        zoneId=1188,
        aetheryteName="Dock Poga",
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
    
        if not GetCharacterCondition(4) then
            yield('/gaction "mount roulette"')
        end
        repeat
            yield("/wait 1")
        until GetCharacterCondition(4)
        PathfindAndMoveTo(alliedSocietyTable.x, alliedSocietyTable.y, alliedSocietyTable.z, true)
        repeat
            yield("/wait 1")
        until not PathIsRunning() and not PathfindInProgress()

        yield("/gs change "..alliedSociety.class)
        yield("/wait 3")
    
        -- accept 3 allocations
        local quests = {}
        for i=1,3 do
            yield("/target "..alliedSocietyTable.questGiver)
            yield("/interact")

            repeat
                yield("/wait 1")
            until IsAddonVisible("SelectIconString")
            yield("/callback SelectIconString true 0")
            repeat
                yield("/wait 1")
            until not IsPlayerOccupied()
        end

        yield("/qst start")
        repeat
            yield("/wait 10")
        until #GetAcceptedAlliedSocietyQuests(alliedSociety.alliedSocietyName) == 0
        yield("/qst stop")
    end
end
