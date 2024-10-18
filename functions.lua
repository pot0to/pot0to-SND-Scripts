-- Svc.AetheryteList.FirstOrDefault(x => x.AetheryteId == aetheryteID)?.AetheryteData.GameData?.PlaceName.Value?.Name ?? string.Empty;
function GetAetheryteName(aetheryteId)
    for i=0,AetheryteList.Count do
        if AetheryteList[i] ~= nil then
            if AetheryteList[i].AetheryteId == aetheryteId then
                if AetheryteList[i].AetheryteData.GameData ~= nil then
                    if AetheryteList[i].AetheryteData.GameData.PlaceName.Value ~= nil then
                        if AetheryteList[i].AetheryteData.GameData.PlaceName.Value.Name ~= nil then
                            LogInfo(AetheryteList[i].AetheryteData.GameData.PlaceName.Value.Name)
                            return tostring(AetheryteList[i].AetheryteData.GameData.PlaceName.Value.Name):match("(.+):")
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

-- Svc.AetheryteList.FirstOrDefault(x => x.AetheryteId == aetheryteID)?.AetheryteData.GameData?.Level.FirstOrDefault()?.Value?.X ?? 0;
function GetAetheryteRawPos(aetheryteId)
    for i=0,AetheryteList.Count do
        if AetheryteList[i] ~= nil then
            if AetheryteList[i].AetheryteId == aetheryteId then
                if AetheryteList[i].AetheryteData.GameData ~= nil then
                    if AetheryteList[i].AetheryteData.GameData.Map ~= nil then
                        yield("/echo map not nil")
                        local level = AetheryteList[i].AetheryteData.GameData.Map
                        LogInfo(AetheryteList[i].AetheryteData.GameData.Level[1].X)
                        if AetheryteList[i].AetheryteData.GameData.Level[1].Value ~= nil then
                            
                            yield("/echo level value not nil")
                            return level.Value.X, level.Value.Y, level.Value.Z
                        end
                        yield("/echo level value is nil")
                    end
                end
            end
        end
    end
    return 0, 0, 0
end

local x,y,z = GetAetheryteRawPos(210)
yield("/echo "..x..", "..y..", "..z)