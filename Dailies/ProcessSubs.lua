FCZone = "Goblet"
ArtisanMagitekRepairListId = 14272

AllResidentialZones =
{
    {
        zoneName = "Mist",
        zoneId = 339,
        aetheryteName = "Limsa Lominsa",
        aetheryteZone = 129,
        entryAethernet = { x=-6, y=49, z=-112 },
        destinationAethernet = "Seagaze Markets"
    },
    {
        zoneName = "Lavender Beds",
        zoneId = 340,
        aetheryteName = "Gridania",
        aetheryteZone = 132,
        entryAethernet = { x=5, y=2, z=184 },
        destinationAethernet = "Dappled Stalls"
    },
    {
        zoneName = "Goblet",
        zoneId = 341,
        aetheryteName = "Ul'dah",
        aetheryteZone = 130,
        entryAethernet = { x=20, y=-12, z=-189 },
        destinationAethernet = "Goblet Exchange"
    },
    {
        zoneName = "Shirogane",
        zoneId = 641,
        aetheryteName = "Kugane",
        aetheryteZone = 628,
        entryAethernet = { x=20, y=-12, z=-189 },
        destinationAethernet = "Kobai Goten",
        materialSupplier = { x=-37, y=20, z=49 }
    },
    {
        zoneName = "Empyreum",
        zoneId = 979,
        aetheryteName = "Foundation",
        aetheryteZone = 418,
        -- entryAethernet = { x=20, y=-12, z=-189 },
        destinationAethernet = "The Halberd's Head"
    }
}

CompanyWorkshopZones = {
    423,
    424,
    425,
    653,
    984
}
function IsInCompanyWorkshop()
    local zoneId = GetZoneID()
    for _, zone in ipairs(CompanyWorkshopZones) do
        if zoneId == zone then
            return true
        end
    end
    return false
end

function GoToCompanyWorkshop()
    if IsInCompanyWorkshop() then
        State = CharacterState.turnInItems
        LogInfo("[WorkshopGatherer] StateChange: TurnInItems")
    else
        yield("/target \"Entrance to Additional Chambers\"")
        yield("/wait 0.5")
        if GetTargetName() == "Entrance to Additional Chambers" then
            FC = GetZoneID()
            if GetDistanceToTarget() > 3 then
                if not PathfindInProgress() and not PathIsRunning() then
                    yield("/vnav movetarget")
                end
            else
                if PathfindInProgress() or PathIsRunning() then
                    yield("/vnav stop")
                elseif PathfindInProgress() or PathIsRunning() then
                    yield("/vnav stop")
                elseif IsAddonVisible("SelectString") then
                    yield("/callback SelectString true 0")
                else
                    yield("/interact")
                    yield("/wait 1")
                end
            end
        else
            if FC == nil then
                yield("/li fc")
                repeat
                    yield("/wait 0.1")
                until LifestreamIsBusy()
                repeat
                    yield("/wait 1")
                until not LifestreamIsBusy()
                FC = { x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos() }
            else
                yield("/target Entrance")
                yield("/wait 0.5")
                if GetTargetName() == "Entrance" then
                    if GetDistanceToTarget() > 3 then
                        if not PathfindInProgress() and not PathIsRunning() then
                            yield("/vnav movetarget")
                        end
                    elseif PathfindInProgress() or PathIsRunning() then
                        yield("/vnav stop")
                    elseif IsAddonVisible("SelectYesno") then
                        yield("/callback SelectYesno true 0")
                    else
                        yield("/interact")
                    end
                end
            end
        end
    end
end

function PurchaseCeruleumTanks()
    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("FreeCompanyCreditShop") then
        yield("/callback FreeCompanyCreditShop true 0 0 99")
    elseif IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif GetTargetName() == "Mammet Voyager #004A" then
        if GetDistanceToTarget() > 7 then
            if not PathfindInProgress() and not PathIsRunning() then
                yield("/vnav movetarget")
            end
        else
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            else
                yield("/interact")
            end
        end
    else
        yield("/target Mammet Voyager #004A")
    end
end

function CraftRepairKits()
    if ArtisanIsListRunning() then
        yield("/wait 3")
        return
    else
        yield("/artisan lists "..ArtisanMagitekRepairListId.." start")
    end
end

CharacterCondition =
{
    betweenAreas=45
}

yield("/ays e")
for _, zone in ipairs(AllResidentialZones) do
    if zone.zoneName == FCZone then
        FCZone = zone.zoneId
        break
    end
end
while ARSubsWaitingToBeProcessed() do
    yield("/echo Subs waiting to be processed? "..tostring(ARSubsWaitingToBeProcessed()))
    if GetCharacterCondition(CharacterCondition.betweenAreas) then
        yield("/wait 1")
    elseif not IsInCompanyWorkshop() then
        GoToCompanyWorkshop()
    elseif GetItemCount(10155) < 12 then
        PurchaseCeruleumTanks()
    elseif GetItemCount(10373) < 24 then
        CraftRepairKits()
    elseif IsInCompanyWorkshop() then
        yield("/target Voyage Control Panel")
        yield("/wait 0.5")
        if GetDistanceToTarget() > 3 then
            if not PathfindInProgress() and not PathIsRunning() then
                yield("/vnav movetarget")
            end
            yield("/wait 1")
        elseif PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end
        yield("/interact")
    elseif GetCharacterCondition(CharacterCondition.betweenAreas) then
        yield("/wait 1")
    else
        
    end
    yield("/wait 0.1")
end
if IsAddonVisible("SelectString") then
    yield("/callback SelectString true -1")
end