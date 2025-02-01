--[[

********************************************************************************
*                             Multi Zone Farming                               *
*                                Version 1.0.1                                 *
********************************************************************************

Multi zone farming script meant to be used with `Fate Farming.lua`. This will go
down the list of zones and farm fates until there are no eligible fates left,
then teleport to the next zone and restart the fate farming script.

Created by: pot0to (https://ko-fi.com/pot0to)
        
    -> 1.0.1    Added check for death and unexpected combat
                First release

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

FateMacro = "Fate Farming Companion"      -- Name of whatever you nicknamed the base fate farming SND script
initialJob = "WHM"  -- job name
ClassForBossFates = false -- set True if using different job when doing boss fate

-- Ctrl+F through Fate Farming.lua to find the zoneIds, or find them in Godbert
ZonesToFarm =
{
    -- Uncomment this for EW fates
    -- { zoneName = "Elpis", zoneId = 961},
    -- { zoneName = "Ultima Thule", zoneId = 960},
    -- { zoneName = "Garlemald", zoneId = 958},
    -- { zoneName = "Thavnair", zoneId = 957},
    -- { zoneName = "Labyrinthos", zoneId = 956},

    -- DT Fates
    { zoneName = "Urqopacha", zoneId = 1187 },
    { zoneName = "Kozama'uka", zoneId = 1188 },
    { zoneName = "Yak T'el", zoneId = 1189 },
    { zoneName = "Shaaloani", zoneId = 1190 },
    { zoneName = "Heritage Found", zoneId = 1191 },
    { zoneName = "Living Memory", zoneId = 1192 }
}

--#endregion Settings

------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
**************************************************************
*  Code: Don't touch this unless you know what you're doing  *
**************************************************************
]]

ClassList =
{
    gla = { classId=1, className="Gladiator", isMelee=true, isTank=true },
    pgl = { classId=2, className="Pugilist", isMelee=true, isTank=false },
    mrd = { classId=3, className="Marauder", isMelee=true, isTank=true },
    lnc = { classId=4, className="Lancer", isMelee=true, isTank=false },
    arc = { classId=5, className="Archer", isMelee=false, isTank=false },
    cnj = { classId=6, className="Conjurer", isMelee=false, isTank=false },
    thm = { classId=7, className="Thaumaturge", isMelee=false, isTank=false },
    pld = { classId=19, className="Paladin", isMelee=true, isTank=true },
    mnk = { classId=20, className="Monk", isMelee=true, isTank=false },
    war = { classId=21, className="Warrior", isMelee=true, isTank=true },
    drg = { classId=22, className="Dragoon", isMelee=true, isTank=false },
    brd = { classId=23, className="Bard", isMelee=false, isTank=false },
    whm = { classId=24, className="White Mage", isMelee=false, isTank=false },
    blm = { classId=25, className="Black Mage", isMelee=false, isTank=false },
    acn = { classId=26, className="Arcanist", isMelee=false, isTank=false },
    smn = { classId=27, className="Summoner", isMelee=false, isTank=false },
    sch = { classId=28, className="Scholar", isMelee=false, isTank=false },
    rog = { classId=29, className="Rogue", isMelee=false, isTank=false },
    nin = { classId=30, className="Ninja", isMelee=true, isTank=false },
    mch = { classId=31, className="Machinist", isMelee=false, isTank=false},
    drk = { classId=32, className="Dark Knight", isMelee=true, isTank=true },
    ast = { classId=33, className="Astrologian", isMelee=false, isTank=false },
    sam = { classId=34, className="Samurai", isMelee=true, isTank=false },
    rdm = { classId=35, className="Red Mage", isMelee=false, isTank=false },
    blu = { classId=36, className="Blue Mage", isMelee=false, isTank=false },
    gnb = { classId=37, className="Gunbreaker", isMelee=true, isTank=true },
    dnc = { classId=38, className="Dancer", isMelee=false, isTank=false },
    rpr = { classId=39, className="Reaper", isMelee=true, isTank=false },
    sge = { classId=40, className="Sage", isMelee=false, isTank=false },
    vpr = { classId=41, className="Viper", isMelee=true, isTank=false },
    pct = { classId=42, className="Pictomancer", isMelee=false, isTank=false }
}

function setSNDProperty(propertyName, value)
    local currentValue = GetSNDProperty(propertyName)
    if currentValue ~= value then
        SetSNDProperty(propertyName, tostring(value))
        LogInfo("[SetSNDProperty] " .. propertyName .. " set to " .. tostring(value))
    end
end

setSNDProperty("UseItemStructsVersion", true)

function GetClassJobTableFromAbbrev(classString)
    if classString == "" then
        LogInfo("[FATE] No class set")
        return nil
    end
    for classJobAbbrev, classJob in pairs(ClassList) do
        if classJobAbbrev == string.lower(classString) then
            return classJob
        end
    end
    LogInfo("[FATE] Cannot recognize combat job.")
    return nil
end

MainClass = GetClassJobTableFromAbbrev(initialJob)
CharacterCondition = {
    casting=27,
    betweenAreas=45
}

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait 1")
    end
    yield("/wait 1")
end

FarmingZoneIndex = 1
OldBicolorGemCount = GetItemCount(26807)
while true do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        local currentClass = GetClassJobId()
        if GetCharacterCondition(2) or GetCharacterCondition(26) or GetZoneID() == ZonesToFarm[FarmingZoneIndex].zoneId then
            if currentClass ~= MainClass.classId and ClassForBossFates then
                LogInfo("Switch back to "..MainClass.className)
                yield("/gs change "..MainClass.className)
            end
            LogInfo("[MultiZone] Starting FateMacro")
            yield("/snd run "..FateMacro)
            repeat
                yield("/wait 3")
            until not IsMacroRunningOrQueued(FateMacro)
            LogInfo("[MultiZone] FateMacro has stopped")
            NewBicolorGemCount = GetItemCount(26807)
            if NewBicolorGemCount == OldBicolorGemCount then
                yield("/echo Bicolor Count: "..NewBicolorGemCount)
                FarmingZoneIndex  = (FarmingZoneIndex % #ZonesToFarm) + 1
            else
                OldBicolorGemCount = NewBicolorGemCount
            end
        else
            LogInfo("[MultiZone] Teleporting to "..ZonesToFarm[FarmingZoneIndex].zoneName)
            TeleportTo(GetAetheryteName(GetAetherytesInZone(ZonesToFarm[FarmingZoneIndex].zoneId)[0]))
        end
    end
    yield("/wait 1")
end