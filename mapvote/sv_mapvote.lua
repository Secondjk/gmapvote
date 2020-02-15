MapVote.AllMaps = MapVote.AllMaps or {}
MapVote.Allow = false

if file.Exists( "mapvote/recent.txt", "DATA" ) then
    MapVote.RecentMaps = util.JSONToTable(file.Read("mapvote/recent.txt", "DATA"))
else
    MapVote.RecentMaps = {}
end

if file.Exists( "mapvote/blacklist.txt", "DATA" ) then
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
    return !( table.HasValue(MapVote.BlackList, map) || table.HasValue(MapVote.RecentMaps, map) )
end

function MapVote.CreateMapList()
    local actualMaps = {}

    for _, map in RandomPairs(MapVote.NominatedMaps) do
        if ( #actualMaps == MapVote.Config.MaxNominatedMaps ) then break end
        table.insert(actualMaps, map)
    end

    for _, map in RandomPairs(MapVote.AllMaps) do
        if ( #actualMaps == MapVote.Config.MaxMaps ) then break end

        if ( !isAvailableMap(map) || table.HasValue(actualMaps, map) ) then continue end

        table.insert(actualMaps, map)
    end

    MapVote.CurrentMaps = actualMaps
    return true
end

function MapVote.Start()
    if ( !MapVote.CreateMapList() ) then error("createmaplist err") end

    net.Start("MapVote_Start")
        net.WriteTable(MapVote.CurrentMaps)
        net.WriteUInt(MapVote.Config.VoteTime, 16)
    net.Broadcast()

    MapVote.Allow = true

    timer.Create("MapVote_ActivePhase", MapVote.Config.VoteTime, 1, function()
        MapVote.Allow = false
        local results = {}

        for k, v in pairs(player.GetAll()) do
            MapVote.Votes[v:SteamID()] = 1
        end

        for k, v in pairs(MapVote.Votes) do
            if ( !results[v] ) then
                results[v] = 0
            end

            for _, ply in pairs(player.GetAll()) do
                if ( ply:SteamID() == k ) then
                    if ( MapVote.Config.ExtraPower[ply:GetUserGroup()] ) then
                        results[v] = results[v] + MapVote.Config.ExtraPower[ply:GetUserGroup()]
                    else
                        results[v] = results[v] + 1
                    end
                end
            end

            local winner_key = table.GetWinningKey(results)

            net.Start("MapVote_End")
                net.WriteUInt(winner_key, 32)
            net.Broadcast()

            timer.Simple(3, function()
                RunConsoleCommand("changelevel", MapVote.CurrentMaps[winner_key])
            end) 
        end
    end)
end

function MapVote.Cancel()
    if ( MapVote.Allow ) then
        MapVote.Allow = false

        net.Start("MapVote_Cancel")
        net.Broadcast()

        timer.Remove("MapVote_ActivePhase")
    end
end

function MapVote.ChangeRecentMapsList()
    local CurrentMap = string.lower( string.gsub(game.GetMap(), "%.bsp$", "") )
    table.insert(MapVote.RecentMaps, 1, CurrentMap)

    if ( #MapVote.RecentMaps > MapVote.Config.MapsBeforeRevote ) then
        table.remove(MapVote.RecentMaps)
    end

    file.Write("mapvote/recent.txt", util.TableToJSON(MapVote.RecentMaps))
end
hook.Add("ShutDown", "ChangeRecentMapsList", MapVote.ChangeRecentMapsList)