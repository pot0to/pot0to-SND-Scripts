-- Svc.AetheryteList.FirstOrDefault(x => x.AetheryteId == aetheryteID)?.AetheryteData.GameData?.PlaceName.Value?.Name ?? string.Empty;
function GetAetheryteName(aetheryteId)
    for i=0,AetheryteList.Count do
        if AetheryteList[i] ~= nil then
            if AetheryteList[i].AetheryteId == aetheryteId then
                if AetheryteList[i].AetheryteData.GameData ~= nil then
                    if AetheryteList[i].AetheryteData.GameData.PlaceName.Value ~= nil then
                        if AetheryteList[i].AetheryteData.GameData.PlaceName.Value.Name ~= nil then
                            LogInfo(AetheryteList[i].AetheryteData.GameData.PlaceName.Value.Name)
                            return tostring(AetheryteList[i].AetheryteData.GameData.PlaceName.Value.Name):gsub(": %d+", "")
                        end
                    end
                end
            end
        end
    end
end

-- Svc.AetheryteList.Where(x => x.TerritoryId == zoneID).Select(x => x.AetheryteId).ToList();
function GetAetherytesInZone(zoneId)
    local aetherytes = {}
    for i=0,AetheryteList.Count do
        if AetheryteList[i] ~= nil then
            if AetheryteList[i].TerritoryId == zoneId then
                yield("/echo "..AetheryteList[i].AetheryteId)
                table.insert(aetherytes, AetheryteList[i].AetheryteId)
            end
        end
    end
    return aetherytes
end

for _, aetheryte in ipairs(GetAetherytesInZone(478)) do
    yield("/echo "..aetheryte)
end