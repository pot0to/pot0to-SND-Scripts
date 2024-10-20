-- SETTINGS
downKeybind = "DOWN"
confirmKeybind = "DELETE"
plateNumber = 20

-- CODE
local table = require("table")

function Split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^\t]+)") do
        table.insert(t, str)
    end
    return t
end

function AddToFashionReportList(fashionReportList, itemId, itemName, itemSlot, category)
    local newItem = { itemId = itemId, itemName = itemName }
    for _, fashionReportCategory in ipairs(fashionReportList) do
        if fashionReportCategory.category == category then
            table.insert(fashionReportCategory.itemList, newItem )
            return
        end
    end
    table.insert( fashionReportList, { category=category, itemSlot = itemSlot, itemList={ newItem } })
end

function GetSlot()

yield("/target Glamour Dresser")
yield("/wait 0.1")
yield("/interact")

yield("/send DOWN")
yield("/wait 0.5")
yield("/send "..downKeybind)
yield("/wait 0.5")
yield("/send "..confirmKeybind)
yield("/wait 1")

yield("/callback MiragePrismMiragePlate true 17 "..(plateNumber - 1))

Slots = {
    MainHand= 0,
    OffHand = 1,
    Head    = 2,
    Body    = 3,
    Hands   = 4,
    Legs    = 5,
    Feet    = 6,
    Ears    = 7,
    Neck    = 8,
    Wrists  = 9,
    Ring    = 10
}

Categories = {}
for i=0, 12 do
    local category = GetNodeText("FashionCheck", 39-i, 2)
    if category ~= nil and category ~= "" and tonumber(category) == nil then
        table.insert(Categories, category)
    end
end

Sheet = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\Avant-Garde Data Spreadsheet - Data Tracker (Main).tsv"
File =  io.open(Sheet, 'r')
-- Parse all the lines
FashionReportList = {}

if File then
    for Line in File:lines() do
        local results = Split(Line, '\t')
        local itemIdString = results[1]
        local itemName = results[2]
        local itemSlot = results[3]
        local category = results[4]
        for _, fashionReportCategory in ipairs(Categories) do
            if fashionReportCategory == category then
                AddToFashionReportList(FashionReportList, tonumber(itemIdString), itemName, itemSlot, category)
            end
        end
    end
    -- Close file
    File:close()

    for _, fashionReportSlot in FashionReportList do
        local slotId = Slots[fashionReportSlot.itemSlot]
        yield("/callback MiragePrismMiragePlate true 13 "..slotId)
        yield("/callback MiragePrismPrismBox 2 49")
    end
else
  print("ERROR:", Sheet)
end
