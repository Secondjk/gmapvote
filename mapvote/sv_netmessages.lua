MapVote.NominatedMaps = MapVote.NominatedMaps or {}

util.AddNetworkString("MapVote_Start")
util.AddNetworkString("MapVote_Update")
util.AddNetworkString("MapVote_Cancel")
util.AddNetworkString("MapVote_End")

local function canNominate(ply, map)
    return isAvailableMap(map) && IsValid(MapVote.AllMaps[map]) && !MapVote.Allow
end

net.Receive("MapVote_Update", function(len, ply)
    if ( MapVote.Allow && IsValid(ply) ) then
        local map_id = net.ReadUInt(32)

        if ( MapVote.CurrentMaps[map_id] ) then
            MapVote.Votes[ply:SteamID()] = map_id

            net.Start("MapVote_Update")
                net.WriteTable(MapVote.Votes)
            net.Broadcast()
        end
    end
end)

function MapVote.UpdateNominatedMap(ply, map) -- функция вызывается при каждой номинации игроком    
    if ( !canNominate(ply, map) ) then return false end

    MapVote.NominatedMaps[ply:SteamID()] = map
    return true
end

function MapVote.NominateChatCommands(ply, text)
    local arguments = string.Split(text, " ")

    if ( table.HasValue(MapVote.Config.NominateCommands, string.sub(string.lower(arguments[1]), 2)) ) then
        local map = arguments[2]

        if ( MapVote.UpdateNominatedMap(ply, map) ) then
            ply:ChatPrint("Nominated: " .. map) -- вызов сообщения в чат
        else
            ply:ChatPrint("Can't nominate " .. map) -- вызов сообщения в чат локально
        end
    end
end

if ( MapVote.Config.PlayersCanNominateMaps ) then
    hook.Add("PlayerSay", "NominateChatCommands", MapVote.NominateChatCommands)
end

function MapVote.PlayerDisconnect(ply)
    if ( MapVote.NominatedMaps[ply:SteamID()] ) then
        MapVote.NominatedMaps[ply:SteamID()] = nil
    end
end
hook.Add("PlayerDisconnected", "MapVoteDisconnect", MapVote.PlayerDisconnect)

print("sv_netmessages loaded")