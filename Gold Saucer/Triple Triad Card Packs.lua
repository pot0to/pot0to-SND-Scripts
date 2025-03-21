--[[

********************************************************************************
*                            Firmament Craft All                               *
*                               Version 1.0.0                                  *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

This script will repeatedly purchase a specific triple triad card pack from the
vender in sets of 10, opens them, and repeats until you find the cards you're
looking for.

********************************************************************************
*                                   Settings                                   *
********************************************************************************

Please download Godbert (https://github.com/ufx/SaintCoinach/releases) and
search through the "Item" page to find the item codes.
]]

PackName = "Gold Triad Card"
PackId = 10077
ShopSlot = 38
CardsToLookFor = {
    9840,
    9842,
    9848,
    9851
}

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

function Main()
    if GetItemCount(PackId) > 0 then
        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency true -1")
        else
            yield("/item "..PackName)
            
            for i, card in ipairs(CardsToLookFor) do
                if GetItemCount(card) > 0 then
                    table.remove(CardsToLookFor, i)
                end
            end
            if #CardsToLookFor == 0 then
                Stop = true
            end
        end
        return
    end

    if not HasTarget() or GetTargetName() ~= "Triple Triad Trader" then
        yield("/target Triple Triad Trader")
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

    if IsAddonVisible("ShopExchangeCurrency") then
        yield("/callback ShopExchangeCurrency true 0 "..ShopSlot.." 10")
        return
    end

    yield("/interact")
end

Stop = false
while not Stop do
    Main()
    yield("/wait 0.5")
end