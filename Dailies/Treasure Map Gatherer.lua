--[[

********************************************************************************
*                               Map Gathering                                  * 
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
State Machine Diagram: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/FateFarmingStateMachine.drawio.png

Gathers a map, relogs as the next character in the list, and repeat.

********************************************************************************
*                                    Version                                   *
*                                     0.0.9                                    *
********************************************************************************
0.0.9   Added checks to stop pathing and close gathering menus when ready to
            switch characters
0.0.8   Added ability to search entire timers list for map allowances, added
            other maps

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. Vnavmesh
2. Gather Buddy Reborn
3. Autoretainer
]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

MapName = "Timeworn Gazelleskin Map"

Multimode = true
Characters =
{
	{ characterName="John Doe", worldName="Excalibur" },
	{ characterName="Jane Doe", worldName="Excalibur" }
}

--#endregion Settings

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

TimewornMapIds = {
    -- ARR Maps
    {itemId=6688, itemName="Timeworn Leather Map"},
    {itemId=6689, itemName="Timeworn Goatskin Map"},
    {itemId=6690, itemName="Timeworn Toadskin Map"},
    {itemId=6691, itemName="Timeworn Boarskin Map"},
    {itemId=6692, itemName="Timeworn Piesteskin Map"},

    -- Heavensward Maps
    {itemId=12241, itemName="Timeworn Archaeoskin Map"},
    {itemId=12242, itemName="Timeworn Wyvernskin Map"},
    {itemId=12243, itemName="Timeworn Dragonskin Map"},
    
    -- Stormblood Maps
    {itemId=17835, itemName="Timeworn Gaganaskin Map"},
    {itemId=17836, itemName="Timeworn Gazelleskin Map"},

    -- Shadowbringers Maps
    {itemId=26744, itemName="Timeworn Gliderskin Map"},
    {itemId=26745, itemName="Timeworn Zonureskin Map"},
    
    -- Endwalker Maps
    {itemId=36611, itemName="Timeworn Saigaskin Map"},
    {itemId=36612, itemName="Timeworn Kumbhiraskin Map"},
    {itemId=39591, itemName="Timeworn Ophiotauroskin Map"},

    -- Dawntrail Maps
    {itemId=43556, itemName="Timeworn Loboskin Map"},
    {itemId=43557, itemName="Timeworn Br'aaxskin Map"}
}

function GetMapInfo()
    for _, mapInfo in ipairs(TimewornMapIds) do
        if mapInfo.itemName == MapName then
            return mapInfo
        end
    end
end

function HasMapAllowance()
    if not IsAddonVisible("ContentsInfo") then
        yield("/timers")
        yield ("/wait 1")
    end

    for i = 1, 15 do
        local timerName = GetNodeText("ContentsInfo", 8, i, 5)
        if timerName == "Next Map Allowance" then
            return GetNodeText("ContentsInfo", 8, i, 4) == "Available Now"
        end
    end
    return false
end

function Gather()
    yield("/echo gathering")
    if not GBRAutoOn then
        yield("/gbr auto on")
        GBRAutoOn = true
    end
    yield("/wait 10")
end

function SwapCharacters()
    if IsAddonVisible("Gathering") then
        yield("/callback Gathering true -1")
        return
    end

    if PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
        return
    end

    yield("/echo swapping characters")
    yield("/ays multi d")
    yield("/ays disable")
	for i=1, #Characters do
		if Characters[i].visited == nil then
			Characters[i].visited = true
			local nextCharacterName = Characters[i].characterName.."@"..Characters[i].worldName
            yield("/echo "..nextCharacterName)
			if GetCharacterName(true) ~= nextCharacterName then
				yield("/ays relog "..nextCharacterName)
				-- yield("/wait 3")
                repeat
                    yield("/wait 1")
                until GetCharacterName(true) == nextCharacterName
                -- yield("/waitaddon _ActionBar <maxwait.600><wait.5>")
                yield("/waitaddon _ActionBar")
			end
			return
		end
	end
	Multimode = false
end

function Main()
    if not IsAddonVisible("ContentsInfo") then
        yield("/timers")
        yield("/wait 3")
        return
    end

    local hasMapAllowance = GetNodeText("ContentsInfo", 8, 10, 4)

    yield("/echo "..MapInfo.itemId)
    yield("/echo "..GetItemCount(MapInfo.itemId))
    if GetItemCount(MapInfo.itemId) > 0 or not HasMapAllowance() then
        if GBRAutoOn then
            yield("/gbr auto off")
            GBRAutoOn = false
        end
        if IsPlayerOccupied() then
            return
        end

        if GetItemCount(MapInfo.itemId) > 0 then
            yield("/echo Already have map in inventory.")
        end
        if not HasMapAllowance() then
            yield("/echo No map allowance left for today.")
        end

        yield("/li auto")
        yield("/wait 1")
        repeat
            yield("/wait 1")
        until LifestreamIsBusy()

        yield("/echo player is not occupied")

        SwapCharacters()
    else
        Gather()
    end
end

GBRAutoOn = false
MapInfo = GetMapInfo()
if MapInfo == nil then
    yield("/echo Cannot find item # for "..MapName)
else
    repeat
        Main()
        yield("/wait 1")
    until not Multimode
end