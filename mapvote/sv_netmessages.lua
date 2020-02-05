MapVote.NominatedMaps = MapVote.NominatedMaps or {}

util.AddNetworkString("MapVote_Start")
util.AddNetworkString("MapVote_Update")
util.AddNetworkString("MapVote_Cancel")

local function canNominate(ply, map) 
    return tobool( isAvailableMap(map) && MapVote.AllMaps[map] && !MapVote.NominatedMaps[ply:SteamID()] )
end

function MapVote.UpdateNominatedMap(ply, map) -- функция вызывается при каждой номинации игроком    
    if ( canNominate(ply, map) ) then return false end

    MapVote.NominatedMaps[ply:SteamID()] = map
    return true
end

hook.Add("PlayerSay", "playersay", function(ply, text)
    local arguments = string.Split(text, " ")

    if ( table.HasValue(MapVote.Config.NominateCommands, string.sub(string.lower(arguments[1]), 2)) ) then
        local map = arguments[2]

        if !(MapVote.UpdateNominatedMap(ply, map)) then
            ply:ChatPrint("Cant nominate")
        end

        ply:ChatPrint("Nominated: " .. map)
        PrintTable(MapVote.NominatedMaps)
    end
end)

print("sv_netmessages loaded")