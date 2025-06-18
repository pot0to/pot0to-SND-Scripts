Cap = 450
DutyToRun = 1266 -- The Underkeep

while not IsAddonVisible("Currency") do
    yield("/currency")
    yield("/wait 2")
    yield("/callback Currency true 12 1")
    yield("/wait 2")
end

local fraction = GetNodeText("Currency", 66, 1)
local numerator, denominator = fraction:match("(%d+)/(%d+)")
numerator = tonumber(numerator)
denominator = tonumber(denominator)

while IsAddonVisible("Currency") do
    yield("/callback Currency true -1")
    yield("/wait 2")
end

yield("/autoduty run Support "..DutyToRun.." "..(math.ceil((denominator - numerator)/50)).." true")
