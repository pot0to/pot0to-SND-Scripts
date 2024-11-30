--[[

********************************************************************************
*                               Map Gathering                                  * 
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Gathers a map, relogs as the next character in the list, rinse and repeat.
You will need to install Gather Buddy Reborn and add your desired map to the
auto gather list. This plugin only kicks off the gather list and waits for the
map to drop in your inventory, then stops the gathering and relogs as the next
character.

********************************************************************************
*                                    Version                                   *
*                                     0.1.2                                    *
********************************************************************************

0.1.2   Fixed state change between character swap and ready
0.1.1   Added code to support Delivery Moogle at Radz-at-Han (/tp radz)
0.1.0   Added ability to mail
0.0.10  Moved command to close gathering menu
0.0.9   Added checks to stop pathing and close gathering menus when ready to
            switch characters
0.0.8   Added ability to search entire timers list for map allowances, added
            other maps

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. Vnavmesh
2. Gather Buddy Reborn - Create an autogather list with your desired map
3. Autoretainer
]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

MapName = "Timeworn Gazelleskin Map" -- must match the map on your GBR list

Multimode = true
Characters =
{
	{ characterName="John Doe", worldName="Excalibur" },
	{ characterName="Jane Doe", worldName="Excalibur" }
}

Mail = true
    RecipientName = "John Doe"
    MailboxName = "Moogle Letter Box"       -- options: Moogle Letter Box, Regal Letter Box, Delivery Moogle
    MailboxTeleportCommand = "/li auto"     -- if you don't have a private home or fc, then "/tp radz" + Delivery Moogle will work

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
    if LifestreamIsBusy() then
        return
    end

    if GetItemCount(MapInfo.itemId) > 0 then
        yield("/echo Acquired map.")
        State = CharacterState.ready
        return
    end

    yield("/echo gathering")
    if not GBRAutoOn then
        yield("/gbr auto on")
        GBRAutoOn = true
    end
    yield("/wait 10")
end

function MailMap()
    if LifestreamIsBusy() then
        return
    end

    yield("/echo mailing")
    if GetItemCount(MapInfo.itemId) == 0 then
        if IsAddonVisible("LetterList") then
            yield("/callback LetterList true -1")
        end
        State = CharacterState.ready
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("LetterEditor") then
        if MapAttached then
            --local dateString = os.date("%B %d, %Y", os.time(os.date("*t")))
            yield('/callback LetterEditor true 0 0 "'..RecipientName..'" "sending you a map" 0 0')
            return
        end

        -- search through every inventory slot until you find the map
        for inventoryPage=0,4 do
            for inventorySlot=0,34 do
                if (GetItemIdInSlot(inventoryPage, inventorySlot) == MapInfo.itemId) then
                    yield("/callback LetterEditor true 3 0 "..inventoryPage.." "..inventorySlot.." 0 0")
                    MapAttached = true
                    return
                end
            end
        end

        yield("/echo Could not find "..MapInfo.itemName.." in inventory.")
        State = CharacterState.ready
        return
    end

    if IsAddonVisible("LetterList") then
        yield("/callback LetterList true 1 0 0 0") -- click "New"
        return
    end

    yield("/target "..MailboxName)

    if HasTarget() and GetTargetName() == MailboxName then
        if GetDistanceToTarget() > 5 then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), false)

            repeat
                yield("/wait 1")
            until GetDistanceToTarget() <= 5
            yield("/vnav stop")
        end
        yield("/interact")
        return
    else
        yield(MailboxTeleportCommand)
        return
    end
end

function SwapCharacters()
    yield("/echo swapping")
    if GBRAutoOn then
        yield("/gbr auto off")
        GBRAutoOn = false
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
                State = CharacterState.ready
			end
			return
		end
	end
	Multimode = false
end

function Ready()
    yield("/echo ready")
    if IsAddonVisible("Gathering") then
        yield("/callback Gathering true -1")
        return
    end

    if IsPlayerOccupied() then -- wait for player to be available
        return
    end

    if GetItemCount(MapInfo.itemId) > 0 then
        if Mail and RecipientName ~= GetCharacterName(false) then
            MapAttached = false
            State = CharacterState.mailing
        end
    elseif not HasMapAllowance() then
        yield("/echo No map allowance left for today.")
        if Multimode then
            State = CharacterState.swapping
        end
    else
        State = CharacterState.gathering
    end
end

CharacterState =
{
    ready = Ready,
    gathering = Gather,
    mailing = MailMap,
    swapping = SwapCharacters
}

yield("/at y")
GBRAutoOn = false
MapInfo = GetMapInfo()
State = CharacterState.ready
if MapInfo == nil then
    yield("/echo Cannot find item # for "..MapName)
else
    repeat
        State()
        yield("/wait 1")
    until not Multimode and (not HasMapAllowance() or (GetItemCount(MapInfo.itemId) > 0 and not Mail))
end