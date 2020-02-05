MapVote.AllMaps = MapVote.AllMaps or {}
MapVote.Maps = MapVote.Maps or {}

if file.Exists("mapvote/recent.txt", "DATA") then
    MapVote.RecentMaps = util.JSONToTable(file.Read("mapvote/recent.txt", "DATA"))
else
    MapVote.RecentMaps = {}
end

if file.Exists("mapvote/blacklist.txt", "DATA") then
    MapVote.BlackList = util.JSONToTable(file.Read("mapvote/blacklist.txt", "DATA"))
else
    MapVote.BlackList = {}
end

local function SetMaps()
    local maps = file.Find("maps/*.bsp", "GAME")

    for _, map in pairs(maps) do
        local map = string.lower( string.gsub(map, "%.bsp$", "") )
        table.insert(MapVote.AllMaps, map)
    end
end
SetMaps()

function isAvailableMap(map) 
    return tobool(MapVote.BlackList[map] || MapVote.RecentMaps[map]) 
end

function MapVote.CreateMapList() 
    local actualMaps = {}
    
    for _, map in RandomPairs(MapVote.AllMaps) do
        if (#actualMaps == MapVote.Config.MaxMaps) then break end

        if ( isAvailableMap(map) ) then continue end
        
        table.insert(actualMaps, map)
    end

    MapVote.Maps = actualMaps
    return true
end

function MapVote.ChangeRecentMapsList()
    local CurrentMap = string.lower( string.gsub(game.GetMap(), "%.bsp$", "") )
    table.insert(MapVote.RecentMaps, 1, CurrentMap)

    if (#MapVote.RecentMaps > MapVote.Config.MapsBeforeRevote) then 
        table.remove(MapVote.RecentMaps)
    end

    file.Write("mapvote/recent.txt", util.TableToJSON(MapVote.RecentMaps))
end
hook.Add("ShutDown", "ChangeRecentMapsList", MapVote.ChangeRecentMapsList)
